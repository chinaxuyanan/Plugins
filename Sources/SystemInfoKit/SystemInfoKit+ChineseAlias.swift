import Foundation

// MARK: - 中文命名别名
//
// 为每个英文属性提供中文命名的别名，让开发者在输入 `SystemInfoKit.` 触发自动补全时，
// 直接在候选列表里看到中文属性名，见名即用。每个中文别名等价转发到对应英文属性。

public extension SystemInfoKit {

    /// 系统名称（等同 `systemName`）
    static var 系统名称: String { systemName }
    /// 系统版本号（等同 `systemVersion`）
    static var 系统版本: String { systemVersion }
    /// 系统完整版本字符串（等同 `systemVersionString`）
    static var 系统完整版本: String { systemVersionString }

    /// 设备标识符（等同 `deviceIdentifier`）
    static var 设备标识符: String { deviceIdentifier }
    /// 设备名称（等同 `deviceName`）
    static var 设备名称: String { deviceName }
    /// 设备类型（等同 `deviceType`）
    static var 设备类型: String { deviceType }

    /// 物理内存总量字节（等同 `memoryTotalBytes`）
    static var 内存总字节数: UInt64 { memoryTotalBytes }
    /// 物理内存总量（等同 `memoryTotal`）
    static var 内存总量: String { memoryTotal }
    /// 处理器逻辑核心数（等同 `processorCount`）
    static var 处理器核心数: Int { processorCount }
    /// 处理器可用核心数（等同 `activeProcessorCount`）
    static var 处理器可用核心数: Int { activeProcessorCount }
    /// 处理器型号（等同 `processorName`）
    static var 处理器型号: String? { processorName }

    /// 磁盘总容量字节（等同 `diskTotalBytes`）
    static var 磁盘总字节数: UInt64 { diskTotalBytes }
    /// 磁盘剩余容量字节（等同 `diskFreeBytes`）
    static var 磁盘剩余字节数: UInt64 { diskFreeBytes }
    /// 磁盘总容量（等同 `diskTotal`）
    static var 磁盘总容量: String { diskTotal }
    /// 磁盘剩余容量（等同 `diskFree`）
    static var 磁盘剩余容量: String { diskFree }
    /// 磁盘已用容量字节（等同 `diskUsedBytes`）
    static var 磁盘已用字节数: UInt64 { diskUsedBytes }
    /// 磁盘已用容量（等同 `diskUsed`）
    static var 磁盘已用: String { diskUsed }
    /// 磁盘使用率（等同 `diskUsagePercent`）
    static var 磁盘使用率: Double { diskUsagePercent }

    /// 电池电量（等同 `batteryLevel`）
    static var 电池电量: Float? { batteryLevel }
    /// 是否正在充电（等同 `isCharging`）
    static var 是否充电: Bool? { isCharging }

    /// 屏幕分辨率（等同 `screenSize`）
    static var 屏幕分辨率: String { screenSize }
    /// 屏幕缩放因子（等同 `screenScale`）
    static var 屏幕缩放: CGFloat { screenScale }

    /// 系统运行秒数（等同 `systemUptime`）
    static var 系统运行秒数: TimeInterval { systemUptime }
    /// 系统运行时长（等同 `systemUptimeString`）
    static var 系统运行时长: String { systemUptimeString }
    /// 是否模拟器（等同 `isSimulator`）
    static var 是否模拟器: Bool { isSimulator }

    /// App 显示名称（等同 `appName`）
    static var 应用名称: String { appName }
    /// App 版本号（等同 `appVersion`）
    static var 应用版本: String { appVersion }
    /// App 构建号（等同 `appBuildNumber`）
    static var 应用构建号: String { appBuildNumber }
}
