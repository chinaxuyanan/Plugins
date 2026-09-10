import Foundation
import Dispatch

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
    /// 当前进程 CPU 架构（等同 `cpuArchitecture`）
    static var CPU架构: String { cpuArchitecture }

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

    /// 重要用途可用容量字节（等同 `availableCapacityBytes`）
    static var 可用容量字节数: UInt64 { availableCapacityBytes }
    /// 重要用途可用容量（等同 `availableCapacity`）
    static var 可用容量: String { availableCapacity }
    /// 机会性可用容量字节（等同 `opportunisticCapacityBytes`）
    static var 机会容量字节数: UInt64 { opportunisticCapacityBytes }
    /// 机会性可用容量（等同 `opportunisticCapacity`）
    static var 机会容量: String { opportunisticCapacity }
    /// 主卷名（等同 `volumeName`）
    static var 卷名: String { volumeName }
    /// 文件系统类型（等同 `fileSystemName`）
    static var 文件系统名称: String { fileSystemName }

    /// 电池电量（等同 `batteryLevel`）
    static var 电池电量: Float? { batteryLevel }
    /// 是否正在充电（等同 `isCharging`）
    static var 是否充电: Bool? { isCharging }
    /// 电池循环次数（等同 `batteryCycleCount`，仅 macOS）
    static var 电池循环次数: Int? { batteryCycleCount }
    /// 电池健康度（等同 `batteryHealthPercent`，`0.0`~`1.0`，仅 macOS）
    static var 电池健康度: Double? { batteryHealthPercent }
    /// 电池健康（等同 `batteryHealth`，人类可读，形如 `98%`）
    static var 电池健康: String { batteryHealth }
    /// 设备热状态（等同 `thermalState`）
    static var 热状态: ProcessInfo.ThermalState { thermalState }
    /// 热状态中文名（等同 `thermalStateName`）
    static var 热状态名: String { thermalStateName }
    /// 是否开启低功耗模式（等同 `isLowPowerModeEnabled`，仅 iOS）
    static var 低功耗模式: Bool { isLowPowerModeEnabled }

    /// 屏幕分辨率（等同 `screenSize`）
    static var 屏幕分辨率: String { screenSize }
    /// 屏幕缩放因子（等同 `screenScale`）
    static var 屏幕缩放: CGFloat { screenScale }
    /// 显示器数量（等同 `displayCount`）
    static var 显示器数量: Int { displayCount }
    /// 各显示器分辨率（等同 `displayResolutions`）
    static var 显示器分辨率: [String] { displayResolutions }
    /// 各显示器缩放因子（等同 `displayScales`）
    static var 显示器缩放: [CGFloat] { displayScales }

    /// 系统运行秒数（等同 `systemUptime`）
    static var 系统运行秒数: TimeInterval { systemUptime }
    /// 系统运行时长（等同 `systemUptimeString`）
    static var 系统运行时长: String { systemUptimeString }
    /// 系统本次开机时间点（等同 `bootTime`）
    static var 系统启动时间: Date { bootTime }
    /// 系统本次开机时间字符串（等同 `bootTimeString`）
    static var 系统启动时间字符串: String { bootTimeString }
    /// 是否模拟器（等同 `isSimulator`）
    static var 是否模拟器: Bool { isSimulator }

    /// App 显示名称（等同 `appName`）
    static var 应用名称: String { appName }
    /// App 版本号（等同 `appVersion`）
    static var 应用版本: String { appVersion }
    /// App 构建号（等同 `appBuildNumber`）
    static var 应用构建号: String { appBuildNumber }

    // MARK: 网络信息

    /// 本机局域网 IP 地址（等同 `localIPAddress`）
    static var 本机IP地址: String? { localIPAddress }
    /// 是否接入网络（等同 `isNetworkConnected`）
    static var 是否联网: Bool { isNetworkConnected }
    /// 网络类型（等同 `networkType`，近似判断）
    static var 网络类型: String? { networkType }
    /// Wi-Fi 信号强度（等同 `wifiSignalStrength`，仅 macOS）
    static var WiFi信号强度: Int? { wifiSignalStrength }
    /// Wi-Fi 信号强度中文名（等同 `wifiSignalStrengthName`）
    static var WiFi信号强度名: String { wifiSignalStrengthName }
    /// DNS 服务器列表（等同 `dnsServers`，仅 macOS）
    static var DNS服务器: [String] { dnsServers }
    /// 默认网关（等同 `defaultGateway`，仅 macOS）
    static var 默认网关: String? { defaultGateway }
    /// 公网 IP 地址（等同 `publicIPAddress`，异步请求，失败抛错）
    static func 公网IP地址() async throws -> String {
        try await publicIPAddress()
    }

    // MARK: 本地化信息

    /// 当前语言代码（等同 `languageCode`）
    static var 语言代码: String { languageCode }
    /// 当前区域代码（等同 `regionCode`）
    static var 区域代码: String { regionCode }
    /// 完整地区标识（等同 `localeIdentifier`）
    static var 地区标识: String { localeIdentifier }
    /// 当前时区标识（等同 `timeZoneIdentifier`）
    static var 时区标识: String { timeZoneIdentifier }
    /// 当前日历标识（等同 `calendarIdentifier`）
    static var 日历标识: String { calendarIdentifier }

    // MARK: 资源占用

    /// CPU 使用率（等同 `cpuUsage`，调用会阻塞约 100ms 采样）
    static var CPU使用率: Double { cpuUsage }
    /// 内存已用容量字节（等同 `memoryUsedBytes`）
    static var 内存已用字节数: UInt64 { memoryUsedBytes }
    /// 内存已用容量（等同 `memoryUsed`）
    static var 内存已用: String { memoryUsed }
    /// 内存使用率（等同 `memoryUsagePercent`）
    static var 内存使用率: Double { memoryUsagePercent }
    /// 当前进程 CPU 使用率（等同 `processCPUUsage`）
    static var 进程CPU使用率: Double { processCPUUsage }
    /// 当前进程内存占用字节（等同 `processMemoryBytes`）
    static var 进程内存字节数: UInt64 { processMemoryBytes }
    /// 当前进程内存占用（等同 `processMemory`）
    static var 进程内存: String { processMemory }
    /// 当前内存压力（等同 `memoryPressure`，仅 macOS）
    static var 内存压力: DispatchSource.MemoryPressureEvent? { memoryPressure }
    /// 内存压力中文名（等同 `memoryPressureName`）
    static var 内存压力名: String { memoryPressureName }
    /// 当前进程可用内存字节（等同 `availableMemoryBytes`）
    static var 可用内存字节数: UInt64? { availableMemoryBytes }
    /// 当前进程可用内存（等同 `availableMemory`）
    static var 可用内存: String { availableMemory }
    /// 系统负载（等同 `loadAverage`，1/5/15 分钟三值）
    static var 系统负载: [Double] { loadAverage }
    /// 1 分钟平均负载（等同 `loadAverage1Min`）
    static var 负载1分钟: Double { loadAverage1Min }
    /// 5 分钟平均负载（等同 `loadAverage5Min`）
    static var 负载5分钟: Double { loadAverage5Min }
    /// 15 分钟平均负载（等同 `loadAverage15Min`）
    static var 负载15分钟: Double { loadAverage15Min }

    // MARK: 网络流量与磁盘读写

    /// 采样网络流量（等同 `sampleNetworkTraffic`）
    static func 采样网络流量() -> NetworkTraffic? {
        sampleNetworkTraffic()
    }
    /// 采样磁盘读写（等同 `sampleDiskIOTraffic`，仅 macOS）
    static func 采样磁盘读写() -> DiskIOTraffic? {
        sampleDiskIOTraffic()
    }
}
