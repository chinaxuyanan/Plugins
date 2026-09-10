# SystemInfoKit —— 中文友好的系统检测工具库

> 解决「查系统信息要记各种零散 API」的痛点。
> 把系统版本、设备型号、硬件、屏幕、电池等常用检测项集中封装，全部属性带中文别名。

## 特性

- **系统信息**：系统名称 / 版本号 / 完整版本
- **设备信息**：标识符 / 名称 / 类型
- **硬件信息**：内存 / 处理器 / 磁盘（含已用 / 使用率）+ CPU 架构
- **存储详情**：重要用途可用容量 / 机会性可用容量 / 卷名 / 文件系统类型
- **电池**：电量 / 是否充电 / 循环次数 / 健康度（iOS + macOS，循环次数与健康度仅 macOS）
- **热状态与电源**：热状态 / 低功耗模式（低功耗仅 iOS）
- **屏幕与显示器**：分辨率 / 缩放因子 / 显示器数量 / 各显示器分辨率与缩放
- **运行信息**：运行时长 / 启动时间 / 是否模拟器
- **App 信息**：名称 / 版本 / 构建号
- **网络信息**：本机 IP / 是否联网 / 网络类型 / Wi-Fi 信号强度（macOS）/ DNS / 默认网关（macOS）/ 公网 IP（异步）
- **本地化信息**：语言 / 区域 / 地区 / 时区 / 日历
- **资源占用**：CPU 使用率 / 内存已用 / 内存使用率 / 可用内存 / 内存压力（macOS）
- **系统负载**：1 / 5 / 15 分钟平均负载（`getloadavg`）
- **网络流量统计**：`sampleNetworkTraffic()` 采样活跃接口累计收发字节 + 每秒速率
- **磁盘读写速率**：`sampleDiskIOTraffic()` 汇总块存储驱动累计读写字节 + 每秒速率（仅 macOS）
- **运行进程**：`runningProcesses` / `processCount` 枚举内核进程表（`sysctl(KERN_PROC)`，含 pid 与进程名）
- **交换内存**：`swapTotalBytes` / `swapUsedBytes` / `swapTotal` / `swapUsed`（仅 macOS，`vm.swapusage`）
- **网络接口**：`networkInterfaces` 枚举所有网络接口（名称 + IPv4 + 是否启用 / 是否回环）
- **本进程信息**：当前进程 CPU 使用率 / 内存占用
- **运行环境**：内核版本 / 主机名 / 当前用户名 / 是否被调试器附加（`uname` + `sysctl(P_TRACED)`）
- **内存压力监听**：`MemoryPressureMonitor` 实时回调压力变化（仅 macOS）
- **中文别名**：`SystemInfoKit.系统版本` 等，与英文属性一一等价
- **纯 Foundation + Darwin 系统接口**，iOS 15+ / macOS 12+

## 安装

在 Xcode 中：`File → Add Packages...`，粘贴本仓库地址，选择版本即可。

或在 `Package.swift` 中声明依赖：

```swift
dependencies: [
    .package(url: "https://github.com/<你的账号>/SystemInfoKit", from: "0.10.0")
]
```

