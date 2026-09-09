import Foundation
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
    public static let version = "0.2.0"

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
