# SystemInfoKit —— 中文友好的系统检测工具库

> 解决「查系统信息要记各种零散 API」的痛点。
> 把系统版本、设备型号、硬件、屏幕、电池等常用检测项集中封装，全部属性带中文别名。

## 特性

- **系统信息**：系统名称 / 版本号 / 完整版本
- **设备信息**：标识符 / 名称 / 类型
- **硬件信息**：内存 / 处理器 / 磁盘（含已用 / 使用率）+ CPU 架构
- **存储详情**：重要用途可用容量 / 机会性可用容量 / 卷名 / 文件系统类型
- **电池**：电量 / 是否充电（iOS + macOS）
- **热状态与电源**：热状态 / 低功耗模式（低功耗仅 iOS）
- **屏幕**：分辨率 / 缩放因子
- **运行信息**：运行时长 / 是否模拟器
- **App 信息**：名称 / 版本 / 构建号
- **网络信息**：本机 IP / 是否联网 / 网络类型
- **本地化信息**：语言 / 区域 / 地区 / 时区 / 日历
- **资源占用**：CPU 使用率 / 内存已用 / 内存使用率 / 可用内存 / 内存压力（macOS）
- **内存压力监听**：`MemoryPressureMonitor` 实时回调压力变化（仅 macOS）
- **中文别名**：`SystemInfoKit.系统版本` 等，与英文属性一一等价
- **纯 Foundation + Darwin 系统接口**，iOS 15+ / macOS 12+

## 安装

在 Xcode 中：`File → Add Packages...`，粘贴本仓库地址，选择版本即可。

或在 `Package.swift` 中声明依赖：

```swift
dependencies: [
    .package(url: "https://github.com/<你的账号>/SystemInfoKit", from: "0.5.1")
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
| `thermalState` | 设备热状态 | `ProcessInfo.ThermalState` |
| `thermalStateName` | 热状态中文名 | 正常 / 尚可 / 严重 / 危急 |
| `isLowPowerModeEnabled` | 低功耗模式 | 仅 iOS |
| `screenSize` | 屏幕分辨率 | 逻辑点 |
| `screenScale` | 屏幕缩放因子 | `1.0` / `2.0` / `3.0` |
| `systemUptime` | 系统运行时长（秒） | `TimeInterval` |
| `systemUptimeString` | 系统运行时长 | 形如 `3 天 5 小时` |
| `isSimulator` | 是否模拟器 | `Bool` |
| `appName` | App 显示名称 | `String` |
| `appVersion` / `appBuildNumber` | App 版本 / 构建号 | `String` |
| `localIPAddress` | 本机局域网 IP | `String?` |
| `isNetworkConnected` | 是否联网 | `Bool` |
| `networkType` | 网络类型 | `String?` |
| `languageCode` / `regionCode` | 语言 / 区域代码 | `String` |
| `localeIdentifier` | 完整地区标识 | `String` |
| `timeZoneIdentifier` / `calendarIdentifier` | 时区 / 日历标识 | `String` |
| `cpuUsage` | CPU 使用率 | `0.0`~`1.0` |
| `memoryUsedBytes` / `memoryUsed` | 内存已用（字节 / 可读） | `UInt64` / 人类可读 |
| `memoryUsagePercent` | 内存使用率 | `0.0`~`1.0` |
| `memoryPressure` | 内存压力 | 仅 macOS |
| `memoryPressureName` | 内存压力中文名 | 正常 / 警告 / 严重 / 不支持 |
| `availableMemoryBytes` / `availableMemory` | 可用内存（字节 / 可读） | `UInt64?` / 人类可读 |
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
| `屏幕分辨率` / `屏幕缩放` | `screenSize` / `screenScale` |
| `系统运行时长` / `是否模拟器` | `systemUptimeString` / `isSimulator` |
| `应用名称` / `应用版本` / `应用构建号` | `appName` / `appVersion` / `appBuildNumber` |
| `本机IP地址` / `是否联网` / `网络类型` | `localIPAddress` / `isNetworkConnected` / `networkType` |
| `语言代码` / `区域代码` / `地区标识` | `languageCode` / `regionCode` / `localeIdentifier` |
| `时区标识` / `日历标识` | `timeZoneIdentifier` / `calendarIdentifier` |
| `CPU使用率` / `内存已用` / `内存使用率` / `内存压力` / `内存压力名` | `cpuUsage` / `memoryUsed` / `memoryUsagePercent` / `memoryPressure` / `memoryPressureName` |
| `可用内存` / `内存压力监听器` | `availableMemory` / `MemoryPressureMonitor`（`.当前压力/.压力变化回调/.开始监听/.停止监听`）|

## 更新日志

- **0.5.1**：修复内存压力读取——一次性 `memoryPressure` 在 macOS 上拿不到当前值（内存压力源仅在压力变化时回调），现正确返回「不支持」并在文档说明，推荐用 `MemoryPressureMonitor` 监听实时值；`MemoryPressureMonitor.currentPressure` 改为记录最近一次压力事件（此前误用一次性读取器）。新增冒烟测试（Tests target，13 用例）。
- **0.5.0**：新增可用内存（`availableMemoryBytes` / `availableMemory`，封装 `os_proc_available_memory()`）、内存压力监听器（`MemoryPressureMonitor`，实时回调压力变化，仅 macOS）、存储详情（`availableCapacityBytes` / `availableCapacity` / `opportunisticCapacityBytes` / `opportunisticCapacity` / `volumeName` / `fileSystemName`，基于 URL 资源值与文件系统属性），均含中文别名。

- **0.4.0**：新增 CPU 架构（`cpuArchitecture`，编译期 `arch()` 判断 `arm64` / `x86_64`）、热状态与电源（`thermalState` / `thermalStateName` / `isLowPowerModeEnabled`，基于 `ProcessInfo`，低功耗模式仅 iOS）、内存压力（`memoryPressure` / `memoryPressureName`，基于 macOS Dispatch 内存压力源），均含中文别名。
- **0.3.0**：新增网络信息（`localIPAddress` / `isNetworkConnected` / `networkType`，基于 getifaddrs）、本地化信息（`languageCode` / `regionCode` / `localeIdentifier` / `timeZoneIdentifier` / `calendarIdentifier`）、资源占用（`cpuUsage` / `memoryUsedBytes` / `memoryUsed` / `memoryUsagePercent`，基于 mach 接口），均含中文别名。
- **0.2.0**：macOS 电池检测（IOKit，`batteryLevel` / `isCharging` 双平台）；新增磁盘已用 / 使用率（`diskUsedBytes` / `diskUsed` / `diskUsagePercent`）、系统运行时长（`systemUptime` / `systemUptimeString`）、是否模拟器（`isSimulator`）、App 信息（`appName` / `appVersion` / `appBuildNumber`），均含中文别名。
- **0.1.0**：首个版本，覆盖系统 / 设备 / 硬件 / 电池 / 屏幕五类检测，含中文别名。

## License

MIT
