import Foundation
import Darwin
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
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
    public static let version = "0.1.0"

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

    // MARK: - 电池（仅 iOS 支持）

    /// 电池电量（`0.0` ~ `1.0`；未知或不支持时返回 `nil`，macOS 暂不支持）
    public static var batteryLevel: Float? {
        #if canImport(UIKit)
        UIDevice.current.isBatteryMonitoringEnabled = true
        let level = UIDevice.current.batteryLevel
        return level < 0 ? nil : level
        #else
        return nil
        #endif
    }

    /// 是否正在充电（未知或不支持时返回 `nil`，macOS 暂不支持）
    public static var isCharging: Bool? {
        #if canImport(UIKit)
        UIDevice.current.isBatteryMonitoringEnabled = true
        switch UIDevice.current.batteryState {
        case .charging, .full: return true
        case .unplugged: return false
        case .unknown: return nil
        @unknown default: return nil
        }
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
}
