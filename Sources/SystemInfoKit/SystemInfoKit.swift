import Foundation
import Dispatch
import Darwin
import os
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif
#if os(macOS)
import IOKit.ps
import CoreWLAN
#endif

/// SystemInfoKit —— 中文友好的系统检测工具库
///
/// 解决「查系统信息要记各种零散 API」的痛点：
/// - 把系统版本、设备型号、硬件、电池、热状态、屏幕、网络、本地化、资源占用、存储详情等常用检测项集中封装；
/// - 每个属性都带中文文档注释 + 中文命名别名，见名即用。
///
/// 快速开始：
/// ```swift
/// import SystemInfoKit
///
/// SystemInfoKit.系统版本      // "13.5.2"
/// SystemInfoKit.设备标识符     // "MacBookPro18,1"
/// SystemInfoKit.内存总量       // "16 GB"
/// ```
public enum SystemInfoKit {

    /// 库版本号
    public static let version = "0.6.0"

    // MARK: - 系统信息

    /// 系统名称（`macOS` / `iOS`）
    public static var systemName: String {
        #if os(macOS)
        return "macOS"
        #elseif os(iOS)
        return "iOS"
        #else
        return "unknown"
        #endif
    }

    /// 系统版本号（形如 `13.5.2`）
    public static var systemVersion: String {
        let v = ProcessInfo.processInfo.operatingSystemVersion
        return "\(v.majorVersion).\(v.minorVersion).\(v.patchVersion)"
    }

    /// 系统完整版本字符串（形如 `Version 13.5.2 (Build 22G91)`）
    public static var systemVersionString: String {
        ProcessInfo.processInfo.operatingSystemVersionString
    }

    // MARK: - 设备信息

    /// 设备标识符（形如 `MacBookPro18,1` / `iPhone14,2`）
    public static var deviceIdentifier: String {
        #if os(macOS)
        return sysctlString("hw.model") ?? "unknown"
        #else
        var systemInfo = utsname()
        uname(&systemInfo)
        let mirror = Mirror(reflecting: systemInfo.machine)
        return mirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        #endif
    }

    /// 设备名称（iOS 为用户设置的名称；macOS 为主机名）
    public static var deviceName: String {
        #if canImport(UIKit)
        return UIDevice.current.name
        #else
        return ProcessInfo.processInfo.hostName
        #endif
    }

    /// 设备类型（`iPhone` / `iPad` / `Mac`）
    public static var deviceType: String {
        #if canImport(UIKit)
        switch UIDevice.current.userInterfaceIdiom {
        case .phone: return "iPhone"
        case .pad: return "iPad"
        case .tv: return "Apple TV"
        case .mac: return "Mac"
        default: return "iOS 设备"
        }
        #else
        return "Mac"
        #endif
    }

    // MARK: - 硬件信息

    /// 物理内存总量（字节）
    public static var memoryTotalBytes: UInt64 {
        ProcessInfo.processInfo.physicalMemory
    }

    /// 物理内存总量（人类可读，形如 `16 GB`）
    public static var memoryTotal: String {
        ByteCountFormatter.string(fromByteCount: Int64(memoryTotalBytes), countStyle: .memory)
    }

    /// 处理器逻辑核心数
    public static var processorCount: Int {
        ProcessInfo.processInfo.processorCount
    }

    /// 处理器当前可用核心数
    public static var activeProcessorCount: Int {
        ProcessInfo.processInfo.activeProcessorCount
    }

    /// 处理器型号（形如 `Apple M1 Pro`，仅 macOS 支持）
    public static var processorName: String? {
        #if os(macOS)
        return sysctlString("machdep.cpu.brand_string")
        #else
        return nil
        #endif
    }

    /// 当前进程的 CPU 架构（编译期决定，形如 `arm64` / `x86_64`）
    public static var cpuArchitecture: String {
        #if arch(arm64)
        return "arm64"
        #elseif arch(x86_64)
        return "x86_64"
        #else
        return "unknown"
        #endif
    }

    /// 磁盘总容量（字节）
    public static var diskTotalBytes: UInt64 {
        fileSystemAttribute(.systemSize) ?? 0
    }

