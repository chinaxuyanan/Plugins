import Foundation
import Dispatch
import Darwin
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif
#if os(macOS)
import IOKit.ps
#endif

/// SystemInfoKit —— 中文友好的系统检测工具库
///
/// 解决「查系统信息要记各种零散 API」的痛点：
/// - 把系统版本、设备型号、硬件信息、屏幕、电池等常用检测项集中封装；
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
    public static let version = "0.4.0"

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

    /// 当前内存压力（仅 macOS 支持；iOS 返回 `nil`）
    ///
    /// 通过 Dispatch 内存压力源读取系统当前的内存压力级别（正常 / 警告 / 严重）。
    public static var memoryPressure: DispatchSource.MemoryPressureEvent? {
        #if os(macOS)
        let source = DispatchSource.makeMemoryPressureSource(eventMask: .all, queue: nil)
        let event = source.data
        source.cancel()
        return event
        #else
        return nil
        #endif
    }

    /// 内存压力中文名（「正常」「警告」「严重」；不支持时返回「不支持」）
    public static var memoryPressureName: String {
        guard let pressure = memoryPressure else { return "不支持" }
        if pressure.contains(.critical) { return "严重" }
        if pressure.contains(.warning) { return "警告" }
        return "正常"
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

    /// 读取内存统计（`host_statistics64`），返回已用字节与使用率
    private static func memoryStats() -> (usedBytes: UInt64, percent: Double)? {
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
        return (used, Double(used) / Double(total))
    }

    #if os(macOS)
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
