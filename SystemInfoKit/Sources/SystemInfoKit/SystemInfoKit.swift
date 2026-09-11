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
#if canImport(Metal)
import Metal
#endif
#if os(macOS)
import IOKit
import IOKit.ps
import CoreWLAN
#endif
#if canImport(CFNetwork)
import CFNetwork
#endif

/// SystemInfoKit —— 中文友好的系统检测工具库
///
/// 解决「查系统信息要记各种零散 API」的痛点：
/// - 把系统版本、设备型号、硬件、电池、热状态、屏幕、网络、本地化、资源占用、存储详情等常用检测项集中封装；
/// - 提供设备友好型号名 `deviceModelName`（标识符对照表可自行增补）、深色模式 `isDarkMode`、屏幕亮度 `screenBrightness`、信息快照 `snapshot()`；
/// - 支持屏幕最大刷新率 `maximumFramesPerSecond`、无障碍设置（`isReduceMotionEnabled` / `isReduceTransparencyEnabled` / `isBoldTextEnabled`）、已挂载存储卷列表 `mountedVolumes`（`MountedVolume`）、签名信息（`bundleIdentifier` / `teamIdentifier` / `isTestFlight`）、代理检测（`isUsingProxy` / `proxyDescription`）；
/// - 支持电池细分状态 `batteryState`（充电中 / 已充满 / 未接电源 / 未知）、网络接口物理地址 `networkInterfaces[].macAddress`、进程占用排行 `topProcesses(by:limit:)`（按内存或 CPU）；
/// - 支持内存明细 `memoryBreakdown`（`MemoryBreakdown`：活跃 / 非活跃 / 联动 / 压缩 / 可丢弃 / 预读）、每核 CPU 占用 `perCoreCPUUsage`、已安装应用列表 `installedApplications`（`InstalledApplication`，仅 macOS）、电池温度 `batteryTemperature` 与电源适配器明细 `powerAdapter`（`PowerAdapter`）；
/// - 支持显卡信息 `gpuInfo`（`GPUInfo`：名称 / 最大工作内存 / 统一内存 / 单线程组最大线程数）、USB 外设列表 `usbDevices`（`USBDevice`，仅 macOS）、风扇转速 `fanSpeeds`（`FanSpeed`）与整机温度 `machineTemperature`（仅 macOS）、电池剩余时间 `batteryTimeRemaining` / 充满剩余时间 `batteryTimeToFullCharge`；
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
    public static let version = "1.5.0"

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

    /// 设备标识符 → 友好型号名对照表
    ///
    /// 内置常见 iPhone / iPad / Apple Silicon Mac 型号；标识符未收录时 `deviceModelName(for:)`
    /// 会原样返回标识符。新机型发布后可直接向本表增补：
    ///
    /// ```swift
    /// SystemInfoKit.deviceModelTable["iPhone18,1"] = "iPhone 17 Pro"
    /// ```
    public static var deviceModelTable: [String: String] = [
        // iPhone
        "iPhone12,1": "iPhone 11",
        "iPhone12,3": "iPhone 11 Pro",
        "iPhone12,5": "iPhone 11 Pro Max",
        "iPhone12,8": "iPhone SE（第二代）",
        "iPhone13,1": "iPhone 12 mini",
        "iPhone13,2": "iPhone 12",
        "iPhone13,3": "iPhone 12 Pro",
        "iPhone13,4": "iPhone 12 Pro Max",
        "iPhone14,2": "iPhone 13 Pro",
        "iPhone14,3": "iPhone 13 Pro Max",
        "iPhone14,4": "iPhone 13 mini",
        "iPhone14,5": "iPhone 13",
        "iPhone14,6": "iPhone SE（第三代）",
        "iPhone14,7": "iPhone 14",
        "iPhone14,8": "iPhone 14 Plus",
        "iPhone15,2": "iPhone 14 Pro",
        "iPhone15,3": "iPhone 14 Pro Max",
        "iPhone15,4": "iPhone 15",
        "iPhone15,5": "iPhone 15 Plus",
        "iPhone16,1": "iPhone 15 Pro",
        "iPhone16,2": "iPhone 15 Pro Max",
        "iPhone17,1": "iPhone 16 Pro",
        "iPhone17,2": "iPhone 16 Pro Max",
        "iPhone17,3": "iPhone 16",
        "iPhone17,4": "iPhone 16 Plus",
        "iPhone17,5": "iPhone 16e",
        // iPad
        "iPad12,1": "iPad（第九代）",
        "iPad12,2": "iPad（第九代）",
        "iPad13,1": "iPad Air（第四代）",
        "iPad13,2": "iPad Air（第四代）",
        "iPad13,18": "iPad（第十代）",
        "iPad13,19": "iPad（第十代）",
        "iPad14,1": "iPad mini（第六代）",
        "iPad14,2": "iPad mini（第六代）",
        "iPad13,4": "iPad Pro 11 英寸（第三代）",
        "iPad13,5": "iPad Pro 11 英寸（第三代）",
        "iPad13,6": "iPad Pro 11 英寸（第三代）",
        "iPad13,7": "iPad Pro 11 英寸（第三代）",
        "iPad13,8": "iPad Pro 12.9 英寸（第五代）",
        "iPad13,9": "iPad Pro 12.9 英寸（第五代）",
        "iPad13,10": "iPad Pro 12.9 英寸（第五代）",
        "iPad13,11": "iPad Pro 12.9 英寸（第五代）",
        // Apple Silicon Mac
        "MacBookAir10,1": "MacBook Air（M1, 2020）",
        "MacBookPro17,1": "MacBook Pro 13 英寸（M1, 2020）",
        "MacBookPro18,1": "MacBook Pro 16 英寸（2021）",
        "MacBookPro18,2": "MacBook Pro 16 英寸（2021）",
        "MacBookPro18,3": "MacBook Pro 14 英寸（2021）",
        "MacBookPro18,4": "MacBook Pro 14 英寸（2021）",
        "Macmini9,1": "Mac mini（M1, 2020）",
        "iMac21,1": "iMac 24 英寸（M1, 2021）",
        "iMac21,2": "iMac 24 英寸（M1, 2021）",
        "Mac13,1": "Mac Studio（2022）",
        "Mac13,2": "Mac Studio（2022）",
        "Mac14,2": "MacBook Air（M2, 2022）",
        "Mac14,7": "MacBook Pro 13 英寸（M2, 2022）",
        "Mac14,3": "Mac mini（M2, 2023）",
        "Mac14,12": "Mac mini（M2 Pro, 2023）",
        "Mac14,5": "MacBook Pro 14 英寸（2023）",
        "Mac14,6": "MacBook Pro 16 英寸（2023）",
        "Mac14,9": "MacBook Pro 14 英寸（2023）",
        "Mac14,10": "MacBook Pro 16 英寸（2023）",
        "Mac14,13": "Mac Studio（2023）",
        "Mac14,14": "Mac Studio（2023）",
        "Mac14,15": "MacBook Air 15 英寸（M2, 2023）",
        "Mac15,3": "MacBook Pro 14 英寸（M3, 2023）",
        "Mac15,4": "iMac 24 英寸（M3, 2023）",
        "Mac15,5": "iMac 24 英寸（M3, 2023）",
        "Mac15,6": "MacBook Pro 14 英寸（M3 Pro, 2023）",
        "Mac15,7": "MacBook Pro 16 英寸（M3 Pro, 2023）",
        "Mac15,8": "MacBook Pro 14 英寸（M3 Max, 2023）",
        "Mac15,9": "MacBook Pro 16 英寸（M3 Max, 2023）",
        "Mac15,10": "MacBook Pro 16 英寸（M3 Max, 2023）",
        "Mac15,12": "MacBook Air 13 英寸（M3, 2024）",
        "Mac15,13": "MacBook Air 15 英寸（M3, 2024）",
        "Mac16,1": "MacBook Pro 14 英寸（M4, 2024）",
        "Mac16,12": "MacBook Air 13 英寸（M4, 2025）",
        "Mac16,13": "MacBook Air 15 英寸（M4, 2025）",
    ]

    /// 把设备标识符转成友好型号名；未收录时原样返回标识符
    ///
    /// - Parameter identifier: 设备标识符（如 `iPhone15,4` / `MacBookPro18,1`）
    /// - Returns: 友好型号名（如 `iPhone 15` / `MacBook Pro 16 英寸（2021）`）
    ///
    /// - Example:
    ///   ```swift
    ///   SystemInfoKit.deviceModelName(for: "iPhone15,4")   // "iPhone 15"
    ///   ```
    public static func deviceModelName(for identifier: String) -> String {
        deviceModelTable[identifier] ?? identifier
    }

    /// 当前设备的友好型号名（形如 `iPhone 15 Pro` / `MacBook Pro 14 英寸（2021）`）
    ///
    /// 即 `deviceModelName(for: deviceIdentifier)`；标识符未收录时返回原始标识符，
    /// 可自行向 `deviceModelTable` 增补新机型。
    public static var deviceModelName: String {
        deviceModelName(for: deviceIdentifier)
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

    // MARK: - 显卡（GPU）

    /// 显卡信息（系统默认 Metal 设备）
    ///
    /// 用 `MTLCreateSystemDefaultDevice()` 取系统默认 GPU 的名称 / 建议最大工作集内存 /
    /// 是否统一内存 / 单线程组最大线程数。取不到（如模拟器、无 Metal 设备）返回 `nil`。
    /// 多显卡机型只给出系统默认设备这一块。
    ///
    /// - Example:
    ///   ```swift
    ///   if let 显卡 = SystemInfoKit.gpuInfo {
    ///       print(显卡.text)      // Apple M1 Pro · 统一内存 · 5461 MB
    ///   }
    ///   ```
    public static var gpuInfo: GPUInfo? {
        #if canImport(Metal)
        guard let device = MTLCreateSystemDefaultDevice() else { return nil }
        return GPUInfo(name: device.name,
                       maxWorkingMemoryBytes: UInt64(device.recommendedMaxWorkingSetSize),
                       hasUnifiedMemory: device.hasUnifiedMemory,
                       maxThreadsPerThreadgroup: device.maxThreadsPerThreadgroup.width)
        #else
        return nil
        #endif
    }

    /// 显卡名称（形如 `Apple M1 Pro`；取不到返回 `nil`）
    public static var gpuName: String? {
        gpuInfo?.name
    }

    /// 显卡信息文本（形如 `Apple M1 Pro · 统一内存 · 5461 MB`；取不到返回「不支持」）
    public static var gpuInfoText: String {
        gpuInfo?.text ?? "不支持"
    }

    // MARK: - USB 外设

    /// 已连接的 USB 外设列表（macOS；iOS 恒为空数组）
    ///
    /// 枚举 IOKit 注册表里的 USB 设备节点（新系统用 `IOUSBHostDevice`，读不到再回退 `IOUSBDevice`），
    /// 读取产品名 / 厂商名 / 厂商 ID / 产品 ID / 序列号，读不到的字段为 `nil`。
    /// **集线器、内建键盘 / 触控板等也会出现在列表里**，要区分可自行按名称或 ID 过滤。
    ///
    /// - Note: 本属性会遍历 IOKit 注册表，开销比一般属性大，建议按需调用，不要放进高频刷新循环。
    ///
    /// - Example:
    ///   ```swift
    ///   for 设备 in SystemInfoKit.usbDevices {
    ///       print(设备.text)      // 键盘 · Apple Inc. (05AC:0250)
    ///   }
    ///   ```
    public static var usbDevices: [USBDevice] {
        #if os(macOS)
        return rawUSBDevices()
        #else
        return []
        #endif
    }

    /// 已连接的 USB 外设数量（等同于 `usbDevices.count`）
    public static var usbDeviceCount: Int {
        usbDevices.count
    }

    /// USB 外设列表的单行文本（每台设备以 ` · ` 连接；无设备返回「无 USB 外设」）
    public static var usbDevicesText: String {
        let devices = usbDevices
        guard !devices.isEmpty else { return "无 USB 外设" }
        return devices.map(\.text).joined(separator: " · ")
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

    /// 电池循环次数（仅 macOS，通过 IOKit `AppleSmartBattery` 读取；iOS 返回 `nil`）
    public static var batteryCycleCount: Int? {
        #if os(macOS)
        return smartBatteryNumber("CycleCount") ?? smartBatteryNumber("Cycle Count")
        #else
        return nil
        #endif
    }

    /// 电池健康度（`0.0` ~ `1.0`，当前最大容量 / 设计容量；仅 macOS，读取不到返回 `nil`）
    public static var batteryHealthPercent: Double? {
        #if os(macOS)
        guard let max = smartBatteryNumber("AppleRawMaxCapacity") ?? smartBatteryNumber("MaxCapacity"),
              let design = smartBatteryNumber("DesignCapacity"), design > 0, max >= 0 else { return nil }
        return min(1.0, Double(max) / Double(design))
        #else
        return nil
        #endif
    }

    /// 电池健康度（人类可读，形如 `98%`；读取不到或非 macOS 返回「不支持」）
    public static var batteryHealth: String {
        guard let percent = batteryHealthPercent else { return "不支持" }
        return "\(Int(percent * 100))%"
    }

    /// 电池细分状态（充电中 / 已充满 / 未接电源 / 未知）
    ///
    /// 比 `isCharging` 更细：`isCharging` 把「充电中」和「已充满」都算作 `true`，
    /// 本属性区分两者，适合做电源状态展示。iOS 取 `UIDevice.batteryState`；
    /// macOS 在接通交流电后再看 `Is Charging` 标志。
    public static var batteryState: BatteryState {
        #if canImport(UIKit)
        UIDevice.current.isBatteryMonitoringEnabled = true
        switch UIDevice.current.batteryState {
        case .charging: return .charging
        case .full: return .full
        case .unplugged: return .unplugged
        case .unknown: return .unknown
        @unknown default: return .unknown
        }
        #elseif os(macOS)
        guard let desc = macBatteryDescription() else { return .unknown }
        guard let state = desc[kIOPSPowerSourceStateKey as String] as? String else { return .unknown }
        // 没接交流电就是未接电源
        guard state == (kIOPSACPowerValue as String) else { return .unplugged }
        // 接了交流电：仍在充电 → 充电中，否则视为已充满
        if let charging = desc[kIOPSIsChargingKey as String] as? Bool {
            return charging ? .charging : .full
        }
        return .full
        #else
        return .unknown
        #endif
    }

    /// 电池细分状态的中文名（等同 `batteryState.chineseName`）
    public static var batteryStateName: String {
        batteryState.chineseName
    }

    /// 电池温度（摄氏度；仅 macOS，读取不到或非 macOS 返回 `nil`）
    ///
    /// 读自 IOKit `AppleSmartBattery` 注册表的 `Temperature`（单位 1/100 ℃，先除以 100）。
    /// 该键在部分机型上缺失，此时回退读 `VirtualTemperature`；读数明显异常（超出 −20 ~ 120 ℃）时
    /// 视为无效返回 `nil`。
    ///
    /// - Important: 这是**电池电芯**的温度，不是 CPU / 环境温度（iOS 未开放该数据）。
    ///
    /// - Example:
    ///   ```swift
    ///   print(SystemInfoKit.batteryTemperatureText)   // 30.3 ℃
    ///   ```
    public static var batteryTemperature: Double? {
        #if os(macOS)
        guard let raw = smartBatteryNumber("Temperature") ?? smartBatteryNumber("VirtualTemperature"),
              raw != 0 else { return nil }
        let celsius = Double(raw) / 100
        guard celsius > -20, celsius < 120 else { return nil }
        return celsius
        #else
        return nil
        #endif
    }

    /// 电池温度文本（形如 `30.3 ℃`；读取不到或非 macOS 返回「不支持」）
    public static var batteryTemperatureText: String {
        guard let celsius = batteryTemperature else { return "不支持" }
        return String(format: "%.1f ℃", celsius)
    }

    /// 当前供电来源中文名（「交流电源」「电池」「未知」「不支持」）
    ///
    /// iOS 由 `UIDevice.batteryState` 推断；macOS 读 IOKit 电源描述里的「交流 / 电池」标志。
    /// 台式机（无内置电池）在 macOS 上返回「不支持」。
    public static var powerSourceName: String {
        #if canImport(UIKit)
        switch batteryState {
        case .charging, .full: return "交流电源"
        case .unplugged: return "电池"
        case .unknown: return "未知"
        }
        #elseif os(macOS)
        guard let desc = macBatteryDescription() else { return "不支持" }
        guard let state = desc[kIOPSPowerSourceStateKey as String] as? String else { return "未知" }
        return state == (kIOPSACPowerValue as String) ? "交流电源" : "电池"
        #else
        return "不支持"
        #endif
    }

    /// 电源适配器明细（仅 macOS；未接适配器或台式机无内置电池时返回 `nil`）
    ///
    /// 读自 IOKit 的 `IOPSCopyExternalPowerAdapterDetails()`，含功率 / 协商电压 / 协商电流 / 适配器标识。
    /// 用电池供电时该接口没有内容，返回 `nil`。
    ///
    /// - Example:
    ///   ```swift
    ///   print(SystemInfoKit.powerAdapterText)   // 适配器 96W · 20.0V · 4.80A
    ///   ```
    public static var powerAdapter: PowerAdapter? {
        #if os(macOS)
        guard let details = IOPSCopyExternalPowerAdapterDetails()?.takeRetainedValue() as? [String: Any] else {
            return nil
        }
        let watts = details[AdapterKey.watts] as? Int
        let voltage = details[AdapterKey.voltage] as? Int
        let current = details[AdapterKey.current] as? Int
        let adapterID = details[AdapterKey.adapterID] as? Int
        // 一个字段都没读到，视为拿不到适配器信息
        guard watts != nil || voltage != nil || current != nil || adapterID != nil else { return nil }
        return PowerAdapter(watts: watts,
                            voltageMillivolts: voltage,
                            currentMilliamps: current,
                            adapterID: adapterID)
        #else
        return nil
        #endif
    }

    /// 电源适配器明细文本（形如 `适配器 96W · 20.0V · 4.80A`；未接电源或非 macOS 返回「不支持」）
    public static var powerAdapterText: String {
        powerAdapter?.text ?? "不支持"
    }

    /// 电池剩余可用时间（秒；充电中 / 读取不到 / 非 macOS 返回 `nil`）
    ///
    /// macOS 读 IOKit 电源描述的 `Time to Empty`（分钟，`kIOPSTimeToEmptyKey`）。系统在估算中
    /// 或正在充电时会给 `-1`，这里把非正数一律当作「未知」返回 `nil`。iOS 未开放该数据，恒为 `nil`。
    ///
    /// - Example:
    ///   ```swift
    ///   print(SystemInfoKit.batteryTimeRemainingText)   // 1 小时 23 分
    ///   ```
    public static var batteryTimeRemaining: TimeInterval? {
        #if os(macOS)
        guard let desc = macBatteryDescription() else { return nil }
        return batterySeconds(fromMinutes: desc[kIOPSTimeToEmptyKey as String] as? Int)
        #else
        return nil
        #endif
    }

    /// 电池充满还需时间（秒；未在充电 / 读取不到 / 非 macOS 返回 `nil`）
    ///
    /// macOS 读 IOKit 电源描述的 `Time to Full Charge`（分钟，`kIOPSTimeToFullChargeKey`）。
    /// 未接电源时该值同样给 `-1`（未知）→ 返回 `nil`。iOS 恒为 `nil`。
    public static var batteryTimeToFullCharge: TimeInterval? {
        #if os(macOS)
        guard let desc = macBatteryDescription() else { return nil }
        return batterySeconds(fromMinutes: desc[kIOPSTimeToFullChargeKey as String] as? Int)
        #else
        return nil
        #endif
    }

    /// 电池剩余时间文本（形如 `1 小时 23 分`；读取不到返回「不支持」）
    public static var batteryTimeRemainingText: String {
        batteryTimeText(batteryTimeRemaining)
    }

    /// 电池充满还需时间文本（形如 `45 分`；读取不到返回「不支持」）
    public static var batteryTimeToFullChargeText: String {
        batteryTimeText(batteryTimeToFullCharge)
    }

    /// 把秒数格式化成中文时长文本（纯逻辑，便于测试）
    ///
    /// `nil` 或负数 → 「不支持」；不足 1 小时只给分钟（形如 `45 分`）；
    /// 满 1 小时给「X 小时 Y 分」（分钟不足两位也照写，如 `1 小时 5 分`）。
    ///
    /// - Parameter seconds: 秒数（`nil` 表示未知）
    public static func batteryTimeText(_ seconds: TimeInterval?) -> String {
        guard let seconds, seconds >= 0 else { return "不支持" }
        let totalMinutes = Int(seconds / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60
        return hours > 0 ? "\(hours) 小时 \(minutes) 分" : "\(minutes) 分"
    }

    /// 内部：把 IOKit 的分钟读数转成秒（`-1` 等非正数表示未知 → `nil`）
    static func batterySeconds(fromMinutes minutes: Int?) -> TimeInterval? {
        guard let minutes, minutes > 0 else { return nil }
        return TimeInterval(minutes) * 60
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

    /// 当前是否处于深色模式
    ///
    /// macOS：优先读 App 的 `effectiveAppearance`，非 AppKit 上下文（命令行工具）回退读
    /// 系统偏好 `AppleInterfaceStyle`；iOS：读当前 `UITraitCollection`。
    ///
    /// - Note: iOS 上必须在主线程读取；后台线程读到的可能是 `.unspecified`（按浅色处理）。
    public static var isDarkMode: Bool {
        #if canImport(UIKit)
        return UITraitCollection.current.userInterfaceStyle == .dark
        #elseif canImport(AppKit)
        if let appearance = NSApp?.effectiveAppearance {
            return appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        }
        return UserDefaults.standard.string(forKey: "AppleInterfaceStyle") == "Dark"
        #else
        return false
        #endif
    }

    /// 屏幕亮度（`0.0` ~ `1.0`）
    ///
    /// iOS 读 `UIScreen.main.brightness`（只反映当前屏幕的设置值）；macOS 经 IOKit
    /// `IODisplayConnect` 读取内建屏亮度。取不到时返回 `nil`（如无内建屏的外接显示器主机、
    /// 或不支持该接口的平台）。
    public static var screenBrightness: Double? {
        #if canImport(UIKit)
        return Double(UIScreen.main.brightness)
        #elseif os(macOS)
        return displayBrightness()
        #else
        return nil
        #endif
    }

    #if os(macOS)
    /// 经 IOKit 读取内建显示器亮度（`0.0` ~ `1.0`）
    private static func displayBrightness() -> Double? {
        let service = IOServiceGetMatchingService(kIOMainPortDefault,
                                                  IOServiceMatching("IODisplayConnect"))
        guard service != 0 else { return nil }
        defer { IOObjectRelease(service) }
        var brightness: Float = 0
        let result = IODisplayGetFloatParameter(service, 0, kIODisplayBrightnessKey as CFString, &brightness)
        guard result == kIOReturnSuccess else { return nil }
        return Double(brightness)
    }
    #endif

    // MARK: - 刷新率与无障碍

    /// 屏幕支持的最大刷新率（Hz，如 `60` / `120`）
    ///
    /// iOS 取 `UIScreen`（ProMotion 机型为 `120`）；macOS 取主屏的
    /// `maximumFramesPerSecond`（macOS 12+，取不到时回退 `60`）。
    /// 适合据此决定是否启用高帧率动画 / 减少不必要的重绘。
    ///
    /// - Example:
    ///   ```swift
    ///   if SystemInfoKit.maximumFramesPerSecond >= 120 {
    ///       // 高刷屏，可放心使用更细腻的动画
    ///   }
    ///   ```
    public static var maximumFramesPerSecond: Int {
        #if canImport(UIKit)
        return UIScreen.main.maximumFramesPerSecond
        #elseif canImport(AppKit)
        return NSScreen.main?.maximumFramesPerSecond ?? 60
        #else
        return 60
        #endif
    }

    /// 是否开启「减弱动态效果」
    ///
    /// iOS 读 `UIAccessibility.isReduceMotionEnabled`，macOS 读
    /// `NSWorkspace.shared.accessibilityDisplayShouldReduceMotion`。开启后应避免大幅位移 /
    /// 缩放动画，改用淡入淡出等更温和的过渡。
    public static var isReduceMotionEnabled: Bool {
        #if canImport(UIKit)
        return UIAccessibility.isReduceMotionEnabled
        #elseif canImport(AppKit)
        return NSWorkspace.shared.accessibilityDisplayShouldReduceMotion
        #else
        return false
        #endif
    }

    /// 是否开启「降低透明度」
    ///
    /// iOS 读 `UIAccessibility.isReduceTransparencyEnabled`，macOS 读
    /// `NSWorkspace.shared.accessibilityDisplayShouldReduceTransparency`。开启后毛玻璃
    /// 材质会被替换成不透明背景，自绘的半透明遮罩建议同步改为实色。
    public static var isReduceTransparencyEnabled: Bool {
        #if canImport(UIKit)
        return UIAccessibility.isReduceTransparencyEnabled
        #elseif canImport(AppKit)
        return NSWorkspace.shared.accessibilityDisplayShouldReduceTransparency
        #else
        return false
        #endif
    }

    /// 是否开启「粗体文本」（仅 iOS）
    ///
    /// iOS 读 `UIAccessibility.isBoldTextEnabled`；macOS 系统未提供对应的全局设置开关，
    /// 固定返回 `false`。
    public static var isBoldTextEnabled: Bool {
        #if canImport(UIKit)
        return UIAccessibility.isBoldTextEnabled
        #else
        return false
        #endif
    }

    /// 无障碍设置摘要（形如 `减弱动态效果 · 降低透明度`，都没开启时返回 `无`）
    ///
    /// 便于一次性打日志 / 上报，判断用户是否开了影响 UI 表现的辅助功能。
    public static var accessibilitySummary: String {
        var enabled: [String] = []
        if isReduceMotionEnabled { enabled.append("减弱动态效果") }
        if isReduceTransparencyEnabled { enabled.append("降低透明度") }
        if isBoldTextEnabled { enabled.append("粗体文本") }
        return enabled.isEmpty ? "无" : enabled.joined(separator: " · ")
    }

    // MARK: - 存储卷

    /// 当前已挂载的存储卷列表（按卷名排序）
    ///
    /// 通过 `FileManager.mountedVolumeURLs` 枚举，跳过隐藏卷（如系统恢复分区）。
    /// 每个卷含名称、路径、总容量、可用容量、是否可移除（U 盘 / 存储卡）、是否内置磁盘。
    ///
    /// - Note: iOS 上一般只返回数据卷本身；macOS 上会列出所有可见挂载点。
    ///
    /// - Example:
    ///   ```swift
    ///   for 卷 in SystemInfoKit.mountedVolumes {
    ///       print("\(卷.name)：剩余 \(卷.freeDescription) / \(卷.totalDescription)")
    ///   }
    ///   ```
    public static var mountedVolumes: [MountedVolume] {
        let keys: [URLResourceKey] = [.volumeNameKey,
                                      .volumeTotalCapacityKey,
                                      .volumeAvailableCapacityKey,
                                      .volumeIsRemovableKey,
                                      .volumeIsInternalKey]
        let keySet = Set(keys)
        guard let urls = FileManager.default.mountedVolumeURLs(includingResourceValuesForKeys: keys,
                                                              options: [.skipHiddenVolumes]) else {
            return []
        }
        let volumes: [MountedVolume] = urls.compactMap { url in
            guard let values = try? url.resourceValues(forKeys: keySet) else { return nil }
            return MountedVolume(name: values.volumeName ?? url.lastPathComponent,
                                 url: url,
                                 totalBytes: Int64(values.volumeTotalCapacity ?? 0),
                                 freeBytes: Int64(values.volumeAvailableCapacity ?? 0),
                                 isRemovable: values.volumeIsRemovable ?? false,
                                 isInternal: values.volumeIsInternal ?? false)
        }
        return volumes.sorted { $0.name < $1.name }
    }

    /// 已挂载存储卷数量（等同 `mountedVolumes.count`）
    public static var mountedVolumeCount: Int {
        mountedVolumes.count
    }

    /// 可移除存储卷列表（U 盘 / 存储卡 / 外接盘）
    public static var removableVolumes: [MountedVolume] {
        mountedVolumes.filter { $0.isRemovable }
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

    /// App 包标识符（形如 `com.example.app`）
    public static var bundleIdentifier: String {
        Bundle.main.bundleIdentifier ?? "未知"
    }

    /// 是否通过 TestFlight 安装
    ///
    /// 判据是 App Store 收据文件名：TestFlight 包为 `sandboxReceipt`，正式上架包为 `receipt`。
    /// 用 Xcode 直接调试运行时没有收据，同样返回 `false`。
    ///
    /// - Example:
    ///   ```swift
    ///   if SystemInfoKit.isTestFlight {
    ///       // 内测包：可放宽日志级别、显示「内测版」水印
    ///   }
    ///   ```
    public static var isTestFlight: Bool {
        Bundle.main.appStoreReceiptURL?.lastPathComponent == "sandboxReceipt"
    }

    /// 签名团队 ID（形如 `ABCDE12345`；读取不到时返回 `nil`）
    ///
    /// 先查 Info.plist 的 `TeamIdentifierPrefix`（少数构建方式会写入），再解析包内嵌的
    /// `embedded.mobileprovision` 描述文件中的 `TeamIdentifier`。App Store 分发的包不带
    /// 描述文件，macOS 包也不带，此时返回 `nil`。
    public static var teamIdentifier: String? {
        if let prefix = Bundle.main.object(forInfoDictionaryKey: "TeamIdentifierPrefix") as? String {
            let trimmed = prefix.trimmingCharacters(in: CharacterSet(charactersIn: "."))
            if !trimmed.isEmpty { return trimmed }
        }
        return teamIdentifierFromProvision()
    }

    /// 内嵌描述文件中的签名团队 ID（无描述文件 / 解析失败时为 `nil`）
    private static func teamIdentifierFromProvision() -> String? {
        guard let url = Bundle.main.url(forResource: "embedded", withExtension: "mobileprovision"),
              let data = try? Data(contentsOf: url),
              // 描述文件是 CMS 签名包，中间夹着一段 XML plist，截出前后标记即可交给 plist 解析
              let text = String(data: data, encoding: .isoLatin1),
              let start = text.range(of: "<?xml"),
              let end = text.range(of: "</plist>") else { return nil }
        let plist = String(text[start.lowerBound..<end.upperBound])
        guard let plistData = plist.data(using: .isoLatin1),
              let object = try? PropertyListSerialization.propertyList(from: plistData,
                                                                       options: [],
                                                                       format: nil),
              let dict = object as? [String: Any],
              let teams = dict["TeamIdentifier"] as? [String] else { return nil }
        return teams.first
    }

    /// 已安装的应用列表（仅 macOS；iOS 返回空数组）
    ///
    /// 扫描 `/Applications` 与 `/System/Applications` 下的 `.app` 包，读取各自 `Info.plist`
    /// 里的名称 / 标识符 / 版本号，按名称排序。
    ///
    /// 只扫顶层目录、不深入 `.app` 内部，所以不会把 App 里嵌的辅助程序（XPC 服务等）也算进来。
    /// 目录读不到（沙盒未授权等）时跳过该目录，不抛错。
    ///
    /// - Example:
    ///   ```swift
    ///   let 应用 = SystemInfoKit.installedApplications
    ///   print("共 \(应用.count) 个应用")
    ///   for item in 应用.prefix(5) { print("\(item.name) \(item.versionText)") }
    ///   ```
    public static var installedApplications: [InstalledApplication] {
        #if os(macOS)
        let roots = [
            URL(fileURLWithPath: "/Applications", isDirectory: true),
            URL(fileURLWithPath: "/System/Applications", isDirectory: true)
        ]
        var apps: [InstalledApplication] = []
        var seen = Set<String>()
        for root in roots {
            guard let entries = try? FileManager.default.contentsOfDirectory(at: root,
                                                                             includingPropertiesForKeys: [.isDirectoryKey],
                                                                             options: [.skipsHiddenFiles]) else { continue }
            for entry in entries where entry.pathExtension == "app" {
                guard let app = makeInstalledApplication(at: entry) else { continue }
                // 两个目录都扫，万一出现同名同路径的包只留一份
                if seen.insert(app.url.path).inserted {
                    apps.append(app)
                }
            }
        }
        // 用本地化排序，中文环境下更接近访达里的显示顺序
        return apps.sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
        #else
        return []
        #endif
    }

    /// 已安装应用的个数（仅 macOS；iOS 恒为 `0`）
    public static var installedApplicationCount: Int {
        installedApplications.count
    }

    #if os(macOS)
    /// 读取一个 `.app` 包的基本信息；不是有效应用包时返回 `nil`（内部工具）
    private static func makeInstalledApplication(at url: URL) -> InstalledApplication? {
        guard let bundle = Bundle(url: url) else { return nil }
        let displayName = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
        let bundleName = bundle.object(forInfoDictionaryKey: "CFBundleName") as? String
        let fallback = url.deletingPathExtension().lastPathComponent
        let name = [displayName, bundleName]
            .compactMap { $0 }
            .first { !$0.isEmpty } ?? fallback
        // Info.plist 里偶尔出现空串（有些系统 App 就是），空串等同读不到，统一归一成 nil
        let identifier = bundle.bundleIdentifier.flatMap { $0.isEmpty ? nil : $0 }
        let version = (bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String)
            .flatMap { $0.isEmpty ? nil : $0 }
        return InstalledApplication(name: name,
                                    bundleIdentifier: identifier,
                                    version: version,
                                    url: url)
    }
    #endif

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

    /// 当前 Wi-Fi 名称（SSID；未连 Wi-Fi 或读取不到时返回 `nil`）
    ///
    /// macOS 经 CoreWLAN 读取当前默认 Wi-Fi 接口的 SSID（无需额外权限）。
    /// iOS 上系统要求 App 声明「Access WiFi Information」权限才允许读取 SSID，
    /// 本库为保持「零配置直接用」固定返回 `nil`；如确有需要，可在 App 侧自行引入
    /// `NetworkExtension` 的 `NEHotspotNetwork.fetchCurrent` 并申请该权限。
    ///
    /// - Note: SSID 属于可定位到用户的信息，上报前请斟酌是否有必要。
    public static var wifiSSID: String? {
        #if os(macOS)
        return CWWiFiClient.shared().interface()?.ssid()
        #else
        return nil
        #endif
    }

    /// 当前是否走了系统代理
    ///
    /// 读取系统代理设置（`CFNetworkCopySystemProxySettings`）判断 HTTP / HTTPS / SOCKS
    /// 代理是否至少启用了一项。iOS / macOS 通用，无需任何权限。
    ///
    /// - Example:
    ///   ```swift
    ///   if SystemInfoKit.isUsingProxy {
    ///       print("当前代理：\(SystemInfoKit.proxyDescription ?? "未知")")
    ///   }
    ///   ```
    public static var isUsingProxy: Bool {
        proxyDescription != nil
    }

    /// 系统代理描述（形如 `HTTPS 代理 127.0.0.1:8080`；未启用代理时返回 `nil`）
    ///
    /// 优先级为 HTTPS → HTTP → SOCKS，返回第一个已启用的代理。
    public static var proxyDescription: String? {
        #if canImport(CFNetwork)
        guard let raw = CFNetworkCopySystemProxySettings()?.takeRetainedValue(),
              let settings = raw as? [String: Any] else { return nil }
        let candidates: [(enable: String, host: String, port: String, name: String)] = [
            ("HTTPSEnable", "HTTPSProxy", "HTTPSPort", "HTTPS 代理"),
            ("HTTPEnable", "HTTPProxy", "HTTPPort", "HTTP 代理"),
            ("SOCKSEnable", "SOCKSProxy", "SOCKSProxyPort", "SOCKS 代理"),
        ]
        for item in candidates {
            guard (settings[item.enable] as? NSNumber)?.intValue == 1,
                  let host = settings[item.host] as? String, !host.isEmpty else { continue }
            let port = (settings[item.port] as? NSNumber)?.intValue ?? 0
            return port > 0 ? "\(item.name) \(host):\(port)" : "\(item.name) \(host)"
        }
        return nil
        #else
        return nil
        #endif
    }

    /// DNS 服务器地址列表（macOS 解析 `/etc/resolv.conf`；iOS 返回空数组）
    public static var dnsServers: [String] {
        #if os(macOS)
        guard let content = try? String(contentsOfFile: "/etc/resolv.conf", encoding: .utf8) else { return [] }
        return content.components(separatedBy: .newlines).compactMap { line -> String? in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.hasPrefix("nameserver") else { return nil }
            let parts = trimmed.split(separator: " ", omittingEmptySubsequences: true)
            guard parts.count >= 2 else { return nil }
            return String(parts[1])
        }
        #else
        return []
        #endif
    }

    /// 默认网关地址（形如 `192.168.1.1`；仅 macOS，读取不到返回 `nil`）
    ///
    /// 通过 `sysctl` 拉取带 `RTF_GATEWAY` 标志的路由表，定位目标为 `0.0.0.0` 的默认路由。
    public static var defaultGateway: String? {
        #if os(macOS)
        return routeGateway()
        #else
        return nil
        #endif
    }

    /// 公网出口 IP 地址（异步请求）
    ///
    /// 通过公共接口（api.ipify.org）获取本机当前出口的公网 IP。需要网络，失败时抛错。
    ///
    /// - Example:
    ///   ```swift
    ///   Task {
    ///       let ip = try await SystemInfoKit.publicIPAddress()
    ///       print("公网 IP：\(ip)")
    ///   }
    ///   ```
    public static func publicIPAddress() async throws -> String {
        guard let url = URL(string: "https://api.ipify.org") else {
            throw SystemInfoError.invalidResponse
        }
        let (data, response) = try await URLSession.shared.data(from: url)
        guard let http = response as? HTTPURLResponse, http.statusCode == 200,
              let ip = String(data: data, encoding: .utf8)?
                  .trimmingCharacters(in: .whitespacesAndNewlines),
              !ip.isEmpty else {
            throw SystemInfoError.invalidResponse
        }
        return ip
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

    // MARK: - 运行环境

    /// 内核版本（Darwin 版本号，形如 `23.6.0`）
    ///
    /// 来自 `uname` 的 `release` 字段，比 `systemVersion`（面向用户的系统版本）更底层，
    /// 排查底层 / 驱动问题时有用。
    public static var kernelVersion: String {
        var uts = utsname()
        guard uname(&uts) == 0 else { return "未知" }
        var release = uts.release
        return withUnsafeBytes(of: &release) { raw in
            String(cString: raw.bindMemory(to: CChar.self).baseAddress!)
        }
    }

    /// 主机名（macOS 形如 `MacBook-Pro.local`；iOS 形如 `iPhone`）
    public static var hostName: String {
        ProcessInfo.processInfo.hostName
    }

    /// 当前用户名（macOS 为登录用户名；iOS 恒为 `mobile`）
    public static var userName: String {
        NSUserName()
    }

    /// 是否被调试器附加（`sysctl` 进程标志位 `P_TRACED`）
    ///
    /// 常用于「仅开发期启用某些行为」的判断。经 Xcode / 模拟器运行时为 `true`，
    /// 独立安装启动的正式包为 `false`。
    public static var isDebuggerAttached: Bool {
        var info = kinfo_proc()
        var mib = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var size = MemoryLayout<kinfo_proc>.size
        let result = sysctl(&mib, u_int(mib.count), &info, &size, nil, 0)
        guard result == 0 else { return false }
        return (info.kp_proc.p_flag & P_TRACED) != 0
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

    /// 每个逻辑核的 CPU 使用率（`0.0` ~ `1.0`，下标即核序号）
    ///
    /// 与 `cpuUsage` 同为「两次采样求差」，只是逐核分别计算。核数即系统报告的**逻辑核**数量
    /// （带超线程的 Intel 机器会比物理核多一倍）。每次调用会短暂阻塞约 100ms；
    /// 两次采样的核数不一致（极罕见）时返回空数组。
    ///
    /// - Example:
    ///   ```swift
    ///   let 占用 = SystemInfoKit.perCoreCPUUsage
    ///   for (index, value) in 占用.enumerated() {
    ///       print("CPU\(index + 1)：\(Int(value * 100))%")
    ///   }
    ///   ```
    public static var perCoreCPUUsage: [Double] {
        guard let first = samplePerCoreCPUTicks() else { return [] }
        Thread.sleep(forTimeInterval: 0.1)
        guard let second = samplePerCoreCPUTicks(), second.count == first.count else { return [] }
        var usages: [Double] = []
        usages.reserveCapacity(first.count)
        for index in 0..<first.count {
            let dUser = second[index].user &- first[index].user
            let dSystem = second[index].system &- first[index].system
            let dIdle = second[index].idle &- first[index].idle
            let dNice = second[index].nice &- first[index].nice
            let total = dUser &+ dSystem &+ dIdle &+ dNice
            guard total > 0 else {
                usages.append(0)
                continue
            }
            let busy = dUser &+ dSystem &+ dNice
            usages.append(Double(busy) / Double(total))
        }
        return usages
    }

    /// 每个逻辑核 CPU 使用率的单行文本（形如 `CPU1 12% · CPU2 34%`；取不到时返回「不支持」）
    public static var perCoreCPUUsageText: String {
        let usages = perCoreCPUUsage
        guard !usages.isEmpty else { return "不支持" }
        return usages.enumerated()
            .map { "CPU\($0.offset + 1) \(Int(($0.element * 100).rounded()))%" }
            .joined(separator: " · ")
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

    /// 内存占用明细（活跃 / 非活跃 / 联动 / 压缩 / 可丢弃 / 预读；读取失败时返回 `nil`）
    ///
    /// 比 `memoryUsedBytes` / `memoryUsagePercent` 更细，适合做内存面板或排查「内存去哪了」。
    /// 数据来自 mach `host_statistics64`，与 `memoryUsedBytes` 同一份数据源，两者口径一致。
    ///
    /// - Example:
    ///   ```swift
    ///   if let 明细 = SystemInfoKit.memoryBreakdown {
    ///       print(明细.text)
    ///       print(明细.联动文本)     // 联动内存不可回收，长期偏高说明有内存压力
    ///   }
    ///   ```
    public static var memoryBreakdown: MemoryBreakdown? {
        memoryBreakdownStats()
    }

    /// 系统负载（1 / 5 / 15 分钟平均负载，`getloadavg` 三值）
    ///
    /// 负载值表示「平均可运行线程数」：多核机器上数值可超过 `1.0`。
    /// 与 `cpuUsage`（瞬时占用率）不同，负载反映一段时间内的平均排队压力。
    public static var loadAverage: [Double] {
        var loads = [Double](repeating: 0, count: 3)
        let result = loads.withUnsafeMutableBufferPointer { buffer in
            getloadavg(buffer.baseAddress, 3)
        }
        guard result == 3 else { return [0, 0, 0] }
        return loads
    }

    /// 1 分钟平均负载
    public static var loadAverage1Min: Double { loadAverage[0] }

    /// 5 分钟平均负载
    public static var loadAverage5Min: Double { loadAverage[1] }

    /// 15 分钟平均负载
    public static var loadAverage15Min: Double { loadAverage[2] }

    // MARK: - 网络流量统计

    /// 采样一次网络流量（累计字节 + 每秒速率）
    ///
    /// 读取当前活跃网络接口（Wi-Fi `en0` 优先）的累计收发字节，与上次采样做差换算速率。
    /// 首次调用无历史样本，速率返回 `nil`；之后每次调用都会更新内部样本。
    ///
    /// - Returns: 网络流量快照；无活跃接口时返回 `nil`
    ///
    /// - Example:
    ///   ```swift
    ///   if let t = SystemInfoKit.sampleNetworkTraffic() {
    ///       print("累计接收 \(t.receivedBytes) B · 接收速率 \(t.receivedBytesPerSecond ?? 0) B/s")
    ///   }
    ///   ```
    public static func sampleNetworkTraffic() -> NetworkTraffic? {
        guard let active = activeNetworkInterface(),
              let counts = networkByteCounts(interfaceName: active.name) else { return nil }
        let now = Date()
        trafficLock.lock()
        defer { trafficLock.unlock() }
        let previous = lastTrafficSample
        lastTrafficSample = (now.timeIntervalSince1970, counts.received, counts.sent)

        var receivedRate: Double?
        var sentRate: Double?
        if let prev = previous {
            let dt = now.timeIntervalSince1970 - prev.timestamp
            if dt > 0 {
                receivedRate = Double(delta(from: prev.received, to: counts.received)) / dt
                sentRate = Double(delta(from: prev.sent, to: counts.sent)) / dt
            }
        }
        return NetworkTraffic(receivedBytes: counts.received,
                              sentBytes: counts.sent,
                              receivedBytesPerSecond: receivedRate,
                              sentBytesPerSecond: sentRate,
                              interface: active.name,
                              timestamp: now)
    }

    /// 计算计数器差值，处理 32 位计数器回绕（溢出归零后继续累加）
    private static func delta(from old: UInt64, to new: UInt64) -> UInt64 {
        if new >= old { return new - old }
        // ifi_ibytes / ifi_obytes 为 u_int32_t，回绕周期约 4 GB
        return (UInt64(UInt32.max) + 1 - old) + new
    }

    private static let trafficLock = NSLock()
    private static var lastTrafficSample: (timestamp: TimeInterval, received: UInt64, sent: UInt64)?

    /// 读取指定接口的累计收发字节（`getifaddrs` 的 AF_LINK `if_data`）
    private static func networkByteCounts(interfaceName: String) -> (received: UInt64, sent: UInt64)? {
        var ifaddrPtr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddrPtr) == 0, let first = ifaddrPtr else { return nil }
        defer { freeifaddrs(first) }
        var current: UnsafeMutablePointer<ifaddrs>? = first
        while let ifa = current {
            defer { current = ifa.pointee.ifa_next }
            let name = String(cString: ifa.pointee.ifa_name)
            guard name == interfaceName else { continue }
            guard let addr = ifa.pointee.ifa_addr, addr.pointee.sa_family == UInt8(AF_LINK) else { continue }
            guard let raw = ifa.pointee.ifa_data else { continue }
            let ifData = raw.assumingMemoryBound(to: if_data.self).pointee
            return (UInt64(ifData.ifi_ibytes), UInt64(ifData.ifi_obytes))
        }
        return nil
    }

    // MARK: - 磁盘读写速率

    /// 采样一次磁盘 I/O（累计读写字节 + 每秒速率，仅 macOS）
    ///
    /// 汇总所有 `IOBlockStorageDriver` 的累计读写字节，与上次采样做差换算速率。
    /// iOS 无法访问 IOKit 块存储统计，恒返回 `nil`；首次调用速率返回 `nil`。
    ///
    /// - Returns: 磁盘读写快照；无法读取时返回 `nil`
    public static func sampleDiskIOTraffic() -> DiskIOTraffic? {
        #if os(macOS)
        guard let counts = diskIOByteCounts() else { return nil }
        let now = Date()
        diskIOLock.lock()
        defer { diskIOLock.unlock() }
        let previous = lastDiskIOSample
        lastDiskIOSample = (now.timeIntervalSince1970, counts.read, counts.written)

        var readRate: Double?
        var writeRate: Double?
        if let prev = previous {
            let dt = now.timeIntervalSince1970 - prev.timestamp
            if dt > 0 {
                readRate = Double(counts.read >= prev.read ? counts.read - prev.read : 0) / dt
                writeRate = Double(counts.written >= prev.written ? counts.written - prev.written : 0) / dt
            }
        }
        return DiskIOTraffic(bytesRead: counts.read,
                             bytesWritten: counts.written,
                             readBytesPerSecond: readRate,
                             writeBytesPerSecond: writeRate,
                             timestamp: now)
        #else
        return nil
        #endif
    }

    #if os(macOS)
    private static let diskIOLock = NSLock()
    private static var lastDiskIOSample: (timestamp: TimeInterval, read: UInt64, written: UInt64)?

    /// 汇总所有 `IOBlockStorageDriver` 的累计读写字节
    private static func diskIOByteCounts() -> (read: UInt64, written: UInt64)? {
        var iterator = io_iterator_t()
        let matching = IOServiceMatching("IOBlockStorageDriver")
        let result = IOServiceGetMatchingServices(kIOMainPortDefault, matching, &iterator)
        guard result == KERN_SUCCESS else { return nil }
        defer { IOObjectRelease(iterator) }

        var read: UInt64 = 0
        var written: UInt64 = 0
        while true {
            let service = IOIteratorNext(iterator)
            guard service != 0 else { break }
            defer { IOObjectRelease(service) }
            guard let stats = IORegistryEntryCreateCFProperty(service, "Statistics" as CFString, kCFAllocatorDefault, 0)?
                .takeRetainedValue() as? [String: Any] else { continue }
            if let r = (stats["Bytes (Read)"] as? NSNumber)?.uint64Value { read += r }
            if let w = (stats["Bytes (Write)"] as? NSNumber)?.uint64Value { written += w }
        }
        return (read, written)
    }
    #endif

    // MARK: - 运行进程

    /// 系统当前运行进程列表
    ///
    /// 通过 `sysctl(KERN_PROC, KERN_PROC_ALL)` 枚举内核进程表，返回每个进程的 pid 与名称。
    /// 进程表实时变化，两次调用结果可能不同。iOS 沙盒下只能看到有限信息。
    public static var runningProcesses: [RunningProcess] {
        var mib = [CTL_KERN, KERN_PROC, KERN_PROC_ALL, 0]
        var length = 0
        guard sysctl(&mib, u_int(mib.count), nil, &length, nil, 0) == 0, length > 0 else { return [] }
        var buffer = [UInt8](repeating: 0, count: length)
        let result = buffer.withUnsafeMutableBytes { (raw: UnsafeMutableRawBufferPointer) -> Int32 in
            sysctl(&mib, u_int(mib.count), raw.baseAddress, &length, nil, 0)
        }
        guard result == 0, length > 0 else { return [] }

        let count = length / MemoryLayout<kinfo_proc>.size
        var processes: [RunningProcess] = []
        processes.reserveCapacity(count)
        buffer.withUnsafeBytes { raw in
            let base = raw.bindMemory(to: kinfo_proc.self).baseAddress!
            for i in 0..<count {
                let kp = base[i]
                let pid = kp.kp_proc.p_pid
                var comm = kp.kp_proc.p_comm
                let name = withUnsafeBytes(of: &comm) { raw in
                    String(cString: raw.bindMemory(to: CChar.self).baseAddress!)
                }
                processes.append(RunningProcess(pid: pid, name: name))
            }
        }
        return processes
    }

    /// 运行进程数量（实时重新枚举 `runningProcesses`）
    public static var processCount: Int {
        runningProcesses.count
    }

    /// 进程占用排行 Top N（按内存或 CPU 排序，仅 macOS）
    ///
    /// 逐个进程向内核查询占用信息（libproc），再按 `key` 排序取前 `limit` 个。
    /// 因为要逐个查，进程多时有一点耗时，适合「按需点一下看排行」，不要放进高频刷新里。
    ///
    /// - Parameters:
    ///   - key: 排序依据，默认 `.memory`（按常驻内存）
    ///   - limit: 返回条数上限，默认 `10`；传 `0` 或负数返回空数组
    /// - Returns: 占用排行；非 macOS 平台恒为空数组
    ///
    /// - Note: 只统计能读到信息的进程——系统进程受权限限制可能读不到，会被跳过；
    ///   `pid == 0` 的内核进程也被排除。
    ///
    /// - Example:
    ///   ```swift
    ///   for item in SystemInfoKit.topProcesses(by: .memory, limit: 5) {
    ///       print(item.name, item.memory, String(format: "%.1f%%", item.cpuPercent))
    ///   }
    ///   ```
    public static func topProcesses(by key: ProcessSortKey = .memory, limit: Int = 10) -> [ProcessUsage] {
        #if os(macOS)
        guard limit > 0 else { return [] }
        var usages: [ProcessUsage] = []
        for process in runningProcesses where process.pid > 0 {
            if let usage = processUsage(pid: process.pid, name: process.name) {
                usages.append(usage)
            }
        }
        switch key {
        case .memory:
            usages.sort { $0.memoryBytes > $1.memoryBytes }
        case .cpu:
            usages.sort { $0.cpuPercent > $1.cpuPercent }
        }
        return Array(usages.prefix(limit))
        #else
        return []
        #endif
    }

    // MARK: - 交换内存

    /// 交换空间总量（字节，仅 macOS；其它平台返回 `nil`）
    public static var swapTotalBytes: UInt64? { swapUsage()?.total }

    /// 交换空间已用（字节，仅 macOS；其它平台返回 `nil`）
    public static var swapUsedBytes: UInt64? { swapUsage()?.used }

    /// 交换空间总量（人类可读，非 macOS 返回「不支持」）
    public static var swapTotal: String {
        guard let bytes = swapTotalBytes else { return "不支持" }
        return ByteCountFormatter.string(fromByteCount: Int64(bytes), countStyle: .memory)
    }

    /// 交换空间已用（人类可读，非 macOS 返回「不支持」）
    public static var swapUsed: String {
        guard let bytes = swapUsedBytes else { return "不支持" }
        return ByteCountFormatter.string(fromByteCount: Int64(bytes), countStyle: .memory)
    }

    /// 读取交换空间统计（`vm.swapusage`，仅 macOS）
    private static func swapUsage() -> (total: UInt64, used: UInt64)? {
        #if os(macOS)
        var mib = [CTL_VM, VM_SWAPUSAGE]
        var usage = xsw_usage()
        var size = MemoryLayout<xsw_usage>.size
        let result = withUnsafeMutablePointer(to: &usage) { ptr in
            sysctl(&mib, u_int(mib.count), ptr, &size, nil, 0)
        }
        guard result == 0 else { return nil }
        return (usage.xsu_total, usage.xsu_used)
        #else
        return nil
        #endif
    }

    // MARK: - 网络接口

    /// 网络接口列表（名称 + IPv4 地址 + 物理地址 + 是否启用 / 是否回环）
    ///
    /// 通过 `getifaddrs` 枚举所有接口，含虚拟接口（`lo0`、`utun` 等）。
    /// 物理地址（MAC）取自链路层地址，只有真实网卡才有，虚拟接口为 `nil`。
    public static var networkInterfaces: [NetworkInterface] {
        var ifaddrPtr: UnsafeMutablePointer<ifaddrs>?
        guard getifaddrs(&ifaddrPtr) == 0, let first = ifaddrPtr else { return [] }
        defer { freeifaddrs(first) }

        var flagsByName: [String: (up: Bool, loopback: Bool)] = [:]
        var addressByName: [String: String] = [:]
        var macByName: [String: String] = [:]
        var order: [String] = []

        var current: UnsafeMutablePointer<ifaddrs>? = first
        while let ifa = current {
            defer { current = ifa.pointee.ifa_next }
            let name = String(cString: ifa.pointee.ifa_name)
            guard let addr = ifa.pointee.ifa_addr else { continue }
            let family = addr.pointee.sa_family
            let flags = Int32(ifa.pointee.ifa_flags)

            if family == UInt8(AF_LINK) {
                if flagsByName[name] == nil { order.append(name) }
                flagsByName[name] = ((flags & IFF_UP) == IFF_UP, (flags & IFF_LOOPBACK) == IFF_LOOPBACK)
                macByName[name] = linkLayerAddress(addr)
            } else if family == UInt8(AF_INET) {
                var host = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                if getnameinfo(addr, socklen_t(addr.pointee.sa_len), &host, socklen_t(host.count), nil, 0, NI_NUMERICHOST) == 0 {
                    addressByName[name] = String(cString: host)
                }
            }
        }

        return order.map { name in
            let f = flagsByName[name] ?? (up: false, loopback: false)
            return NetworkInterface(name: name,
                                    address: addressByName[name],
                                    macAddress: macByName[name],
                                    isUp: f.up,
                                    isLoopback: f.loopback)
        }
    }

    /// 主网卡的物理地址（MAC）
    ///
    /// 优先取 `en0`（一般就是 Wi-Fi / 有线网卡），没有则取第一个「已启用、非回环、且读到了物理地址」的接口。
    /// 都取不到时返回 `nil`。
    ///
    /// - Example:
    ///   ```swift
    ///   SystemInfoKit.primaryMACAddress   // "A4:83:E7:12:34:56"
    ///   ```
    public static var primaryMACAddress: String? {
        let interfaces = networkInterfaces
        if let en0 = interfaces.first(where: { $0.name == "en0" }), let mac = en0.macAddress {
            return mac
        }
        return interfaces.first { $0.isUp && !$0.isLoopback && $0.macAddress != nil }?.macAddress
    }

    /// 内部：从链路层地址（`sockaddr_dl`）里取出 MAC 并格式化成大写冒号分隔
    ///
    /// `sockaddr_dl.sdl_data` 的前 `sdl_nlen` 个字节是接口名，紧跟其后的 `sdl_alen` 个字节才是地址。
    /// 只认 6 字节的以太网 / Wi-Fi 地址；回环、隧道等接口 `sdl_alen` 为 0，返回 `nil`。
    private static func linkLayerAddress(_ addr: UnsafeMutablePointer<sockaddr>) -> String? {
        let link = UnsafeRawPointer(addr).assumingMemoryBound(to: sockaddr_dl.self)
        let nameLength = Int(link.pointee.sdl_nlen)
        let addressLength = Int(link.pointee.sdl_alen)
        guard addressLength == 6 else { return nil }
        let dataOffset = MemoryLayout<sockaddr_dl>.offset(of: \.sdl_data) ?? 8
        let start = UnsafeRawPointer(addr).advanced(by: dataOffset + nameLength)
        let bytes = UnsafeRawBufferPointer(start: start, count: addressLength)
        return bytes.map { String(format: "%02X", $0) }.joined(separator: ":")
    }

    // MARK: - 信息快照

    /// 系统信息快照：把常用检测项一次性汇总成一个字典
    ///
    /// 键为英文属性名（与各属性名一一对应），值全部为字符串（人类可读），
    /// 因此可以直接交给 `JSONSerialization` 序列化后上报 / 落盘：
    ///
    /// ```swift
    /// let data = try JSONSerialization.data(withJSONObject: SystemInfoKit.snapshot(),
    ///                                       options: [.prettyPrinted, .sortedKeys])
    /// ```
    ///
    /// - Note: 只含「即时可取」的项，不含需要采样或阻塞的 CPU 使用率 / 网络流量 / 磁盘读写速率，
    ///   可安全高频调用（如每次崩溃上报时附一份）。
    /// - Returns: 信息快照字典（值均为字符串）
    public static func snapshot() -> [String: String] {
        var dict: [String: String] = [
            "systemName": systemName,
            "systemVersion": systemVersion,
            "deviceIdentifier": deviceIdentifier,
            "deviceModelName": deviceModelName,
            "deviceName": deviceName,
            "deviceType": deviceType,
            "cpuArchitecture": cpuArchitecture,
            "processorCount": "\(processorCount)",
            "memoryTotal": memoryTotal,
            "diskTotal": diskTotal,
            "diskFree": diskFree,
            "diskUsage": String(format: "%.1f%%", diskUsagePercent * 100),
            "thermalState": thermalStateName,
            "isLowPowerModeEnabled": "\(isLowPowerModeEnabled)",
            "screenSize": screenSize,
            "screenScale": "\(screenScale)",
            "displayCount": "\(displayCount)",
            "maximumFramesPerSecond": "\(maximumFramesPerSecond)",
            "accessibility": accessibilitySummary,
            "isDarkMode": "\(isDarkMode)",
            "languageCode": languageCode,
            "regionCode": regionCode,
            "timeZoneIdentifier": timeZoneIdentifier,
            "appName": appName,
            "appVersion": appVersion,
            "appBuildNumber": appBuildNumber,
            "bundleIdentifier": bundleIdentifier,
            "isTestFlight": "\(isTestFlight)",
            "isUsingProxy": "\(isUsingProxy)",
            "mountedVolumeCount": "\(mountedVolumeCount)",
            "isSimulator": "\(isSimulator)",
            "systemUptime": systemUptimeString,
            "bootTime": bootTimeString,
            "kernelVersion": kernelVersion,
            "hostName": hostName,
            "userName": userName,
            "isDebuggerAttached": "\(isDebuggerAttached)"
        ]
        if let processor = processorName {
            dict["processorName"] = processor
        }
        if let brightness = screenBrightness {
            dict["screenBrightness"] = String(format: "%.0f%%", brightness * 100)
        }
        if let level = batteryLevel {
            dict["batteryLevel"] = String(format: "%.0f%%", Double(level) * 100)
        }
        if let charging = isCharging {
            dict["isCharging"] = "\(charging)"
        }
        dict["batteryState"] = batteryStateName
        return dict
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

    /// 枚举 IOKit 注册表里的 USB 外设（macOS）
    ///
    /// 新系统的设备类名是 `IOUSBHostDevice`，老系统是 `IOUSBDevice`：先试新的，
    /// 读不到再用老的，避免同一台设备被两个类名各枚举一遍。
    private static func rawUSBDevices() -> [USBDevice] {
        #if os(macOS)
        for className in ["IOUSBHostDevice", "IOUSBDevice"] {
            let devices = usbDevices(matchingClass: className)
            if !devices.isEmpty { return devices }
        }
        return []
        #else
        return []
        #endif
    }

    /// 枚举指定 IOKit 类名的 USB 外设节点（macOS）
    private static func usbDevices(matchingClass className: String) -> [USBDevice] {
        #if os(macOS)
        guard let matching = IOServiceMatching(className) else { return [] }
        var iterator: io_iterator_t = 0
        // IOServiceGetMatchingServices 会消费 matching 字典，调用方不需要再释放
        guard IOServiceGetMatchingServices(kIOMainPortDefault, matching, &iterator) == KERN_SUCCESS else { return [] }
        defer { IOObjectRelease(iterator) }

        var devices: [USBDevice] = []
        var service = IOIteratorNext(iterator)
        while service != 0 {
            if let device = usbDevice(from: service) {
                devices.append(device)
            }
            IOObjectRelease(service)
            service = IOIteratorNext(iterator)
        }
        return devices
        #else
        return []
        #endif
    }

    /// 从单个 IOKit 服务节点读出 USB 外设信息（macOS；没有任何可用字段时返回 `nil`）
    private static func usbDevice(from service: io_registry_entry_t) -> USBDevice? {
        #if os(macOS)
        var rawProperties: Unmanaged<CFMutableDictionary>?
        guard IORegistryEntryCreateCFProperties(service, &rawProperties, kCFAllocatorDefault, 0) == KERN_SUCCESS,
              let cfProperties = rawProperties?.takeRetainedValue(),
              let properties = (cfProperties as NSDictionary) as? [String: Any] else { return nil }

        let rawName = (properties["USB Product Name"] as? String) ?? ""
        let rawVendor = (properties["USB Vendor Name"] as? String) ?? ""
        let rawSerial = (properties["USB Serial Number"] as? String) ?? ""
        let vendorID = (properties["idVendor"] as? NSNumber)?.intValue
        let productID = (properties["idProduct"] as? NSNumber)?.intValue

        // 三个文本字段全空、又没有任何 ID 的节点（如集线器的空端口）直接跳过
        guard !rawName.isEmpty || !rawVendor.isEmpty || vendorID != nil || productID != nil else { return nil }

        return USBDevice(name: rawName.isEmpty ? "未知设备" : rawName,
                         vendorName: rawVendor.isEmpty ? nil : rawVendor,
                         vendorID: vendorID,
                         productID: productID,
                         serialNumber: rawSerial.isEmpty ? nil : rawSerial)
        #else
        return nil
        #endif
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

    /// 采样一次每个逻辑核的 tick（每项为 USER / SYSTEM / IDLE / NICE）
    ///
    /// 与 `sampleCPUTicks()` 同一个 `host_processor_info` 调用，只是不把各核累加到一起。
    private static func samplePerCoreCPUTicks() -> [(user: UInt32, system: UInt32, idle: UInt32, nice: UInt32)]? {
        var cpuInfo: processor_info_array_t?
        var numCpuInfo: mach_msg_type_number_t = 0
        var numCPUs: natural_t = 0
        let result = host_processor_info(mach_host_self(), PROCESSOR_CPU_LOAD_INFO, &numCPUs, &cpuInfo, &numCpuInfo)
        guard result == KERN_SUCCESS, let info = cpuInfo, numCPUs > 0 else { return nil }
        defer {
            vm_deallocate(mach_task_self_, vm_address_t(bitPattern: info),
                          vm_size_t(numCpuInfo) * vm_size_t(MemoryLayout<integer_t>.size))
        }
        let perCPU = 4
        var ticks: [(user: UInt32, system: UInt32, idle: UInt32, nice: UInt32)] = []
        ticks.reserveCapacity(Int(numCPUs))
        for i in 0..<Int(numCPUs) {
            ticks.append((user: UInt32(bitPattern: info[i * perCPU + 0]),
                          system: UInt32(bitPattern: info[i * perCPU + 1]),
                          idle: UInt32(bitPattern: info[i * perCPU + 2]),
                          nice: UInt32(bitPattern: info[i * perCPU + 3])))
        }
        return ticks
    }

    /// 读取内存统计（`host_statistics64`），返回已用字节、使用率、可用字节
    ///
    /// 只是把 `memoryBreakdownStats()` 的三个派生量取出来，保证与 `memoryBreakdown` 口径完全一致。
    private static func memoryStats() -> (usedBytes: UInt64, percent: Double, availableBytes: UInt64)? {
        guard let breakdown = memoryBreakdownStats() else { return nil }
        return (breakdown.usedBytes, breakdown.usedPercent, breakdown.availableBytes)
    }

    /// 读取内存明细（`host_statistics64` / `vm_statistics64`），逐项拆出各类页数
    private static func memoryBreakdownStats() -> MemoryBreakdown? {
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
        return MemoryBreakdown(
            totalBytes: total,
            freeBytes: UInt64(stats.free_count) * pageSize,
            activeBytes: UInt64(stats.active_count) * pageSize,
            inactiveBytes: UInt64(stats.inactive_count) * pageSize,
            wiredBytes: UInt64(stats.wire_count) * pageSize,
            compressedBytes: UInt64(stats.compressor_page_count) * pageSize,
            purgeableBytes: UInt64(stats.purgeable_count) * pageSize,
            speculativeBytes: UInt64(stats.speculative_count) * pageSize)
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
        var info = task_vm_info_data_t()
        var count = mach_msg_type_number_t(MemoryLayout<task_vm_info_data_t>.size / MemoryLayout<natural_t>.size)
        let result = withUnsafeMutablePointer(to: &info) { ptr in
            ptr.withMemoryRebound(to: integer_t.self, capacity: Int(count)) { rebound in
                task_info(mach_task_self_, task_flavor_t(TASK_VM_INFO), rebound, &count)
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
    /// 读取单个进程的占用信息（libproc，内部工具）
    ///
    /// 分两次查询：`PROC_PIDTASKINFO` 拿常驻内存与累计 CPU 时间，`PROC_PIDTBSDINFO` 拿启动时刻。
    /// CPU 时间单位是纳秒，除以 10 亿换算成秒；平均占用率 = 累计 CPU 时间 / 已运行时长，
    /// 所以刚启动的进程读数会偏高、长时间运行的进程会偏低，这是「进程生命周期平均值」的正常特性。
    static func processUsage(pid: Int32, name: String) -> ProcessUsage? {
        var taskInfo = proc_taskinfo()
        let taskSize = MemoryLayout<proc_taskinfo>.stride
        guard proc_pidinfo(pid, PROC_PIDTASKINFO, 0, &taskInfo, Int32(taskSize)) == taskSize else { return nil }

        var startDate: Date?
        var bsdInfo = proc_bsdinfo()
        let bsdSize = MemoryLayout<proc_bsdinfo>.stride
        if proc_pidinfo(pid, PROC_PIDTBSDINFO, 0, &bsdInfo, Int32(bsdSize)) == bsdSize {
            let seconds = TimeInterval(bsdInfo.pbi_start_tvsec) + TimeInterval(bsdInfo.pbi_start_tvusec) / 1_000_000
            startDate = Date(timeIntervalSince1970: seconds)
        }

        let cpuTime = TimeInterval(taskInfo.pti_total_user &+ taskInfo.pti_total_system) / 1_000_000_000
        var cpuPercent = 0.0
        if let start = startDate {
            let elapsed = Date().timeIntervalSince(start)
            if elapsed > 0 { cpuPercent = cpuTime / elapsed * 100 }
        }

        return ProcessUsage(pid: pid,
                            name: name,
                            memoryBytes: taskInfo.pti_resident_size,
                            cpuTime: cpuTime,
                            cpuPercent: cpuPercent,
                            startDate: startDate)
    }

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

    /// 电源适配器信息字典的键
    ///
    /// 取值为 IOKit `kIOPSPowerAdapter*Key` 常量的实际字符串。这里直接写字面量，
    /// 以免依赖各 SDK 版本不一定导出的符号名（键值本身是稳定的公开约定）。
    private enum AdapterKey {
        /// 功率（瓦）
        static let watts = "Watts"
        /// 协商电压（毫伏）
        static let voltage = "Voltage"
        /// 协商电流（毫安）
        static let current = "Current"
        /// 适配器标识
        static let adapterID = "AdapterID"
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

    /// 读取 AppleSmartBattery 注册表里某个属性的值（IOKit）
    private static func smartBatteryProperty(_ key: String) -> CFTypeRef? {
        guard let matching = IOServiceMatching("AppleSmartBattery") else { return nil }
        let service = IOServiceGetMatchingService(kIOMainPortDefault, matching)
        guard service != 0 else { return nil }
        defer { IOObjectRelease(service) }
        let value = IORegistryEntryCreateCFProperty(service, key as CFString, kCFAllocatorDefault, 0)
        return value?.takeRetainedValue()
    }

    /// 读取 AppleSmartBattery 注册表里某个属性的数值
    private static func smartBatteryNumber(_ key: String) -> Int? {
        (smartBatteryProperty(key) as? NSNumber)?.intValue
    }

    /// 通过 sysctl 拉取默认网关（目标为 0.0.0.0 的默认路由）
    private static func routeGateway() -> String? {
        // MIB：CTL_NET(4), PF_ROUTE(17), 0, 0, NET_RT_FLAGS(2), RTF_GATEWAY(0x2)
        var mib: [Int32] = [4, 17, 0, 0, 2, 2]
        var length = 0
        guard sysctl(&mib, u_int(mib.count), nil, &length, nil, 0) == 0, length > 0 else { return nil }
        var buffer = [UInt8](repeating: 0, count: length)
        guard sysctl(&mib, u_int(mib.count), &buffer, &length, nil, 0) == 0 else { return nil }

        let headerSize = MemoryLayout<rt_msghdr>.size
        var offset = 0
        while offset + headerSize <= buffer.count {
            var header = rt_msghdr()
            _ = buffer.withUnsafeBytes { raw in
                memcpy(&header, raw.baseAddress!.advanced(by: offset), headerSize)
            }
            let messageLength = Int(header.rtm_msglen)
            guard messageLength > headerSize, offset + messageLength <= buffer.count else { break }

            // 遍历 header 之后按 rtm_addrs 位掩码排列的 sockaddr
            var bitmask = Int(header.rtm_addrs)
            var sockOffset = offset + headerSize
            var index = 0
            var isDefaultRoute = false
            var gateway: String?
            while bitmask != 0, sockOffset < offset + messageLength {
                if bitmask & 1 != 0 {
                    let sockLen = Int(buffer[sockOffset])
                    if sockLen >= MemoryLayout<sockaddr_in>.size,
                       sockOffset + MemoryLayout<sockaddr_in>.size <= buffer.count {
                        var sin = sockaddr_in()
                        _ = buffer.withUnsafeBytes { raw in
                            memcpy(&sin, raw.baseAddress!.advanced(by: sockOffset), MemoryLayout<sockaddr_in>.size)
                        }
                        if sin.sin_family == UInt8(AF_INET) {
                            if index == 0 {                        // RTAX_DST：默认路由目标为 0.0.0.0
                                isDefaultRoute = sin.sin_addr.s_addr == 0
                            } else if index == 1, isDefaultRoute { // RTAX_GATEWAY
                                gateway = formatIPv4(sin.sin_addr)
                            }
                        }
                    }
                    sockOffset += max(sockLen, 1)
                    index += 1
                }
                bitmask >>= 1
            }
            if let gateway = gateway { return gateway }
            offset += messageLength
        }
        return nil
    }

    /// 把 in_addr 格式化为点分十进制 IPv4
    private static func formatIPv4(_ addr: in_addr) -> String {
        let value = UInt32(bigEndian: addr.s_addr)
        return "\(value >> 24 & 0xFF).\(value >> 16 & 0xFF).\(value >> 8 & 0xFF).\(value & 0xFF)"
    }
    #endif
}

/// SystemInfoKit 抛出的错误
public enum SystemInfoError: Error, LocalizedError {
    /// 响应无效（非 200 或内容为空）
    case invalidResponse

    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "获取公网 IP 失败：响应无效"
        }
    }
}

/// 网络流量快照
///
/// 由 `SystemInfoKit.sampleNetworkTraffic()` 返回，含累计收发字节与换算后的每秒速率。
public struct NetworkTraffic {
    /// 累计接收字节（自系统启动 / 接口计数器开始统计）
    public let receivedBytes: UInt64
    /// 累计发送字节
    public let sentBytes: UInt64
    /// 接收速率（字节 / 秒；首次采样为 `nil`）
    public let receivedBytesPerSecond: Double?
    /// 发送速率（字节 / 秒；首次采样为 `nil`）
    public let sentBytesPerSecond: Double?
    /// 网络接口名（如 `en0`）
    public let interface: String
    /// 采样时间
    public let timestamp: Date
}

/// 中文名：网络流量（等同 `NetworkTraffic`）
public typealias 网络流量 = NetworkTraffic

/// 磁盘 I/O 快照
///
/// 由 `SystemInfoKit.sampleDiskIOTraffic()` 返回（仅 macOS），含累计读写字节与每秒速率。
public struct DiskIOTraffic {
    /// 累计读取字节
    public let bytesRead: UInt64
    /// 累计写入字节
    public let bytesWritten: UInt64
    /// 读取速率（字节 / 秒；首次采样为 `nil`）
    public let readBytesPerSecond: Double?
    /// 写入速率（字节 / 秒；首次采样为 `nil`）
    public let writeBytesPerSecond: Double?
    /// 采样时间
    public let timestamp: Date
}

/// 中文名：磁盘读写（等同 `DiskIOTraffic`）
public typealias 磁盘读写 = DiskIOTraffic

/// 单个运行进程的信息
///
/// 由 `SystemInfoKit.runningProcesses` 返回的列表元素。
public struct RunningProcess {
    /// 进程 ID
    public let pid: Int32
    /// 进程名（内核截断后的名称）
    public let name: String
}

/// 中文名：运行进程（等同 `RunningProcess`）
public typealias 运行进程 = RunningProcess

/// 电池细分状态
///
/// 由 `SystemInfoKit.batteryState` 返回。`isCharging` 只回答「有没有接电源」，
/// 本枚举进一步区分「接着电源但已充满」与「正在补充电量」。
public enum BatteryState: CaseIterable {
    /// 正在充电
    case charging
    /// 已接电源且已充满（不再继续充）
    case full
    /// 未接电源（用电池供电）
    case unplugged
    /// 未知 / 设备没有电池
    case unknown

    /// 状态的中文名
    public var chineseName: String {
        switch self {
        case .charging: return "充电中"
        case .full: return "已充满"
        case .unplugged: return "未接电源"
        case .unknown: return "未知"
        }
    }
}

/// 中文名：电池状态（等同 `BatteryState`）
public typealias 电池状态 = BatteryState

public extension BatteryState {
    /// 正在充电（等同 `.charging`）
    static var 充电中: BatteryState { .charging }
    /// 已充满（等同 `.full`）
    static var 已充满: BatteryState { .full }
    /// 未接电源（等同 `.unplugged`）
    static var 未接电源: BatteryState { .unplugged }
    /// 未知（等同 `.unknown`）
    static var 未知: BatteryState { .unknown }
}

/// 进程排行依据
///
/// 供 `SystemInfoKit.topProcesses(by:limit:)` 选择按哪个维度排序。
public enum ProcessSortKey {
    /// 按常驻内存（RSS）排序
    case memory
    /// 按平均 CPU 占用排序
    case cpu
}

/// 中文名：进程排序依据（等同 `ProcessSortKey`）
public typealias 进程排序依据 = ProcessSortKey

public extension ProcessSortKey {
    /// 按内存排序（等同 `.memory`）
    static var 内存: ProcessSortKey { .memory }
    /// 按 CPU 排序（等同 `.cpu`）
    static var CPU: ProcessSortKey { .cpu }
}

/// 单个进程的占用信息
///
/// 由 `SystemInfoKit.topProcesses(by:limit:)` 返回的列表元素（仅 macOS 有数据）。
public struct ProcessUsage {
    /// 进程 ID
    public let pid: Int32
    /// 进程名（内核截断后的名称）
    public let name: String
    /// 常驻内存（RSS，字节）
    public let memoryBytes: UInt64
    /// 累计占用的 CPU 时间（秒，用户态 + 内核态）
    public let cpuTime: TimeInterval
    /// 平均 CPU 占用百分比
    ///
    /// 按「累计 CPU 时间 / 进程已运行时长」计算，是**进程生命周期内的平均值**，
    /// 不是瞬时占用率；多线程进程可能超过 100。取不到启动时刻时为 `0`。
    public let cpuPercent: Double
    /// 进程启动时刻（取不到为 `nil`）
    public let startDate: Date?

    /// 常驻内存（人类可读，形如 `128 MB`）
    public var memory: String {
        ByteCountFormatter.string(fromByteCount: Int64(memoryBytes), countStyle: .memory)
    }
}

/// 中文名：进程占用（等同 `ProcessUsage`）
public typealias 进程占用 = ProcessUsage

public extension ProcessUsage {
    /// 常驻内存（人类可读，等同 `memory`）
    var 内存: String { memory }
    /// 进程 ID（等同 `pid`）
    var 进程ID: Int32 { pid }
    /// 进程名（等同 `name`）
    var 进程名称: String { name }
    /// 常驻内存字节（等同 `memoryBytes`）
    var 内存字节数: UInt64 { memoryBytes }
    /// 累计 CPU 时间（秒，等同 `cpuTime`）
    var CPU时间: TimeInterval { cpuTime }
    /// 平均 CPU 占用百分比（等同 `cpuPercent`）
    var CPU占用: Double { cpuPercent }
    /// 进程启动时刻（等同 `startDate`）
    var 启动时间: Date? { startDate }
}

/// 单个网络接口的信息
///
/// 由 `SystemInfoKit.networkInterfaces` 返回的列表元素。
public struct NetworkInterface {
    /// 接口名（如 `en0` / `lo0` / `utun0`）
    public let name: String
    /// IPv4 地址（无则 `nil`）
    public let address: String?
    /// 物理地址 / MAC（大写冒号分隔，如 `A4:83:E7:12:34:56`；虚拟接口为 `nil`）
    public let macAddress: String?
    /// 是否已启用（`IFF_UP`）
    public let isUp: Bool
    /// 是否回环接口（`IFF_LOOPBACK`，如 `lo0`）
    public let isLoopback: Bool
}

/// 中文名：网络接口（等同 `NetworkInterface`）
public typealias 网络接口 = NetworkInterface

public extension NetworkInterface {
    /// 接口名（等同 `name`）
    var 名称: String { name }
    /// IPv4 地址（等同 `address`）
    var 地址: String? { address }
    /// 物理地址 / MAC（等同 `macAddress`）
    var 物理地址: String? { macAddress }
    /// 是否已启用（等同 `isUp`）
    var 已启用: Bool { isUp }
    /// 是否回环接口（等同 `isLoopback`）
    var 是否回环: Bool { isLoopback }
}