然后在目标中 `import SystemInfoKit`。

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
| `thermalState` | 设备热状态 | `ProcessInfo.ThermalState` |
| `thermalStateName` | 热状态中文名 | 正常 / 尚可 / 严重 / 危急 |
| `isLowPowerModeEnabled` | 低功耗模式 | 仅 iOS |
| `screenSize` | 屏幕分辨率 | 逻辑点 |
| `screenScale` | 屏幕缩放因子 | `1.0` / `2.0` / `3.0` |
| `displayCount` | 显示器数量 | 内置 + 外接屏 |
| `displayResolutions` | 各显示器分辨率 | `[String]`，逻辑点 |
| `displayScales` | 各显示器缩放因子 | `[CGFloat]` |
| `systemUptime` | 系统运行时长（秒） | `TimeInterval` |
| `systemUptimeString` | 系统运行时长 | 形如 `3 天 5 小时` |
| `bootTime` | 系统启动时间 | `Date` |
| `bootTimeString` | 系统启动时间（可读） | 形如 `2026-09-08 14:30:00` |
| `isSimulator` | 是否模拟器 | `Bool` |
| `appName` | App 显示名称 | `String` |
| `appVersion` / `appBuildNumber` | App 版本 / 构建号 | `String` |
| `localIPAddress` | 本机局域网 IP | `String?` |
| `isNetworkConnected` | 是否联网 | `Bool` |
| `networkType` | 网络类型 | `String?` |
| `wifiSignalStrength` | Wi-Fi 信号强度（RSSI） | `Int?`，仅 macOS |
| `wifiSignalStrengthName` | Wi-Fi 信号强度中文名 | 强 / 中 / 弱 / 不支持 |
| `dnsServers` | DNS 服务器 | `[String]`，仅 macOS |
| `defaultGateway` | 默认网关 | `String?`，仅 macOS |
| `publicIPAddress()` | 公网 IP | `async throws`，请求 api.ipify.org |
| `languageCode` / `regionCode` | 语言 / 区域代码 | `String` |
| `localeIdentifier` | 完整地区标识 | `String` |
| `timeZoneIdentifier` / `calendarIdentifier` | 时区 / 日历标识 | `String` |
| `cpuUsage` | CPU 使用率 | `0.0`~`1.0` |
| `memoryUsedBytes` / `memoryUsed` | 内存已用（字节 / 可读） | `UInt64` / 人类可读 |
| `memoryUsagePercent` | 内存使用率 | `0.0`~`1.0` |
| `memoryPressure` | 内存压力 | 仅 macOS |
| `memoryPressureName` | 内存压力中文名 | 正常 / 警告 / 严重 / 不支持 |
| `availableMemoryBytes` / `availableMemory` | 可用内存（字节 / 可读） | `UInt64?` / 人类可读 |
| `loadAverage` | 系统负载 | `[Double]`，1/5/15 分钟三值 |
| `loadAverage1Min` / `loadAverage5Min` / `loadAverage15Min` | 1/5/15 分钟负载 | `Double` |
| `sampleNetworkTraffic()` | 采样网络流量 | `NetworkTraffic?`，累计收发字节 + 每秒速率（首次速率 `nil`）|
| `sampleDiskIOTraffic()` | 采样磁盘读写 | `DiskIOTraffic?`，累计读写字节 + 每秒速率（仅 macOS，首次速率 `nil`）|
| `processCPUUsage` | 当前进程 CPU 使用率 | 相对单核，多线程可 >`1.0` |
| `processMemoryBytes` / `processMemory` | 当前进程内存占用（字节 / 可读） | `UInt64` / 人类可读 |
| `runningProcesses` / `processCount` | 运行进程列表 / 数量 | `[RunningProcess]` / `Int`，`sysctl(KERN_PROC)` |
| `swapTotalBytes` / `swapUsedBytes` | 交换内存总 / 已用（字节） | `UInt64?`，仅 macOS |
| `swapTotal` / `swapUsed` | 交换内存总 / 已用（可读） | 非 macOS 返回「不支持」 |
| `networkInterfaces` | 网络接口列表 | `[NetworkInterface]`，`getifaddrs` |
| `kernelVersion` | 内核版本 | `uname` 的 release，形如 `23.5.0` |
| `hostName` | 主机名 | `ProcessInfo.hostName` |
| `userName` | 当前用户名 | `NSUserName()` |
| `isDebuggerAttached` | 是否被调试器附加 | `Bool`，`sysctl` 读 `P_TRACED` 标志 |
| `MemoryPressureMonitor` | 内存压力监听器 | 实时回调，仅 macOS |

## 中文命名别名

