# SystemInfoKit —— 中文友好的系统检测工具库

[![CI](https://github.com/chinaxuyanan/Plugins/actions/workflows/ci.yml/badge.svg?branch=main&label=Plugins%20CI)](https://github.com/chinaxuyanan/Plugins/actions/workflows/ci.yml)

> 解决「查系统信息要记各种零散 API」的痛点。
> 把系统版本、设备型号、硬件、屏幕、电池等常用检测项集中封装，全部属性带中文别名。

## 特性

- **系统信息**：系统名称 / 版本号 / 完整版本
- **设备信息**：标识符 / 名称 / 类型 / 友好型号名（`deviceModelName`，内置标识符→机型对照表，可自行增补）
- **硬件信息**：内存 / 处理器 / 磁盘（含已用 / 使用率）+ CPU 架构
- **存储详情**：重要用途可用容量 / 机会性可用容量 / 卷名 / 文件系统类型
- **电池**：电量 / 是否充电 / 循环次数 / 健康度（iOS + macOS，循环次数与健康度仅 macOS）/ 细分状态 `batteryState` + `batteryStateName`（充电中 / 已充满 / 未接电源 / 未知）/ 电池温度 `batteryTemperature` + `batteryTemperatureText`（仅 macOS，读 IOKit `AppleSmartBattery` 的 `Temperature`）/ 电源适配器明细 `powerAdapter` + `powerAdapterText`（`PowerAdapter` / `电源适配器`：功率 / 协商电压 / 协商电流，仅 macOS，未接电源时为 `nil`）/ 供电来源 `powerSourceName`（交流电源 / 电池）
- **热状态与电源**：热状态 / 低功耗模式（低功耗仅 iOS）
- **屏幕与显示器**：分辨率 / 缩放因子 / 显示器数量 / 各显示器分辨率与缩放 / 是否深色模式 / 屏幕亮度（macOS）
- **刷新率与无障碍**：屏幕最大刷新率 `maximumFramesPerSecond` / 减弱动态效果 `isReduceMotionEnabled` / 降低透明度 `isReduceTransparencyEnabled` / 粗体文本 `isBoldTextEnabled`（仅 iOS）/ 无障碍设置摘要 `accessibilitySummary`
- **运行信息**：运行时长 / 启动时间 / 是否模拟器
- **App 信息**：名称 / 版本 / 构建号 / 包标识符 `bundleIdentifier` / 团队 ID `teamIdentifier` / 是否 TestFlight `isTestFlight` / 已安装应用列表 `installedApplications` + `installedApplicationCount`（`InstalledApplication` / `已安装应用`：名称 / 标识符 / 版本 / 路径，仅 macOS，扫 `/Applications` 与 `/System/Applications`）
- **网络信息**：本机 IP / 是否联网 / 网络类型 / Wi-Fi 名称（macOS）/ Wi-Fi 信号强度（macOS）/ 是否走系统代理 `isUsingProxy` + 代理描述 `proxyDescription` / DNS / 默认网关（macOS）/ 公网 IP（异步）
- **本地化信息**：语言 / 区域 / 地区 / 时区 / 日历
- **资源占用**：CPU 使用率 / 每核 CPU 使用率 `perCoreCPUUsage` + `perCoreCPUUsageText`（逐核采样，下标即核序号）/ 内存已用 / 内存使用率 / 可用内存 / 内存压力（macOS）
- **内存明细**：`memoryBreakdown` / `内存明细` 把内存拆成活跃 / 非活跃 / 联动 / 压缩 / 可丢弃 / 预读（`MemoryBreakdown` / `内存明细` 结构体，含各分项人类可读文本与中文摘要）
- **系统负载**：1 / 5 / 15 分钟平均负载（`getloadavg`）
- **网络流量统计**：`sampleNetworkTraffic()` 采样活跃接口累计收发字节 + 每秒速率
- **磁盘读写速率**：`sampleDiskIOTraffic()` 汇总块存储驱动累计读写字节 + 每秒速率（仅 macOS）
- **运行进程**：`runningProcesses` / `processCount` 枚举内核进程表（`sysctl(KERN_PROC)`，含 pid 与进程名）
- **进程占用排行**：`topProcesses(by:limit:)` / `进程排行(依据:数量:)` 按常驻内存或平均 CPU 排行 Top N（`proc_pidinfo`，仅 macOS，含 `ProcessUsage` / `进程占用` 结构体）
- **交换内存**：`swapTotalBytes` / `swapUsedBytes` / `swapTotal` / `swapUsed`（仅 macOS，`vm.swapusage`）
- **网络接口**：`networkInterfaces` 枚举所有网络接口（名称 + IPv4 + 物理地址 / MAC + 是否启用 / 是否回环），另有 `primaryMACAddress` / `主网卡物理地址` 取主网卡 MAC
- **存储卷列表**：`mountedVolumes` 枚举已挂载存储卷（卷名 / 路径 / 总容量 / 可用容量 / 是否可移除 / 是否内置），另有 `removableVolumes` 只看可移除设备
- **本进程信息**：当前进程 CPU 使用率 / 内存占用
- **运行环境**：内核版本 / 主机名 / 当前用户名 / 是否被调试器附加（`uname` + `sysctl(P_TRACED)`）
- **内存压力监听**：`MemoryPressureMonitor` 实时回调压力变化（仅 macOS）
- **信息快照**：`snapshot()` / `信息快照()` 一次性取出全部常用检测项为 `[String: String]`，值均为字符串，可直接 JSON 序列化上报
- **中文别名**：`SystemInfoKit.系统版本` 等，与英文属性一一等价
- **纯 Foundation + Darwin 系统接口**，iOS 15+ / macOS 12+

## 安装

本库是 [Plugins](../README.md) monorepo 里的一个包，和 `SwiftUIProKit`、`LogKit` 并排放在同一个仓库中。把仓库 clone 到本地，用**本地路径依赖**引入：

```swift
dependencies: [
    .package(path: "../Plugins/SystemInfoKit")
]
```

然后在目标中 `import SystemInfoKit`。

> **为什么不是 `.package(url: "...", from: "1.4.0")`？** SwiftPM 要求 `Package.swift` 位于仓库根目录，且不支持带前缀的版本 tag，所以没法从远端直接解析子目录里的这个包（官方 issue：[#5768](https://github.com/swiftlang/swift-package-manager/issues/5768)、[#5780](https://github.com/swiftlang/swift-package-manager/issues/5780)）。如果需要「按版本从远端依赖」，在仓库根目录加一个 `Package.swift` 把三个库收成三个 product 即可，详见 [Plugins/README.md](../README.md)。

## 快速开始

```swift
import SystemInfoKit

SystemInfoKit.系统名称       // "macOS"
SystemInfoKit.系统版本       // "13.5.2"
SystemInfoKit.系统完整版本   // "Version 13.5.2 (Build 22G91)"
SystemInfoKit.设备标识符     // "MacBookPro18,1"
SystemInfoKit.内存总量       // "16 GB"
SystemInfoKit.磁盘剩余容量   // "120 GB"
SystemInfoKit.屏幕分辨率     // "1512×982"
```

## 属性速查表

| 属性 | 中文含义 | 说明 |
| --- | --- | --- |
| `systemName` | 系统名称 | `macOS` / `iOS` |
| `systemVersion` | 系统版本号 | 形如 `13.5.2` |
| `systemVersionString` | 系统完整版本 | 含 Build 号 |
| `deviceIdentifier` | 设备标识符 | 形如 `MacBookPro18,1` |
| `deviceName` | 设备名称 | 用户命名 / 主机名 |
| `deviceType` | 设备类型 | `iPhone` / `iPad` / `Mac` |
| `deviceModelName` | 当前设备友好型号名 | 由 `deviceIdentifier` 查 `deviceModelTable` |
| `deviceModelTable` | 标识符 → 友好型号名对照表 | `[String: String]`，可自行增补新机型 |
| `deviceModelName(for:)` | 标识符转友好型号名 | 未收录的标识符原样返回 |
| `memoryTotalBytes` | 内存总量（字节） | `UInt64` |
| `memoryTotal` | 内存总量 | 形如 `16 GB` |
| `processorCount` | 处理器逻辑核心数 | `Int` |
| `activeProcessorCount` | 处理器可用核心数 | `Int` |
| `processorName` | 处理器型号 | 仅 macOS |
| `cpuArchitecture` | CPU 架构 | `arm64` / `x86_64` |
| `diskTotalBytes` / `diskFreeBytes` | 磁盘总 / 剩余（字节） | `UInt64` |
| `diskTotal` / `diskFree` | 磁盘总 / 剩余 | 人类可读 |
| `diskUsedBytes` / `diskUsed` | 磁盘已用（字节 / 可读） | `UInt64` / 人类可读 |
| `diskUsagePercent` | 磁盘使用率 | `0.0`~`1.0` |
| `availableCapacityBytes` / `availableCapacity` | 重要用途可用容量（字节 / 可读） | 计入可清除空间 |
| `opportunisticCapacityBytes` / `opportunisticCapacity` | 机会性可用容量（字节 / 可读） | 可清理出的空间 |
| `volumeName` | 主卷名 | 形如 `Macintosh HD` |
| `fileSystemName` | 文件系统类型 | 形如 `APFS` |
| `batteryLevel` | 电池电量 | `0.0`~`1.0`，iOS + macOS |
| `isCharging` | 是否充电 | iOS + macOS |
| `batteryCycleCount` | 电池循环次数 | `Int?`，仅 macOS |
| `batteryHealthPercent` | 电池健康度 | `Double?`，`0.0`~`1.0`，仅 macOS |
| `batteryHealth` | 电池健康 | 人类可读，形如 `98%`，非 macOS 返回「不支持」 |
| `batteryState` | 电池细分状态 | `BatteryState`，充电中 / 已充满 / 未接电源 / 未知，双平台 |
| `batteryStateName` | 电池细分状态中文名 | 形如 `充电中` |
| `batteryTemperature` / `batteryTemperatureText` | 电池温度（度 / 文本） | `Double?` / `String`，仅 macOS，读 IOKit `AppleSmartBattery`，读不到为「不支持」|
| `powerSourceName` | 供电来源中文名 | `交流电源` / `电池` / `不支持`（台式机）|
| `powerAdapter` / `powerAdapterText` | 电源适配器明细（对象 / 文本） | `PowerAdapter?`，仅 macOS，**未接电源时为 `nil`** |
| `thermalState` | 设备热状态 | `ProcessInfo.ThermalState` |
| `thermalStateName` | 热状态中文名 | 正常 / 尚可 / 严重 / 危急 |
| `isLowPowerModeEnabled` | 低功耗模式 | 仅 iOS |
| `screenSize` | 屏幕分辨率 | 逻辑点 |
| `screenScale` | 屏幕缩放因子 | `1.0` / `2.0` / `3.0` |
| `displayCount` | 显示器数量 | 内置 + 外接屏 |
| `displayResolutions` | 各显示器分辨率 | `[String]`，逻辑点 |
| `displayScales` | 各显示器缩放因子 | `[CGFloat]` |
| `isDarkMode` | 是否深色模式 | `Bool`，双平台 |
| `screenBrightness` | 屏幕亮度 | `Double?`，`0.0`~`1.0`，仅 macOS（无权限 / 取不到为 `nil`）|
| `maximumFramesPerSecond` | 屏幕最大刷新率 | `Int`，Hz（`60` / `120`）|
| `isReduceMotionEnabled` | 是否减弱动态效果 | `Bool`，双平台 |
| `isReduceTransparencyEnabled` | 是否降低透明度 | `Bool`，双平台 |
| `isBoldTextEnabled` | 是否粗体文本 | `Bool`，仅 iOS（macOS 恒 `false`）|
| `accessibilitySummary` | 无障碍设置摘要 | 形如 `减弱动态效果 · 降低透明度`，都没开启为 `无` |
| `mountedVolumes` | 已挂载存储卷列表 | `[MountedVolume]`，按卷名升序 |
| `mountedVolumeCount` | 已挂载存储卷数量 | `Int` |
| `removableVolumes` | 可移除存储卷列表 | `[MountedVolume]`，U 盘 / 存储卡 / 外接盘 |
| `systemUptime` | 系统运行时长（秒） | `TimeInterval` |
| `systemUptimeString` | 系统运行时长 | 形如 `3 天 5 小时` |
| `bootTime` | 系统启动时间 | `Date` |
| `bootTimeString` | 系统启动时间（可读） | 形如 `2026-09-08 14:30:00` |
| `isSimulator` | 是否模拟器 | `Bool` |
| `appName` | App 显示名称 | `String` |
| `appVersion` / `appBuildNumber` | App 版本 / 构建号 | `String` |
| `bundleIdentifier` | App 包标识符 | 形如 `com.example.app` |
| `teamIdentifier` | 签名团队 ID | `String?`，读 Info.plist / 内嵌描述文件，取不到为 `nil` |
| `isTestFlight` | 是否 TestFlight 安装 | `Bool`，收据为 `sandboxReceipt` 即内测包 |
| `installedApplications` / `installedApplicationCount` | 已安装应用列表 / 数量 | `[InstalledApplication]` / `Int`，仅 macOS，扫 `/Applications` 与 `/System/Applications`，按名称升序 |
| `localIPAddress` | 本机局域网 IP | `String?` |
| `isNetworkConnected` | 是否联网 | `Bool` |
| `networkType` | 网络类型 | `String?` |
| `wifiSSID` | 当前 Wi-Fi 名称 | `String?`，仅 macOS |
| `wifiSignalStrength` | Wi-Fi 信号强度（RSSI） | `Int?`，仅 macOS |
| `wifiSignalStrengthName` | Wi-Fi 信号强度中文名 | 强 / 中 / 弱 / 不支持 |
| `isUsingProxy` | 是否走系统代理 | `Bool`，`CFNetworkCopySystemProxySettings` |
| `proxyDescription` | 系统代理描述 | `String?`，形如 `HTTPS 代理 127.0.0.1:8080` |
| `dnsServers` | DNS 服务器 | `[String]`，仅 macOS |
| `defaultGateway` | 默认网关 | `String?`，仅 macOS |
| `publicIPAddress()` | 公网 IP | `async throws`，请求 api.ipify.org |
| `languageCode` / `regionCode` | 语言 / 区域代码 | `String` |
| `localeIdentifier` | 完整地区标识 | `String` |
| `timeZoneIdentifier` / `calendarIdentifier` | 时区 / 日历标识 | `String` |
| `cpuUsage` | CPU 使用率 | `0.0`~`1.0` |
| `perCoreCPUUsage` / `perCoreCPUUsageText` | 每核 CPU 使用率（数组 / 单行文本） | `[Double]`，下标即核序号；调用阻塞约 100ms 采样 |
| `memoryUsedBytes` / `memoryUsed` | 内存已用（字节 / 可读） | `UInt64` / 人类可读 |
| `memoryUsagePercent` | 内存使用率 | `0.0`~`1.0` |
| `memoryPressure` | 内存压力 | 仅 macOS |
| `memoryPressureName` | 内存压力中文名 | 正常 / 警告 / 严重 / 不支持 |
| `availableMemoryBytes` / `availableMemory` | 可用内存（字节 / 可读） | `UInt64?` / 人类可读 |
| `memoryBreakdown` | 内存明细 | `MemoryBreakdown?`，拆出活跃 / 非活跃 / 联动 / 压缩 / 可丢弃 / 预读 |
| `loadAverage` | 系统负载 | `[Double]`，1/5/15 分钟三值 |
| `loadAverage1Min` / `loadAverage5Min` / `loadAverage15Min` | 1/5/15 分钟负载 | `Double` |
| `sampleNetworkTraffic()` | 采样网络流量 | `NetworkTraffic?`，累计收发字节 + 每秒速率（首次速率 `nil`）|
| `sampleDiskIOTraffic()` | 采样磁盘读写 | `DiskIOTraffic?`，累计读写字节 + 每秒速率（仅 macOS，首次速率 `nil`）|
| `processCPUUsage` | 当前进程 CPU 使用率 | 相对单核，多线程可 >`1.0` |
| `processMemoryBytes` / `processMemory` | 当前进程内存占用（字节 / 可读） | `UInt64` / 人类可读 |
| `runningProcesses` / `processCount` | 运行进程列表 / 数量 | `[RunningProcess]` / `Int`，`sysctl(KERN_PROC)` |
| `topProcesses(by:limit:)` | 进程占用排行 Top N | `[ProcessUsage]`，按 `.memory`（常驻内存）/ `.cpu`（平均 CPU）排序，仅 macOS（`proc_pidinfo`，iOS 返回空）|
| `swapTotalBytes` / `swapUsedBytes` | 交换内存总 / 已用（字节） | `UInt64?`，仅 macOS |
| `swapTotal` / `swapUsed` | 交换内存总 / 已用（可读） | 非 macOS 返回「不支持」 |
| `networkInterfaces` | 网络接口列表 | `[NetworkInterface]`，`getifaddrs`（含物理地址 / MAC）|
| `primaryMACAddress` | 主网卡物理地址 / MAC | `String?`，优先 `en0`，形如 `A4:83:E7:12:34:56` |
| `kernelVersion` | 内核版本 | `uname` 的 release，形如 `23.5.0` |
| `hostName` | 主机名 | `ProcessInfo.hostName` |
| `userName` | 当前用户名 | `NSUserName()` |
| `isDebuggerAttached` | 是否被调试器附加 | `Bool`，`sysctl` 读 `P_TRACED` 标志 |
| `snapshot()` | 信息快照 | `[String: String]`，一次性取出全部常用检测项，值均为字符串，可直接 JSON 序列化 |
| `MemoryPressureMonitor` | 内存压力监听器 | 实时回调，仅 macOS |
| `MountedVolume` | 存储卷 | 卷名 / 路径 / 总容量 / 可用容量 / 已用占比 / 是否可移除 / 是否内置 |
| `MemoryBreakdown` | 内存明细 | 总容量 / 空闲 / 活跃 / 非活跃 / 联动 / 压缩 / 可丢弃 / 预读，含各分项可读文本与中文摘要 |
| `InstalledApplication` | 已安装应用 | 名称 / 标识符 / 版本 / 路径，仅 macOS |
| `PowerAdapter` | 电源适配器 | 功率 / 协商电压 / 协商电流 / 标识，仅 macOS |

## 中文命名别名

| 中文别名 | 等同英文属性 |
| --- | --- |
| `系统名称` / `系统版本` / `系统完整版本` | `systemName` / `systemVersion` / `systemVersionString` |
| `设备标识符` / `设备名称` / `设备类型` | `deviceIdentifier` / `deviceName` / `deviceType` |
| `设备型号名称` / `设备型号名称(标识符:)` / `设备型号对照表` | `deviceModelName` / `deviceModelName(for:)` / `deviceModelTable` |
| `内存总量` / `处理器核心数` / `处理器型号` / `CPU架构` | `memoryTotal` / `processorCount` / `processorName` / `cpuArchitecture` |
| `磁盘总容量` / `磁盘剩余容量` / `磁盘已用` / `磁盘使用率` | `diskTotal` / `diskFree` / `diskUsed` / `diskUsagePercent` |
| `可用容量` / `机会容量` / `卷名` / `文件系统名称` | `availableCapacity` / `opportunisticCapacity` / `volumeName` / `fileSystemName` |
| `电池电量` / `是否充电` / `热状态` / `热状态名` / `低功耗模式` | `batteryLevel` / `isCharging` / `thermalState` / `thermalStateName` / `isLowPowerModeEnabled` |
| `电池循环次数` / `电池健康度` / `电池健康` | `batteryCycleCount` / `batteryHealthPercent` / `batteryHealth` |
| `电池状态` / `电池状态名` | `batteryState` / `batteryStateName`（`.充电中/.已充满/.未接电源/.未知`）|
| `电池温度` / `电池温度文本` / `供电来源` | `batteryTemperature` / `batteryTemperatureText` / `powerSourceName` |
| `电源适配器` / `电源适配器文本` | `powerAdapter` / `powerAdapterText` |
| `屏幕分辨率` / `屏幕缩放` / `显示器数量` / `显示器分辨率` / `显示器缩放` | `screenSize` / `screenScale` / `displayCount` / `displayResolutions` / `displayScales` |
| `深色模式` / `屏幕亮度` | `isDarkMode` / `screenBrightness` |
| `系统运行时长` / `系统启动时间` / `是否模拟器` | `systemUptimeString` / `bootTime` / `isSimulator` |
| `应用名称` / `应用版本` / `应用构建号` | `appName` / `appVersion` / `appBuildNumber` |
| `本机IP地址` / `是否联网` / `网络类型` / `WiFi信号强度` / `WiFi信号强度名` | `localIPAddress` / `isNetworkConnected` / `networkType` / `wifiSignalStrength` / `wifiSignalStrengthName` |
| `DNS服务器` / `默认网关` / `公网IP地址()` | `dnsServers` / `defaultGateway` / `publicIPAddress()` |
| `语言代码` / `区域代码` / `地区标识` | `languageCode` / `regionCode` / `localeIdentifier` |
| `时区标识` / `日历标识` | `timeZoneIdentifier` / `calendarIdentifier` |
| `CPU使用率` / `内存已用` / `内存使用率` / `进程CPU使用率` / `进程内存` / `内存压力` / `内存压力名` | `cpuUsage` / `memoryUsed` / `memoryUsagePercent` / `processCPUUsage` / `processMemory` / `memoryPressure` / `memoryPressureName` |
| `每核CPU使用率` / `每核CPU使用率文本` | `perCoreCPUUsage` / `perCoreCPUUsageText` |
| `可用内存` / `内存压力监听器` / `内存明细` | `availableMemory` / `MemoryPressureMonitor`（`.当前压力/.压力变化回调/.开始监听/.停止监听`）/ `memoryBreakdown` |
| `系统负载` / `负载1分钟` / `负载5分钟` / `负载15分钟` | `loadAverage` / `loadAverage1Min` / `loadAverage5Min` / `loadAverage15Min` |
| `采样网络流量()` / `采样磁盘读写()` | `sampleNetworkTraffic()` / `sampleDiskIOTraffic()` |
| `网络流量` / `磁盘读写` | `NetworkTraffic` / `DiskIOTraffic`（类型别名）|
| `运行进程列表` / `运行进程数量` | `runningProcesses` / `processCount` |
| `进程排行(依据:数量:)` | `topProcesses(by:limit:)`（依据 `.内存` / `.CPU`）|
| `交换内存总字节数` / `交换内存已用字节数` | `swapTotalBytes` / `swapUsedBytes` |
| `交换内存总量` / `交换内存已用` | `swapTotal` / `swapUsed` |
| `网络接口列表` / `主网卡物理地址` | `networkInterfaces` / `primaryMACAddress` |
| `运行进程` / `网络接口` / `进程占用` / `电池状态` / `进程排序依据` | `RunningProcess` / `NetworkInterface` / `ProcessUsage` / `BatteryState` / `ProcessSortKey`（类型别名）|
| `内存明细` / `已安装应用` / `电源适配器` | `MemoryBreakdown` / `InstalledApplication` / `PowerAdapter`（类型别名）|
| `内核版本` / `主机名` / `当前用户名` / `是否被调试` | `kernelVersion` / `hostName` / `userName` / `isDebuggerAttached` |
| `最大刷新率` / `减弱动态效果` / `降低透明度` / `粗体文本` / `无障碍摘要` | `maximumFramesPerSecond` / `isReduceMotionEnabled` / `isReduceTransparencyEnabled` / `isBoldTextEnabled` / `accessibilitySummary` |
| `存储卷列表` / `存储卷数量` / `可移除存储卷列表` | `mountedVolumes` / `mountedVolumeCount` / `removableVolumes` |
| `包标识符` / `团队ID` / `是否TestFlight` | `bundleIdentifier` / `teamIdentifier` / `isTestFlight` |
| `已安装应用列表` / `已安装应用数量` | `installedApplications` / `installedApplicationCount` |
| `WiFi名称` / `是否走代理` / `代理描述` | `wifiSSID` / `isUsingProxy` / `proxyDescription` |
| `存储卷` | `MountedVolume`（`.名称/.路径/.总容量/.可用容量/.是否可移除/.是否内置/.已用字节数/.已用占比/.已用占比文本/.总容量文本/.已用文本/.可用文本/.类型名`）|
| `信息快照()` | `snapshot()` |

## 更新日志

- **版本号规则变更（自 1.4.0 起）**：版本号改为「满十进位式」——次版本满 10 就进位到主版本。按此规则，`0.13.0` 的下一版写作 `1.4.0`（而不是 `0.14.0`）。此前已发布的 `0.x` tag 原样保留，上面的旧条目也保持原编号。

- **1.4.0**：新增内存明细（`memoryBreakdown` / `内存明细`，用 `host_statistics64` 的 `vm_statistics64` 把内存拆成活跃 / 非活跃 / 联动（wired）/ 压缩 / 可丢弃 / 预读，含 `MemoryBreakdown` / `内存明细` 结构体与各分项人类可读文本、中文多行摘要；可用内存 = 空闲 + 非活跃 + 可丢弃 + 预读，与 `availableMemoryBytes` 同口径）、每核 CPU 使用率（`perCoreCPUUsage` / `每核CPU使用率` 与 `perCoreCPUUsageText` / `每核CPU使用率文本`，`PROCESSOR_CPU_LOAD_INFO` 逐核采样 100ms 求差值，下标即核序号）、已安装应用列表（`installedApplications` / `已安装应用列表` 与 `installedApplicationCount` / `已安装应用数量`，扫 `/Applications` 与 `/System/Applications` 顶层的 `.app`，含 `InstalledApplication` / `已安装应用` 结构体：名称 / 标识符 / 版本 / 路径，按名称升序，仅 macOS）、电池温度与电源明细（`batteryTemperature` / `电池温度` 与 `batteryTemperatureText`，读 IOKit `AppleSmartBattery` 的 `Temperature`；`powerSourceName` / `供电来源`；`powerAdapter` / `电源适配器` 与 `powerAdapterText`，读 `IOPSCopyExternalPowerAdapterDetails()` 得到功率 / 协商电压 / 协商电流，含 `PowerAdapter` / `电源适配器` 结构体，未接电源为 `nil`；均仅 macOS），并把 `memoryStats()` 改为委托 `memoryBreakdownStats()`，让 `memoryUsedBytes` / `memoryUsagePercent` 与 `memoryBreakdown` 不可能出现口径分叉。

- **0.13.0**：新增电池细分状态（`batteryState` / `电池状态`，iOS 用 `UIDevice.batteryState`、macOS 用 `IOPSCopyPowerSourcesInfo`，把「接着电源且已充满」与「正在充电」区分开，区分于只回答「有没有接电源」的 `isCharging`；配 `batteryStateName` / `电池状态名`，枚举 `BatteryState` / `电池状态` 含中文静态别名 `充电中` / `已充满` / `未接电源` / `未知`，`snapshot()` 同步补入 `batteryState`）、进程占用排行（`topProcesses(by:limit:)` / `进程排行(依据:数量:)`，按常驻内存 / 平均 CPU 排行 Top N，用 `proc_pidinfo(PROC_PIDTASKINFO / PROC_PIDTBSDINFO)` 读 RSS 与累计 CPU 时间，含 `ProcessUsage` / `进程占用` 结构体与 `ProcessSortKey` / `进程排序依据` 枚举，仅 macOS、iOS 返回空）、网卡物理地址（`NetworkInterface` 新增 `macAddress` / `物理地址` 字段，从 `getifaddrs` 的 `AF_LINK` `sockaddr_dl` 解析 MAC；另有 `primaryMACAddress` / `主网卡物理地址` 优先取 `en0`），均含中文别名并补冒烟测试。

- **0.12.0**：新增刷新率与无障碍（`maximumFramesPerSecond` / `最大刷新率`，iOS `UIScreen` / macOS `NSScreen`；`isReduceMotionEnabled` / `减弱动态效果`、`isReduceTransparencyEnabled` / `降低透明度`，iOS `UIAccessibility` / macOS `NSWorkspace.accessibilityDisplayShould*`；`isBoldTextEnabled` / `粗体文本`，仅 iOS，macOS 恒 `false`；另含 `accessibilitySummary` / `无障碍摘要` 汇总文本）、存储卷列表（`mountedVolumes` / `存储卷列表` 枚举已挂载卷，含 `MountedVolume` / `存储卷` 结构体：卷名 / 路径 / 总容量 / 可用容量 / 是否可移除 / 是否内置 + 已用占比等派生值，另有 `mountedVolumeCount` / `存储卷数量` 与 `removableVolumes` / `可移除存储卷列表`）、App 签名信息（`bundleIdentifier` / `包标识符`、`teamIdentifier` / `团队ID` 读 Info.plist 与内嵌描述文件、`isTestFlight` / `是否TestFlight`）、代理检测（`isUsingProxy` / `是否走代理`、`proxyDescription` / `代理描述`，`CFNetworkCopySystemProxySettings` 判断 HTTP / HTTPS / SOCKS，双平台且无需权限）与 Wi-Fi 名称 `wifiSSID` / `WiFi名称`（macOS CoreWLAN），`snapshot()` 同步补入刷新率 / 无障碍摘要 / 包标识符 / 是否 TestFlight / 是否走代理 / 存储卷数量，均含中文别名并补冒烟测试。

- **0.11.0**：新增设备型号友好名（`deviceModelName` / `deviceModelName(for:)` / `deviceModelTable` / `设备型号名称` / `设备型号对照表`，内置约 70 条标识符→机型对照表（iPhone / iPad / Mac），未收录的标识符原样返回，对照表可自行增补新机型）、深色模式（`isDarkMode` / `深色模式`，双平台，AppKit `effectiveAppearance` 优先、`UserDefaults` 兜底）、屏幕亮度（`screenBrightness` / `屏幕亮度`，`0.0`~`1.0`，仅 macOS，经 IOKit `IODisplayGetFloatParameter` 读取，无权限返回 `nil`）、信息快照（`snapshot()` / `信息快照()`，一次性输出约 31 个固定检测项为 `[String: String]`，值均为字符串可直接 JSON 序列化，另有条件键处理器型号 / 屏幕亮度 / 电池电量 / 是否充电），均含中文别名并补冒烟测试。

- **0.10.0**：新增运行环境检测（`kernelVersion` / `内核版本`（`uname` 内核 release）、`hostName` / `主机名`（`ProcessInfo.hostName`）、`userName` / `当前用户名`（`NSUserName()`）、`isDebuggerAttached` / `是否被调试`（`sysctl` 读取 `kinfo_proc` 的 `P_TRACED` 标志）），均含中文别名并补冒烟测试。

- **0.9.0**：新增运行进程（`runningProcesses` / `processCount`，`sysctl(KERN_PROC, KERN_PROC_ALL)` 枚举内核进程表，含 `RunningProcess` / `运行进程` 结构体与别名）、交换内存（`swapTotalBytes` / `swapUsedBytes` / `swapTotal` / `swapUsed`，macOS `vm.swapusage`，非 macOS 返回「不支持」）、网络接口（`networkInterfaces`，`getifaddrs` 枚举接口名 + IPv4 + 启用 / 回环，含 `NetworkInterface` / `网络接口` 结构体与别名），均含中文别名并补冒烟测试。

- **0.8.1**：将 IOKit 入口常量 `kIOMasterPortDefault` 替换为 `kIOMainPortDefault`，消除 macOS 12+ 的弃用告警。

- **0.8.0**：新增网络流量统计（`sampleNetworkTraffic()` / `采样网络流量()`，`getifaddrs` 读活跃接口 `if_data` 累计收发字节并与上次采样做差换算每秒速率，含回绕处理）、磁盘读写速率（`sampleDiskIOTraffic()` / `采样磁盘读写()`，汇总 `IOBlockStorageDriver` 累计读写字节换算每秒速率，仅 macOS），含 `NetworkTraffic` / `DiskIOTraffic` 结构体及中文类型别名 `网络流量` / `磁盘读写`，并补冒烟测试。

- **0.7.0**：新增系统负载（`loadAverage` / `loadAverage1Min` / `loadAverage5Min` / `loadAverage15Min`，`getloadavg` 三值）、网络扩展（`dnsServers` 解析 `/etc/resolv.conf`、`defaultGateway` 通过 sysctl 路由表定位、`publicIPAddress()` 异步请求公网 IP，另含 `SystemInfoError`）、电池扩展（`batteryCycleCount` / `batteryHealthPercent` / `batteryHealth`，IOKit `AppleSmartBattery` 读循环次数与健康度），均含中文别名并补冒烟测试。

- **0.6.0**：新增系统启动时间（`bootTime` / `bootTimeString`，`Date` + 人类可读）、本进程信息（`processCPUUsage` / `processMemoryBytes` / `processMemory`，mach `task_info` 采样）、显示器信息（`displayCount` / `displayResolutions` / `displayScales`）、Wi-Fi 信号强度（`wifiSignalStrength` / `wifiSignalStrengthName`，macOS CoreWLAN，iOS 返回「不支持」），均含中文别名。

- **0.5.1**：修复内存压力读取——一次性 `memoryPressure` 在 macOS 上拿不到当前值（内存压力源仅在压力变化时回调），现正确返回「不支持」并在文档说明，推荐用 `MemoryPressureMonitor` 监听实时值；`MemoryPressureMonitor.currentPressure` 改为记录最近一次压力事件（此前误用一次性读取器）。新增冒烟测试（Tests target，13 用例）。
- **0.5.0**：新增可用内存（`availableMemoryBytes` / `availableMemory`，封装 `os_proc_available_memory()`）、内存压力监听器（`MemoryPressureMonitor`，实时回调压力变化，仅 macOS）、存储详情（`availableCapacityBytes` / `availableCapacity` / `opportunisticCapacityBytes` / `opportunisticCapacity` / `volumeName` / `fileSystemName`，基于 URL 资源值与文件系统属性），均含中文别名。

- **0.4.0**：新增 CPU 架构（`cpuArchitecture`，编译期 `arch()` 判断 `arm64` / `x86_64`）、热状态与电源（`thermalState` / `thermalStateName` / `isLowPowerModeEnabled`，基于 `ProcessInfo`，低功耗模式仅 iOS）、内存压力（`memoryPressure` / `memoryPressureName`，基于 macOS Dispatch 内存压力源），均含中文别名。
- **0.3.0**：新增网络信息（`localIPAddress` / `isNetworkConnected` / `networkType`，基于 getifaddrs）、本地化信息（`languageCode` / `regionCode` / `localeIdentifier` / `timeZoneIdentifier` / `calendarIdentifier`）、资源占用（`cpuUsage` / `memoryUsedBytes` / `memoryUsed` / `memoryUsagePercent`，基于 mach 接口），均含中文别名。
- **0.2.0**：macOS 电池检测（IOKit，`batteryLevel` / `isCharging` 双平台）；新增磁盘已用 / 使用率（`diskUsedBytes` / `diskUsed` / `diskUsagePercent`）、系统运行时长（`systemUptime` / `systemUptimeString`）、是否模拟器（`isSimulator`）、App 信息（`appName` / `appVersion` / `appBuildNumber`），均含中文别名。
- **0.1.0**：首个版本，覆盖系统 / 设备 / 硬件 / 电池 / 屏幕五类检测，含中文别名。

## License

MIT