    /// 磁盘剩余容量（字节）
    public static var diskFreeBytes: UInt64 {
        fileSystemAttribute(.systemFreeSize) ?? 0
    }

    /// 磁盘总容量（人类可读，形如 `494 GB`）
    public static var diskTotal: String {
        ByteCountFormatter.string(fromByteCount: Int64(diskTotalBytes), countStyle: .file)
    }

    /// 磁盘剩余容量（人类可读）
    public static var diskFree: String {
        ByteCountFormatter.string(fromByteCount: Int64(diskFreeBytes), countStyle: .file)
    }

    /// 磁盘已用容量（字节）
    public static var diskUsedBytes: UInt64 {
        let total = diskTotalBytes
        let free = diskFreeBytes
        return total >= free ? total - free : 0
    }

    /// 磁盘已用容量（人类可读，形如 `200 GB`）
    public static var diskUsed: String {
        ByteCountFormatter.string(fromByteCount: Int64(diskUsedBytes), countStyle: .file)
    }

    /// 磁盘使用率（`0.0` ~ `1.0`）
    public static var diskUsagePercent: Double {
        let total = diskTotalBytes
        guard total > 0 else { return 0 }
        return Double(diskUsedBytes) / Double(total)
    }

    // MARK: - 存储详情

    /// 重要用途可用容量（字节）
    ///
    /// 通过 URL 资源值 `volumeAvailableCapacityForImportantUsageKey` 读取，
    /// 相比 `diskFreeBytes`（严格剩余）更贴近系统「可用空间」口径——已把可清除内容计入。
    /// iOS 11+ / macOS 10.13+（本库基线之上）。
    public static var availableCapacityBytes: UInt64 {
        let value = homeVolumeValues()?.volumeAvailableCapacityForImportantUsage ?? 0
        return UInt64(max(0, value))
    }

    /// 重要用途可用容量（人类可读，形如 `100 GB`）
    public static var availableCapacity: String {
        ByteCountFormatter.string(fromByteCount: Int64(availableCapacityBytes), countStyle: .file)
    }

    /// 机会性可用容量（字节）：系统认为可随时清理出的空间（含缓存等）
    public static var opportunisticCapacityBytes: UInt64 {
        let value = homeVolumeValues()?.volumeAvailableCapacityForOpportunisticUsage ?? 0
        return UInt64(max(0, value))
    }

    /// 机会性可用容量（人类可读）
    public static var opportunisticCapacity: String {
        ByteCountFormatter.string(fromByteCount: Int64(opportunisticCapacityBytes), countStyle: .file)
    }

    /// 主卷名（形如 `Macintosh HD`）
    public static var volumeName: String {
        homeVolumeValues()?.volumeName ?? "未知"
    }

    /// 文件系统类型（形如 `APFS`）
    public static var fileSystemName: String {
        homeVolumeValues()?.volumeLocalizedFormatDescription ?? "未知"
    }

    // MARK: - 电池

    /// 电池电量（`0.0` ~ `1.0`；未知或不支持时返回 `nil`）
    ///
    /// iOS 取 `UIDevice`，macOS 通过 IOKit 读取内置电池。
    public static var batteryLevel: Float? {
        #if canImport(UIKit)
        UIDevice.current.isBatteryMonitoringEnabled = true
        let level = UIDevice.current.batteryLevel
        return level < 0 ? nil : level
        #elseif os(macOS)
        guard let desc = macBatteryDescription() else { return nil }
        guard let current = desc[kIOPSCurrentCapacityKey as String] as? Int,
              let max = desc[kIOPSMaxCapacityKey as String] as? Int, max > 0 else { return nil }
        return Float(current) / Float(max)
        #else
        return nil
        #endif
    }