| 中文别名 | 等同英文属性 |
| --- | --- |
| `系统名称` / `系统版本` / `系统完整版本` | `systemName` / `systemVersion` / `systemVersionString` |
| `设备标识符` / `设备名称` / `设备类型` | `deviceIdentifier` / `deviceName` / `deviceType` |
| `内存总量` / `处理器核心数` / `处理器型号` / `CPU架构` | `memoryTotal` / `processorCount` / `processorName` / `cpuArchitecture` |
| `磁盘总容量` / `磁盘剩余容量` / `磁盘已用` / `磁盘使用率` | `diskTotal` / `diskFree` / `diskUsed` / `diskUsagePercent` |
| `可用容量` / `机会容量` / `卷名` / `文件系统名称` | `availableCapacity` / `opportunisticCapacity` / `volumeName` / `fileSystemName` |
| `电池电量` / `是否充电` / `热状态` / `热状态名` / `低功耗模式` | `batteryLevel` / `isCharging` / `thermalState` / `thermalStateName` / `isLowPowerModeEnabled` |
| `电池循环次数` / `电池健康度` / `电池健康` | `batteryCycleCount` / `batteryHealthPercent` / `batteryHealth` |
| `屏幕分辨率` / `屏幕缩放` / `显示器数量` / `显示器分辨率` / `显示器缩放` | `screenSize` / `screenScale` / `displayCount` / `displayResolutions` / `displayScales` |
| `系统运行时长` / `系统启动时间` / `是否模拟器` | `systemUptimeString` / `bootTime` / `isSimulator` |
| `应用名称` / `应用版本` / `应用构建号` | `appName` / `appVersion` / `appBuildNumber` |
| `本机IP地址` / `是否联网` / `网络类型` / `WiFi信号强度` / `WiFi信号强度名` | `localIPAddress` / `isNetworkConnected` / `networkType` / `wifiSignalStrength` / `wifiSignalStrengthName` |
| `DNS服务器` / `默认网关` / `公网IP地址()` | `dnsServers` / `defaultGateway` / `publicIPAddress()` |
| `语言代码` / `区域代码` / `地区标识` | `languageCode` / `regionCode` / `localeIdentifier` |
| `时区标识` / `日历标识` | `timeZoneIdentifier` / `calendarIdentifier` |
| `CPU使用率` / `内存已用` / `内存使用率` / `进程CPU使用率` / `进程内存` / `内存压力` / `内存压力名` | `cpuUsage` / `memoryUsed` / `memoryUsagePercent` / `processCPUUsage` / `processMemory` / `memoryPressure` / `memoryPressureName` |
| `可用内存` / `内存压力监听器` | `availableMemory` / `MemoryPressureMonitor`（`.当前压力/.压力变化回调/.开始监听/.停止监听`）|
| `系统负载` / `负载1分钟` / `负载5分钟` / `负载15分钟` | `loadAverage` / `loadAverage1Min` / `loadAverage5Min` / `loadAverage15Min` |
| `采样网络流量()` / `采样磁盘读写()` | `sampleNetworkTraffic()` / `sampleDiskIOTraffic()` |
| `网络流量` / `磁盘读写` | `NetworkTraffic` / `DiskIOTraffic`（类型别名）|
| `运行进程列表` / `运行进程数量` | `runningProcesses` / `processCount` |
| `交换内存总字节数` / `交换内存已用字节数` | `swapTotalBytes` / `swapUsedBytes` |
| `交换内存总量` / `交换内存已用` | `swapTotal` / `swapUsed` |
| `网络接口列表` | `networkInterfaces` |
| `运行进程` / `网络接口` | `RunningProcess` / `NetworkInterface`（类型别名）|
| `内核版本` / `主机名` / `当前用户名` / `是否被调试` | `kernelVersion` / `hostName` / `userName` / `isDebuggerAttached` |

## 更新日志

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
