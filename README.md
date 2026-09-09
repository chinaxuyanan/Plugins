# SystemInfoKit —— 中文友好的系统检测工具库

> 解决「查系统信息要记各种零散 API」的痛点。
> 把系统版本、设备型号、硬件、屏幕、电池等常用检测项集中封装，全部属性带中文别名。

## 特性

- **系统信息**：系统名称 / 版本号 / 完整版本
- **设备信息**：标识符 / 名称 / 类型
- **硬件信息**：内存 / 处理器 / 磁盘（含已用 / 使用率）
- **电池**：电量 / 是否充电（iOS + macOS）
- **屏幕**：分辨率 / 缩放因子
- **运行信息**：运行时长 / 是否模拟器
- **App 信息**：名称 / 版本 / 构建号
- **中文别名**：`SystemInfoKit.系统版本` 等，与英文属性一一等价
- **纯 Foundation + 平台条件编译**，iOS 15+ / macOS 12+

## 安装

在 Xcode 中：`File → Add Packages...`，粘贴本仓库地址，选择版本即可。

或在 `Package.swift` 中声明依赖：

```swift
dependencies: [
    .package(url: "https://github.com/<你的账号>/SystemInfoKit", from: "0.2.0")
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
| `diskTotalBytes` / `diskFreeBytes` | 磁盘总 / 剩余（字节） | `UInt64` |
| `diskTotal` / `diskFree` | 磁盘总 / 剩余 | 人类可读 |
| `diskUsedBytes` / `diskUsed` | 磁盘已用（字节 / 可读） | `UInt64` / 人类可读 |
| `diskUsagePercent` | 磁盘使用率 | `0.0`~`1.0` |
| `batteryLevel` | 电池电量 | `0.0`~`1.0`，iOS + macOS |
| `isCharging` | 是否充电 | iOS + macOS |
| `screenSize` | 屏幕分辨率 | 逻辑点 |
| `screenScale` | 屏幕缩放因子 | `1.0` / `2.0` / `3.0` |
| `systemUptime` | 系统运行时长（秒） | `TimeInterval` |
| `systemUptimeString` | 系统运行时长 | 形如 `3 天 5 小时` |
| `isSimulator` | 是否模拟器 | `Bool` |
| `appName` | App 显示名称 | `String` |
| `appVersion` / `appBuildNumber` | App 版本 / 构建号 | `String` |

## 中文命名别名

| 中文别名 | 等同英文属性 |
| --- | --- |
| `系统名称` / `系统版本` / `系统完整版本` | `systemName` / `systemVersion` / `systemVersionString` |
| `设备标识符` / `设备名称` / `设备类型` | `deviceIdentifier` / `deviceName` / `deviceType` |
| `内存总量` / `处理器核心数` / `处理器型号` | `memoryTotal` / `processorCount` / `processorName` |
| `磁盘总容量` / `磁盘剩余容量` / `磁盘已用` / `磁盘使用率` | `diskTotal` / `diskFree` / `diskUsed` / `diskUsagePercent` |
| `电池电量` / `是否充电` | `batteryLevel` / `isCharging` |
| `屏幕分辨率` / `屏幕缩放` | `screenSize` / `screenScale` |
| `系统运行时长` / `是否模拟器` | `systemUptimeString` / `isSimulator` |
| `应用名称` / `应用版本` / `应用构建号` | `appName` / `appVersion` / `appBuildNumber` |

## 更新日志

- **0.2.0**：macOS 电池检测（IOKit，`batteryLevel` / `isCharging` 双平台）；新增磁盘已用 / 使用率（`diskUsedBytes` / `diskUsed` / `diskUsagePercent`）、系统运行时长（`systemUptime` / `systemUptimeString`）、是否模拟器（`isSimulator`）、App 信息（`appName` / `appVersion` / `appBuildNumber`），均含中文别名。
- **0.1.0**：首个版本，覆盖系统 / 设备 / 硬件 / 电池 / 屏幕五类检测，含中文别名。

## License

MIT