    /// 是否正在充电 / 接通电源（未知或不支持时返回 `nil`）
    ///
    /// iOS 取 `UIDevice` 的充电状态，macOS 通过 IOKit 判断是否接通交流电源。
    public static var isCharging: Bool? {
        #if canImport(UIKit)
        UIDevice.current.isBatteryMonitoringEnabled = true
        switch UIDevice.current.batteryState {
        case .charging, .full: return true
        case .unplugged: return false
        case .unknown: return nil
        @unknown default: return nil
        }
        #elseif os(macOS)
        guard let desc = macBatteryDescription() else { return nil }
        guard let state = desc[kIOPSPowerSourceStateKey as String] as? String else { return nil }
        return state == (kIOPSACPowerValue as String)
        #else
        return nil
        #endif
    }

    // MARK: - 热状态与电源

    /// 设备热状态（`ProcessInfo.ThermalState` 枚举）
    ///
    /// 系统根据设备温度与负载给出的散热状态：正常 / 尚可 / 严重 / 危急。
    /// 通常用于在设备过热时主动降载（暂停后台任务、降低帧率等）。
    public static var thermalState: ProcessInfo.ThermalState {
        ProcessInfo.processInfo.thermalState
    }

    /// 热状态中文名（「正常」「尚可」「严重」「危急」）
    public static var thermalStateName: String {
        switch thermalState {
        case .nominal: return "正常"
        case .fair: return "尚可"
        case .serious: return "严重"
        case .critical: return "危急"
        @unknown default: return "未知"
        }
    }

    /// 是否开启低功耗模式（仅 iOS 支持；macOS 恒为 `false`）
    public static var isLowPowerModeEnabled: Bool {
        #if canImport(UIKit)
        return ProcessInfo.processInfo.isLowPowerModeEnabled
        #else
        return false
        #endif
    }

    // MARK: - 屏幕

    /// 屏幕分辨率（逻辑点，形如 `1512×982`；macOS 取主屏）
    public static var screenSize: String {
        #if canImport(UIKit)
        let b = UIScreen.main.bounds
        return "\(Int(b.width))×\(Int(b.height))"
        #elseif canImport(AppKit)
        if let frame = NSScreen.main?.frame {
            return "\(Int(frame.width))×\(Int(frame.height))"
        }
        return "未知"
        #else
        return "未知"
        #endif
    }

    /// 屏幕缩放因子（`1.0` / `2.0` / `3.0` 等）
    public static var screenScale: CGFloat {
        #if canImport(UIKit)
        return UIScreen.main.scale
        #elseif canImport(AppKit)
        return NSScreen.main?.backingScaleFactor ?? 1
        #else
        return 1
        #endif
    }

    /// 显示器数量（内置屏 + 外接屏）
    public static var displayCount: Int {
        #if canImport(UIKit)
        return UIScreen.screens.count
        #elseif canImport(AppKit)
        return NSScreen.screens.count
        #else
        return 0
        #endif
    }

    /// 各显示器分辨率（逻辑点，形如 `1512×982`，按系统屏幕顺序）
    public static var displayResolutions: [String] {
        #if canImport(UIKit)
        return UIScreen.screens.map { "\(Int($0.bounds.width))×\(Int($0.bounds.height))" }
        #elseif canImport(AppKit)
        return NSScreen.screens.map { "\(Int($0.frame.width))×\(Int($0.frame.height))" }
        #else
        return []
        #endif
    }

    /// 各显示器缩放因子（与 `displayResolutions` 一一对应）
    public static var displayScales: [CGFloat] {
        #if canImport(UIKit)
        return UIScreen.screens.map { $0.scale }
        #elseif canImport(AppKit)
        return NSScreen.screens.map { $0.backingScaleFactor }
        #else
        return []
        #endif
    }

    // MARK: - 运行时长与模拟器

    /// 系统自启动以来的运行时长（秒）
    public static var systemUptime: TimeInterval {
        ProcessInfo.processInfo.systemUptime
    }

    /// 系统运行时长（人类可读，形如 `3 天 5 小时`）
    public static var systemUptimeString: String {
        let seconds = Int(systemUptime)
        let days = seconds / 86400
        let hours = (seconds % 86400) / 3600
        let minutes = (seconds % 3600) / 60
        if days > 0 { return "\(days) 天 \(hours) 小时" }
        if hours > 0 { return "\(hours) 小时 \(minutes) 分钟" }
        return "\(minutes) 分钟"
    }

    /// 系统本次开机的时间点（`Date`，由「当前时间 − 运行时长」推算）
    public static var bootTime: Date {
        Date(timeIntervalSinceNow: -systemUptime)
    }

    /// 系统本次开机时间（人类可读，形如 `2026-09-08 14:30:00`）
    public static var bootTimeString: String {
        bootTimeFormatter.string(from: bootTime)
    }

    /// 是否运行在模拟器上
    public static var isSimulator: Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        return false
        #endif
    }

    // MARK: - App 信息

    /// App 显示名称（从 Info.plist 读取，取不到时回退进程名）
    public static var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? ProcessInfo.processInfo.processName
    }

    /// App 版本号（形如 `1.2.3`）
    public static var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "未知"
    }

    /// App 构建号（形如 `42`）
    public static var appBuildNumber: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "未知"
    }

    // MARK: - 网络信息

    /// 本机局域网 IP 地址（如 `192.168.1.8`；未接入网络时返回 `nil`）
    public static var localIPAddress: String? {
        activeNetworkInterface()?.ip
    }

    /// 是否接入网络（存在非回环的 IPv4 地址即为已接入）
    public static var isNetworkConnected: Bool {
        activeNetworkInterface() != nil
    }

    /// 网络类型（近似判断）
    ///
    /// iOS 上可区分「蜂窝网络」；`en` 开头接口近似视为「Wi-Fi」，其余为「其他」。
    public static var networkType: String? {
        guard let name = activeNetworkInterface()?.name else { return nil }
        if name.hasPrefix("pdp") { return "蜂窝网络" }
        if name.hasPrefix("en") { return "Wi-Fi" }
        return "其他"
    }

    /// Wi-Fi 信号强度（RSSI，单位 dBm，通常为负值；仅 macOS，iOS 返回 `nil`）
    ///
    /// 通过 CoreWLAN 读取当前默认 Wi-Fi 接口的接收信号强度。数值越接近 0 信号越好。
    public static var wifiSignalStrength: Int? {
        #if os(macOS)
        return CWWiFiClient.shared().interface()?.rssiValue()
        #else
        return nil
        #endif
    }

    /// Wi-Fi 信号强度中文名（「强」「中」「弱」；非 macOS 或读取失败返回「不支持」）
    public static var wifiSignalStrengthName: String {
        guard let rssi = wifiSignalStrength else { return "不支持" }
        if rssi >= -50 { return "强" }
        if rssi >= -70 { return "中" }
        return "弱"
    }

    // MARK: - 本地化信息

    /// 当前语言代码（形如 `zh` / `en`）
    public static var languageCode: String {
        if #available(iOS 16.0, macOS 13.0, *) {
            return Locale.current.language.languageCode?.identifier ?? "未知"
        } else {
            return Locale.current.languageCode ?? "未知"
        }
    }

    /// 当前区域代码（形如 `CN` / `US`）
    public static var regionCode: String {
        if #available(iOS 16.0, macOS 13.0, *) {
            return Locale.current.region?.identifier ?? "未知"
        } else {
            return Locale.current.regionCode ?? "未知"
        }
    }

    /// 完整地区标识（形如 `zh_CN`）
    public static var localeIdentifier: String {
        Locale.current.identifier
    }

    /// 当前时区标识（形如 `Asia/Shanghai`）
    public static var timeZoneIdentifier: String {
        TimeZone.current.identifier
    }

    /// 当前日历标识（形如 `gregorian`）
    public static var calendarIdentifier: String {
        String(describing: Calendar.current.identifier)
    }

    // MARK: - 资源占用

    /// CPU 使用率（`0.0` ~ `1.0`）
    ///
    /// 通过两次采样（间隔约 100ms）计算瞬时占用，每次调用会短暂阻塞约 100ms。
    public static var cpuUsage: Double {
        guard let s1 = sampleCPUTicks() else { return 0 }
        Thread.sleep(forTimeInterval: 0.1)
        guard let s2 = sampleCPUTicks() else { return 0 }
        let dUser = s2.user &- s1.user
        let dSystem = s2.system &- s1.system
        let dIdle = s2.idle &- s1.idle
        let dNice = s2.nice &- s1.nice
        let total = dUser &+ dSystem &+ dIdle &+ dNice
        guard total > 0 else { return 0 }
        let busy = dUser &+ dSystem &+ dNice
        return Double(busy) / Double(total)
    }

    /// 内存已用容量（字节）
    public static var memoryUsedBytes: UInt64 {
        memoryStats()?.usedBytes ?? 0
    }

    /// 内存已用容量（人类可读，形如 `8 GB`）
    public static var memoryUsed: String {
        ByteCountFormatter.string(fromByteCount: Int64(memoryUsedBytes), countStyle: .memory)
    }

    /// 内存使用率（`0.0` ~ `1.0`）
    public static var memoryUsagePercent: Double {
        memoryStats()?.percent ?? 0
    }

    /// 当前进程 CPU 使用率（相对单核，多线程可超过 `1.0`）
    ///
    /// 通过两次采样（间隔约 100ms）计算本进程消耗的 CPU 时间占比，每次调用会短暂阻塞约 100ms。
    public static var processCPUUsage: Double {
        guard let t1 = processCPUTicks() else { return 0 }
        let start = Date()
        Thread.sleep(forTimeInterval: 0.1)
        guard let t2 = processCPUTicks() else { return 0 }
        let wall = max(Date().timeIntervalSince(start), 0.001)
        let used = Double((t2.user &- t1.user) &+ (t2.system &- t1.system)) / 1_000_000_000
        return used / wall
    }

    /// 当前进程内存占用（物理足迹，字节）
    ///
    /// macOS 上即 Activity Monitor 的「物理足迹」口径；iOS 同样通过 mach `task_info` 读取。
    public static var processMemoryBytes: UInt64 {
        processMemoryFootprint()
    }

    /// 当前进程内存占用（人类可读，形如 `120 MB`）
    public static var processMemory: String {
        ByteCountFormatter.string(fromByteCount: Int64(processMemoryBytes), countStyle: .memory)
    }

    /// 当前内存压力（仅 macOS；iOS 返回 `nil`）
    ///
    /// - Important: 内存压力源只在压力*变化*时回调，健康系统「正常」态没有事件，
    ///   因此一次性读取在 macOS 上通常无法确定当前值、返回 `nil`（对应「不支持」）。
    ///   需要实时压力请改用 `MemoryPressureMonitor` 长期监听。
    public static var memoryPressure: DispatchSource.MemoryPressureEvent? {
        #if os(macOS)
        return currentMemoryPressureEvent()
        #else
        return nil
        #endif
    }

    /// 内存压力中文名（「正常」「警告」「严重」；无法确定或非 macOS 时返回「不支持」）
    ///
    /// - Important: macOS 上一次性读取通常返回「不支持」（见 `memoryPressure` 说明）；
    ///   要拿真实当前值请用 `MemoryPressureMonitor`。
    public static var memoryPressureName: String {
        guard let pressure = memoryPressure else { return "不支持" }
        if pressure.contains(.critical) { return "严重" }
        if pressure.contains(.warning) { return "警告" }
        return "正常"
    }

    /// 当前进程可用内存（字节）
    ///
    /// iOS 通过 `os_proc_available_memory()` 读取（iOS 13+，macOS 无此 API）；
    /// macOS 通过 mach 采样计算（free + inactive + purgeable + speculative）。
    /// 无法获取时返回 `nil`。
    public static var availableMemoryBytes: UInt64? {
        #if os(iOS)
        let available = os_proc_available_memory()
        return available < 0 ? nil : UInt64(available)
        #else
        return memoryStats()?.availableBytes
        #endif
    }

    /// 当前进程可用内存（人类可读，形如 `2.1 GB`；无法获取时返回「未知」）
    public static var availableMemory: String {
        guard let bytes = availableMemoryBytes else { return "未知" }
        return ByteCountFormatter.string(fromByteCount: Int64(bytes), countStyle: .memory)
    }

    // MARK: - 内部工具

    private static func sysctlString(_ name: String) -> String? {
        var size = 0
        sysctlbyname(name, nil, &size, nil, 0)
        guard size > 0 else { return nil }
        var result = [CChar](repeating: 0, count: size)
        sysctlbyname(name, &result, &size, nil, 0)
        return String(cString: result)
    }

    private static func fileSystemAttribute(_ key: FileAttributeKey) -> UInt64? {
        let attrs = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory())
        return (attrs?[key] as? NSNumber)?.uint64Value
    }

    /// 读取主目录所在卷的 URL 资源值（容量 / 卷名 / 文件系统类型）
    private static func homeVolumeValues() -> URLResourceValues? {
        try? URL(fileURLWithPath: NSHomeDirectory()).resourceValues(forKeys: [
            .volumeAvailableCapacityForImportantUsageKey,
            .volumeAvailableCapacityForOpportunisticUsageKey,
            .volumeNameKey,
            .volumeLocalizedFormatDescriptionKey
        ])
    }

    /// 枚举网络接口，返回活跃接口的名称与 IPv4 地址（Wi-Fi 优先）
    private static func activeNetworkInterface() -> (name: String, ip: String)? {
        var ifaddrPtr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddrPtr) == 0, let first = ifaddrPtr else { return nil }
        defer { freeifaddrs(first) }

        var fallback: (name: String, ip: String)?
        var current: UnsafeMutablePointer<ifaddrs>? = first
        while let ifa = current {
            defer { current = ifa.pointee.ifa_next }
            let flags = Int32(ifa.pointee.ifa_flags)
            guard (flags & IFF_UP) == IFF_UP, (flags & IFF_LOOPBACK) == 0 else { continue }
            guard let addr = ifa.pointee.ifa_addr, addr.pointee.sa_family == UInt8(AF_INET) else { continue }

            var host = [CChar](repeating: 0, count: Int(NI_MAXHOST))
            let r = getnameinfo(addr, socklen_t(addr.pointee.sa_len), &host, socklen_t(host.count), nil, 0, NI_NUMERICHOST)
            guard r == 0 else { continue }
            let ip = String(cString: host)
            let name = String(cString: ifa.pointee.ifa_name)

            if name == "en0" { return (name, ip) }          // Wi-Fi 优先
            if name.hasPrefix("pdp") { return (name, ip) }  // 蜂窝网络
            if fallback == nil { fallback = (name, ip) }
        }
        return fallback
    }

    /// 采样一次全 CPU 的 tick（USER / SYSTEM / IDLE / NICE 各自累加）
    private static func sampleCPUTicks() -> (user: UInt32, system: UInt32, idle: UInt32, nice: UInt32)? {
        var cpuInfo: processor_info_array_t?
        var numCpuInfo: mach_msg_type_number_t = 0
        var numCPUs: natural_t = 0
        let result = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numCPUs, &cpuInfo, &numCpuInfo)
        guard result == KERN_SUCCESS, let info = cpuInfo, numCPUs > 0 else { return nil }
        defer {
            vm_deallocate(mach_task_self_, vm_address_t(bitPattern: info),
                          vm_size_t(numCpuInfo) * vm_size_t(MemoryLayout<integer_t>.size))
        }
        // PROCESSOR_CPU_LOAD_INFO：每个 CPU 依次是 USER(0) SYSTEM(1) IDLE(2) NICE(3) 四个 tick
        let perCPU = 4
        var user: UInt32 = 0, system: UInt32 = 0, idle: UInt32 = 0, nice: UInt32 = 0
        for i in 0..<Int(numCPUs) {
            user   &+= UInt32(bitPattern: info[i * perCPU + 0])
            system &+= UInt32(bitPattern: info[i * perCPU + 1])
            idle   &+= UInt32(bitPattern: info[i * perCPU + 2])
            nice   &+= UInt32(bitPattern: info[i * perCPU + 3])
        }
        return (user, system, idle, nice)
    }

    /// 读取内存统计（`host_statistics64`），返回已用字节、使用率、可用字节
    private static func memoryStats() -> (usedBytes: UInt64, percent: Double, availableBytes: UInt64)? {
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.stride / MemoryLayout<integer_t>.stride)
        let result = withUnsafeMutablePointer(to: &stats) { ptr in
            ptr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { rebound in
                host_statistics64(mach_host_self(), HOST_VM_INFO64, rebound, &count)
            }
        }
        guard result == KERN_SUCCESS else { return nil }
        let pageSize = UInt64(getpagesize())
        let total = ProcessInfo.processInfo.physicalMemory
        guard total > 0 else { return nil }
        let free = UInt64(stats.free_count) * pageSize
        let inactive = UInt64(stats.inactive_count) * pageSize
        let purgeable = UInt64(stats.purgeable_count) * pageSize
        let speculative = UInt64(stats.speculative_count) * pageSize
        let available = free + inactive + purgeable + speculative
        let used = total > available ? total - available : 0
        return (used, Double(used) / Double(total), available)
    }

    /// 采样一次本进程的 CPU 时间（用户态 + 内核态，单位纳秒）
    private static func processCPUTicks() -> (user: UInt64, system: UInt64)? {
        var info = task_thread_times_info()
        var count = mach_msg_type_number_t(MemoryLayout<task_thread_times_info>.size / MemoryLayout<natural_t>.size)
        let result = withUnsafeMutablePointer(to: &info) { ptr in
            ptr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { rebound in
                task_info(mach_task_self_, task_flavor_t(TASK_THREAD_TIMES_INFO), rebound, &count)
            }
        }
        guard result == KERN_SUCCESS else { return nil }
        let user = UInt64(max(0, Int(info.user_time.seconds))) &* 1_000_000_000 &+ UInt64(max(0, Int(info.user_time.microseconds))) &* 1000
        let system = UInt64(max(0, Int(info.system_time.seconds))) &* 1_000_000_000 &+ UInt64(max(0, Int(info.system_time.microseconds))) &* 1000
        return (user, system)
    }

    /// 读取当前进程的物理内存足迹（mach `task_info` + `phys_footprint`）
    private static func processMemoryFootprint() -> UInt64 {
        var info = mach_task_vm_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_vm_info>.size / MemoryLayout<natural_t>.size)
        let result = withUnsafeMutablePointer(to: &info) { ptr in
            ptr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { rebound in
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_VM_INFO), rebound, &count)
            }
        }
        guard result == KERN_SUCCESS else { return 0 }
        return info.phys_footprint
    }

    private static let bootTimeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return f
    }()

    #if os(macOS)
    /// 同步读取系统当前内存压力级别（内部工具）
    ///
    /// `DispatchSource` 需 `resume()` 后由事件回调上报当前值，故用信号量等待首次回调，
    /// 拿到当前压力后立即取消；超时（约 0.5 秒）未回调时返回 `nil`（表示无法确定，避免误报「正常」）。
    static func currentMemoryPressureEvent() -> DispatchSource.MemoryPressureEvent? {
        let source = DispatchSource.makeMemoryPressureSource(eventMask: .all, queue: nil)
        let semaphore = DispatchSemaphore(value: 0)
        var event: DispatchSource.MemoryPressureEvent?
        source.setEventHandler {
            event = source.data
            semaphore.signal()
        }
        source.resume()
        let result = semaphore.wait(timeout: .now() + 0.5)
        source.cancel()
        return result == .success ? event : nil
    }

    /// 读取 Mac 内置电池的电源信息（IOKit）
    private static func macBatteryDescription() -> [String: Any]? {
        guard let info = IOPSCopyPowerSourcesInfo()?.takeRetainedValue() else { return nil }
        guard let sources = IOPSCopyPowerSourcesList(info)?.takeRetainedValue() as? [CFTypeRef] else { return nil }
        for source in sources {
            guard let desc = IOPSGetPowerSourceDescription(info, source)?.takeUnretainedValue() as? [String: Any] else { continue }
            if (desc[kIOPSTypeKey as String] as? String) == (kIOPSInternalBatteryType as String) {
                return desc
            }
        }
        return nil
    }
    #endif
}
