import XCTest
import Foundation
@testable import SystemInfoKit

/// SystemInfoKit 冒烟测试：所有检测项都应能正常取值、不崩溃、返回合理类型。
/// 系统信息依赖真实运行环境，故以「非空 / 取值范围」为主，不做精确值断言。
final class SystemInfoKitTests: XCTestCase {

    func testSystemInfo() {
        XCTAssertFalse(SystemInfoKit.systemName.isEmpty)
        XCTAssertFalse(SystemInfoKit.systemVersion.isEmpty)
        XCTAssertFalse(SystemInfoKit.systemVersionString.isEmpty)
    }

    func testDeviceInfo() {
        XCTAssertFalse(SystemInfoKit.deviceIdentifier.isEmpty)
        XCTAssertFalse(SystemInfoKit.deviceName.isEmpty)
        XCTAssertFalse(SystemInfoKit.deviceType.isEmpty)
    }

    func testHardwareInfo() {
        XCTAssertGreaterThan(SystemInfoKit.memoryTotalBytes, 0)
        XCTAssertFalse(SystemInfoKit.memoryTotal.isEmpty)
        XCTAssertGreaterThan(SystemInfoKit.processorCount, 0)
        XCTAssertFalse(SystemInfoKit.cpuArchitecture.isEmpty)
    }

    func testDiskInfo() {
        XCTAssertGreaterThan(SystemInfoKit.diskTotalBytes, 0)
        XCTAssertGreaterThanOrEqual(SystemInfoKit.diskFreeBytes, 0)
        XCTAssertGreaterThanOrEqual(SystemInfoKit.diskUsagePercent, 0)
        XCTAssertLessThanOrEqual(SystemInfoKit.diskUsagePercent, 1.0)
    }

    func testStorageDetail() {
        XCTAssertFalse(SystemInfoKit.availableCapacity.isEmpty)
        XCTAssertFalse(SystemInfoKit.opportunisticCapacity.isEmpty)
        XCTAssertFalse(SystemInfoKit.volumeName.isEmpty)
        XCTAssertFalse(SystemInfoKit.fileSystemName.isEmpty)
    }

    func testBatteryAndThermal() {
        if let level = SystemInfoKit.batteryLevel {
            XCTAssertGreaterThanOrEqual(level, 0)
            XCTAssertLessThanOrEqual(level, 1)
        }
        XCTAssertFalse(SystemInfoKit.thermalStateName.isEmpty)
        _ = SystemInfoKit.isLowPowerModeEnabled
    }

    func testScreenInfo() {
        XCTAssertFalse(SystemInfoKit.screenSize.isEmpty)
        XCTAssertGreaterThan(SystemInfoKit.screenScale, 0)
    }

    func testRuntimeAndApp() {
        XCTAssertGreaterThan(SystemInfoKit.systemUptime, 0)
        XCTAssertFalse(SystemInfoKit.appName.isEmpty)
        XCTAssertFalse(SystemInfoKit.appVersion.isEmpty)
        XCTAssertFalse(SystemInfoKit.appBuildNumber.isEmpty)
    }

    func testLocalization() {
        XCTAssertFalse(SystemInfoKit.languageCode.isEmpty)
        XCTAssertFalse(SystemInfoKit.regionCode.isEmpty)
        XCTAssertFalse(SystemInfoKit.localeIdentifier.isEmpty)
        XCTAssertFalse(SystemInfoKit.timeZoneIdentifier.isEmpty)
        XCTAssertFalse(SystemInfoKit.calendarIdentifier.isEmpty)
    }

    func testNetworkInfo() {
        _ = SystemInfoKit.localIPAddress   // 沙箱 / 无网时可能为 nil
        _ = SystemInfoKit.isNetworkConnected
        _ = SystemInfoKit.networkType
    }

    func testResourceUsage() {
        let cpu = SystemInfoKit.cpuUsage
        XCTAssertGreaterThanOrEqual(cpu, 0)
        XCTAssertLessThanOrEqual(cpu, 1)

        XCTAssertGreaterThanOrEqual(SystemInfoKit.memoryUsedBytes, 0)
        let percent = SystemInfoKit.memoryUsagePercent
        XCTAssertGreaterThanOrEqual(percent, 0)
        XCTAssertLessThanOrEqual(percent, 1)

        XCTAssertFalse(SystemInfoKit.availableMemory.isEmpty)
    }

    func testMemoryPressure() {
        // macOS 返回「正常 / 警告 / 严重 / 不支持」之一；iOS 恒为「不支持」。无论如何不崩溃且非空。
        XCTAssertFalse(SystemInfoKit.memoryPressureName.isEmpty)
    }

    func testChineseAliasesEquivalent() {
        XCTAssertEqual(SystemInfoKit.系统版本, SystemInfoKit.systemVersion)
        XCTAssertEqual(SystemInfoKit.内存总量, SystemInfoKit.memoryTotal)
        // 可用内存是实时值（os_proc_available_memory 每次重读、按 0.1 精度取整），
        // 两次读取可能不同，故别名只断言非空（能返回格式化结果）。
        XCTAssertFalse(SystemInfoKit.可用内存.isEmpty)
        XCTAssertFalse(SystemInfoKit.availableMemory.isEmpty)
        XCTAssertEqual(SystemInfoKit.卷名, SystemInfoKit.volumeName)
        XCTAssertEqual(SystemInfoKit.文件系统名称, SystemInfoKit.fileSystemName)
    }

    func testBootTime() {
        let boot = SystemInfoKit.bootTime
        XCTAssertLessThanOrEqual(boot, Date())
        XCTAssertFalse(SystemInfoKit.bootTimeString.isEmpty)
    }

    func testProcessInfo() {
        XCTAssertGreaterThan(SystemInfoKit.processMemoryBytes, 0)
        XCTAssertFalse(SystemInfoKit.processMemory.isEmpty)
        XCTAssertGreaterThanOrEqual(SystemInfoKit.processCPUUsage, 0)
    }

    func testDisplayInfo() {
        XCTAssertGreaterThanOrEqual(SystemInfoKit.displayCount, 1)
        XCTAssertEqual(SystemInfoKit.displayResolutions.count, SystemInfoKit.displayCount)
        XCTAssertEqual(SystemInfoKit.displayScales.count, SystemInfoKit.displayCount)
    }

    func testWiFiSignal() {
        // iOS 上信号强度恒为 nil、名称恒为「不支持」；macOS 上可能为 nil 或数值，名称非空即可。
        _ = SystemInfoKit.wifiSignalStrength
        XCTAssertFalse(SystemInfoKit.wifiSignalStrengthName.isEmpty)
    }

    func testChineseAliasesForNewFeatures() {
        XCTAssertEqual(SystemInfoKit.显示器数量, SystemInfoKit.displayCount)
        // bootTime 每次访问都重新计算「当前时间 − 运行时长」，两次取值有亚毫秒差异，
        // 故用「时间戳误差 ≤ 2 秒」代替精确相等。
        XCTAssertEqual(SystemInfoKit.系统启动时间.timeIntervalSince1970,
                       SystemInfoKit.bootTime.timeIntervalSince1970, accuracy: 2.0)
        XCTAssertEqual(SystemInfoKit.系统启动时间字符串, SystemInfoKit.bootTimeString)
        // 进程内存是实时值（mach task_info 每次重读、按 0.1 精度取整），两次读取可能不同，
        // 故别名只断言非空（能返回格式化结果）。
        XCTAssertFalse(SystemInfoKit.进程内存.isEmpty)
        XCTAssertFalse(SystemInfoKit.processMemory.isEmpty)
        XCTAssertEqual(SystemInfoKit.WiFi信号强度名, SystemInfoKit.wifiSignalStrengthName)
    }

    // MARK: - 系统负载 load average

    func testLoadAverage() {
        let loads = SystemInfoKit.loadAverage
        XCTAssertEqual(loads.count, 3, "load average 应为 1/5/15 分钟三值")
        XCTAssertGreaterThanOrEqual(SystemInfoKit.loadAverage1Min, 0)
        XCTAssertGreaterThanOrEqual(SystemInfoKit.loadAverage5Min, 0)
        XCTAssertGreaterThanOrEqual(SystemInfoKit.loadAverage15Min, 0)
        // 各分量应与数组对应项一致（三值各自重读 getloadavg，内核每 5 秒重算，用容差避免跨窗口的偶发不一致）
        XCTAssertEqual(SystemInfoKit.loadAverage1Min, loads[0], accuracy: 1.0)
        XCTAssertEqual(SystemInfoKit.loadAverage5Min, loads[1], accuracy: 1.0)
        XCTAssertEqual(SystemInfoKit.loadAverage15Min, loads[2], accuracy: 1.0)
    }

    // MARK: - 电池扩展

    func testBatteryExtension() {
        // macOS 可读循环次数与健康度；iOS 恒为 nil。健康度百分比有值时应在 0~1 之间。
        _ = SystemInfoKit.batteryCycleCount
        if let health = SystemInfoKit.batteryHealthPercent {
            XCTAssertGreaterThanOrEqual(health, 0)
            XCTAssertLessThanOrEqual(health, 1)
        }
        XCTAssertFalse(SystemInfoKit.batteryHealth.isEmpty)
    }

    // MARK: - 网络扩展

    func testNetworkExtension() {
        // macOS 解析 /etc/resolv.conf 与默认路由；iOS 返回空 / nil。冒烟不崩溃即可。
        _ = SystemInfoKit.dnsServers
        _ = SystemInfoKit.defaultGateway
    }

    // MARK: - 新增中文别名

    func testChineseAliasesForExtensions() {
        // 负载均值是实时值，别名与英文各自重读 getloadavg，用容差比较
        let aliasLoad = SystemInfoKit.系统负载
        let englishLoad = SystemInfoKit.loadAverage
        XCTAssertEqual(aliasLoad.count, englishLoad.count)
        for (a, e) in zip(aliasLoad, englishLoad) {
            XCTAssertEqual(a, e, accuracy: 1.0)
        }
        XCTAssertEqual(SystemInfoKit.负载1分钟, SystemInfoKit.loadAverage1Min, accuracy: 1.0)
        XCTAssertEqual(SystemInfoKit.负载5分钟, SystemInfoKit.loadAverage5Min, accuracy: 1.0)
        XCTAssertEqual(SystemInfoKit.负载15分钟, SystemInfoKit.loadAverage15Min, accuracy: 1.0)
        XCTAssertEqual(SystemInfoKit.DNS服务器, SystemInfoKit.dnsServers)
        XCTAssertEqual(SystemInfoKit.默认网关, SystemInfoKit.defaultGateway)
        XCTAssertEqual(SystemInfoKit.电池循环次数, SystemInfoKit.batteryCycleCount)
        XCTAssertEqual(SystemInfoKit.电池健康度, SystemInfoKit.batteryHealthPercent)
        XCTAssertEqual(SystemInfoKit.电池健康, SystemInfoKit.batteryHealth)
    }

    // MARK: - 网络流量 / 磁盘读写

    func testNetworkTrafficSampling() {
        // 沙箱 / 无网时可能为 nil；可读时返回累计字节与（首采样为 nil 的）速率
        if let t = SystemInfoKit.sampleNetworkTraffic() {
            XCTAssertFalse(t.interface.isEmpty)
            XCTAssertGreaterThanOrEqual(t.receivedBytesPerSecond ?? 0, 0)
            XCTAssertGreaterThanOrEqual(t.sentBytesPerSecond ?? 0, 0)
        }
        if let t = SystemInfoKit.sampleNetworkTraffic() {
            XCTAssertGreaterThanOrEqual(t.receivedBytesPerSecond ?? 0, 0)
            XCTAssertGreaterThanOrEqual(t.sentBytesPerSecond ?? 0, 0)
        }
    }

    func testDiskIOTrafficSampling() {
        // iOS 恒为 nil；macOS 可能为 nil（无权限 / 无块设备）或有效快照
        if let t = SystemInfoKit.sampleDiskIOTraffic() {
            XCTAssertGreaterThanOrEqual(t.readBytesPerSecond ?? 0, 0)
            XCTAssertGreaterThanOrEqual(t.writeBytesPerSecond ?? 0, 0)
        }
        _ = SystemInfoKit.sampleDiskIOTraffic()
    }

    func testChineseAliasesForTraffic() {
        _ = SystemInfoKit.采样网络流量()
        _ = SystemInfoKit.采样磁盘读写()
        // 类型别名应等价于英文类型
        let _: 网络流量.Type = NetworkTraffic.self
        let _: 磁盘读写.Type = DiskIOTraffic.self
    }

    // MARK: - 运行进程 / 交换内存 / 网络接口

    func testRunningProcesses() {
        let processes = SystemInfoKit.runningProcesses
        XCTAssertFalse(processes.isEmpty, "进程表应至少含若干进程")
        XCTAssertGreaterThan(SystemInfoKit.processCount, 0)
        for p in processes {
            XCTAssertGreaterThanOrEqual(p.pid, 0)
            // 进程名可能为空（内核态进程），故不断言非空
        }
    }

    func testSwapMemory() {
        // iOS 恒为 nil；macOS 返回字节数。字符串形态恒非空（「不支持」或数值）。
        _ = SystemInfoKit.swapTotalBytes
        _ = SystemInfoKit.swapUsedBytes
        XCTAssertFalse(SystemInfoKit.swapTotal.isEmpty)
        XCTAssertFalse(SystemInfoKit.swapUsed.isEmpty)
    }

    func testNetworkInterfaces() {
        let interfaces = SystemInfoKit.networkInterfaces
        XCTAssertFalse(interfaces.isEmpty, "至少应有 lo0 回环接口")
        for i in interfaces {
            XCTAssertFalse(i.name.isEmpty)
        }
        // 回环接口 lo0 应存在且被标记为回环
        XCTAssertTrue(interfaces.contains { $0.name == "lo0" && $0.isLoopback })
    }

    func testChineseAliasesForProcessSwapInterfaces() {
        // 运行进程 / 网络接口是实时值，别名与英文各自重新枚举，只断言非空 / 结构合理
        XCTAssertFalse(SystemInfoKit.运行进程列表.isEmpty)
        XCTAssertGreaterThan(SystemInfoKit.运行进程数量, 0)
        XCTAssertFalse(SystemInfoKit.网络接口列表.isEmpty)
        XCTAssertTrue(SystemInfoKit.网络接口列表.contains { $0.isLoopback })

        // 交换内存字符串形态恒非空
        XCTAssertFalse(SystemInfoKit.交换内存总量.isEmpty)
        XCTAssertFalse(SystemInfoKit.交换内存已用.isEmpty)
        _ = SystemInfoKit.交换内存总字节数
        _ = SystemInfoKit.交换内存已用字节数

        // 类型别名等价于英文类型
        let _: 运行进程.Type = RunningProcess.self
        let _: 网络接口.Type = NetworkInterface.self
    }

    // MARK: - 运行环境

    func testRuntimeEnvironment() {
        XCTAssertFalse(SystemInfoKit.kernelVersion.isEmpty)
        XCTAssertFalse(SystemInfoKit.hostName.isEmpty)
        XCTAssertFalse(SystemInfoKit.userName.isEmpty)
        _ = SystemInfoKit.isDebuggerAttached   // 视运行方式而定，只保证可取值
    }

    func testChineseAliasesForRuntimeEnvironment() {
        XCTAssertEqual(SystemInfoKit.内核版本, SystemInfoKit.kernelVersion)
        XCTAssertEqual(SystemInfoKit.主机名, SystemInfoKit.hostName)
        XCTAssertEqual(SystemInfoKit.当前用户名, SystemInfoKit.userName)
        XCTAssertEqual(SystemInfoKit.是否被调试, SystemInfoKit.isDebuggerAttached)
    }

    // MARK: - 设备型号名 / 深色模式 / 亮度 / 快照

    /// 对照表是纯函数，可以做精确断言（不依赖运行环境）
    func testDeviceModelNameLookup() {
        XCTAssertEqual(SystemInfoKit.deviceModelName(for: "iPhone15,4"), "iPhone 15")
        XCTAssertEqual(SystemInfoKit.deviceModelName(for: "iPhone16,2"), "iPhone 15 Pro Max")
        XCTAssertEqual(SystemInfoKit.deviceModelName(for: "MacBookPro18,3"), "MacBook Pro 14 英寸（2021）")
        XCTAssertEqual(SystemInfoKit.deviceModelName(for: "iPad14,2"), "iPad mini（第六代）")

        // 未收录的标识符原样返回，便于自行增补
        XCTAssertEqual(SystemInfoKit.deviceModelName(for: "iPhone99,9"), "iPhone99,9")
        XCTAssertEqual(SystemInfoKit.设备型号名称(标识符: "iPhone15,4"), "iPhone 15")

        // 可自行增补新机型
        let original = SystemInfoKit.deviceModelTable
        defer { SystemInfoKit.设备型号对照表 = original }
        SystemInfoKit.deviceModelTable["iPhone99,9"] = "未来机型"
        XCTAssertEqual(SystemInfoKit.deviceModelName(for: "iPhone99,9"), "未来机型")
    }

    func testDeviceModelNameIsNonEmpty() {
        XCTAssertFalse(SystemInfoKit.deviceModelName.isEmpty)
        XCTAssertFalse(SystemInfoKit.设备型号名称.isEmpty)
    }

    func testDarkModeAndBrightness() {
        _ = SystemInfoKit.isDarkMode          // 随系统设置变化，只保证可取值
        XCTAssertEqual(SystemInfoKit.深色模式, SystemInfoKit.isDarkMode)

        if let brightness = SystemInfoKit.screenBrightness {
            // 亮度是实时值，只做范围断言
            XCTAssertGreaterThanOrEqual(brightness, 0)
            XCTAssertLessThanOrEqual(brightness, 1)
            XCTAssertNotNil(SystemInfoKit.屏幕亮度)
        }
    }

    func testSnapshot() {
        let snapshot = SystemInfoKit.信息快照()
        XCTAssertFalse(snapshot.isEmpty)

        // 值全为字符串，可直接 JSON 序列化
        for (key, value) in snapshot {
            XCTAssertFalse(key.isEmpty)
            XCTAssertFalse(value.isEmpty, "\(key) 的值不应为空字符串")
        }
        XCTAssertTrue(JSONSerialization.isValidJSONObject(snapshot))

        // 关键项齐备，且与对应属性一致
        XCTAssertEqual(snapshot["systemName"], SystemInfoKit.systemName)
        XCTAssertEqual(snapshot["deviceIdentifier"], SystemInfoKit.deviceIdentifier)
        XCTAssertEqual(snapshot["deviceModelName"], SystemInfoKit.deviceModelName)
        XCTAssertTrue(snapshot["isDarkMode"] == "true" || snapshot["isDarkMode"] == "false")
        XCTAssertEqual(snapshot["cpuArchitecture"], SystemInfoKit.cpuArchitecture)
        XCTAssertEqual(snapshot["kernelVersion"], SystemInfoKit.kernelVersion)
        XCTAssertNotNil(snapshot["diskUsage"])
        XCTAssertTrue(snapshot["diskUsage"]?.hasSuffix("%") ?? false)
    }

    // MARK: - 刷新率与无障碍

    func testRefreshRateAndAccessibility() {
        // 刷新率：常见为 60 / 120，取不到时兜底 60，故至少应大于 0
        XCTAssertGreaterThan(SystemInfoKit.maximumFramesPerSecond, 0)

        // 辅助功能开关随系统设置变化，只保证可取值、不崩溃（macOS 上「粗体文本」恒为 false）
        _ = SystemInfoKit.isReduceMotionEnabled
        _ = SystemInfoKit.isReduceTransparencyEnabled
        _ = SystemInfoKit.isBoldTextEnabled

        // 摘要恒非空（都没开启时为「无」）
        XCTAssertFalse(SystemInfoKit.accessibilitySummary.isEmpty)
        // 摘要内容应与各开关一致
        if SystemInfoKit.isReduceMotionEnabled {
            XCTAssertTrue(SystemInfoKit.accessibilitySummary.contains("减弱动态效果"))
        }
    }

    func testChineseAliasesForAccessibility() {
        XCTAssertEqual(SystemInfoKit.最大刷新率, SystemInfoKit.maximumFramesPerSecond)
        XCTAssertEqual(SystemInfoKit.减弱动态效果, SystemInfoKit.isReduceMotionEnabled)
        XCTAssertEqual(SystemInfoKit.降低透明度, SystemInfoKit.isReduceTransparencyEnabled)
        XCTAssertEqual(SystemInfoKit.粗体文本, SystemInfoKit.isBoldTextEnabled)
        XCTAssertEqual(SystemInfoKit.无障碍摘要, SystemInfoKit.accessibilitySummary)
    }

    // MARK: - 存储卷

    /// MountedVolume 的换算逻辑是纯函数，可做精确断言
    func testMountedVolumeComputation() {
        let url = URL(fileURLWithPath: "/Volumes/Demo")
        let volume = MountedVolume(name: "演示盘", url: url,
                                   totalBytes: 1_000, freeBytes: 400,
                                   isRemovable: true, isInternal: false)

        XCTAssertEqual(volume.id, "/Volumes/Demo")
        XCTAssertEqual(volume.usedBytes, 600)
        XCTAssertEqual(volume.usedRatio, 0.6, accuracy: 1e-9)
        XCTAssertEqual(volume.usedPercentText, "60.0%")
        XCTAssertEqual(volume.kindName, "可移除设备")
        XCTAssertFalse(volume.totalDescription.isEmpty)
        XCTAssertFalse(volume.usedDescription.isEmpty)
        XCTAssertFalse(volume.freeDescription.isEmpty)

        // 中文别名构造应等价（Hashable / Equatable 由存储属性合成）
        let 中文 = 存储卷(名称: "演示盘", 路径: url, 总容量: 1_000, 可用容量: 400,
                        是否可移除: true, 是否内置: false)
        XCTAssertEqual(中文, volume)
        XCTAssertEqual(中文.名称, "演示盘")
        XCTAssertEqual(中文.路径, url)
        XCTAssertEqual(中文.总容量, 1_000)
        XCTAssertEqual(中文.可用容量, 400)
        XCTAssertTrue(中文.是否可移除)
        XCTAssertFalse(中文.是否内置)
        XCTAssertEqual(中文.已用字节数, 600)
        XCTAssertEqual(中文.已用占比, 0.6, accuracy: 1e-9)
        XCTAssertEqual(中文.已用占比文本, "60.0%")
        XCTAssertEqual(中文.类型名, "可移除设备")
        XCTAssertEqual(中文.可用文本, volume.freeDescription)

        // 内置磁盘 / 外接磁盘的命名区分
        let internalDisk = MountedVolume(name: "内置", url: URL(fileURLWithPath: "/"),
                                         totalBytes: 2_000, freeBytes: 500,
                                         isRemovable: false, isInternal: true)
        XCTAssertEqual(internalDisk.kindName, "内置磁盘")
        let externalDisk = MountedVolume(name: "外接", url: URL(fileURLWithPath: "/Volumes/Ext"),
                                         totalBytes: 2_000, freeBytes: 1_500,
                                         isRemovable: false, isInternal: false)
        XCTAssertEqual(externalDisk.kindName, "外接磁盘")
        XCTAssertEqual(externalDisk.usedBytes, 500)
        XCTAssertEqual(externalDisk.usedPercentText, "25.0%")

        // 总容量为 0 时不除零，且已用容量不出现负数
        let empty = MountedVolume(name: "空卷", url: URL(fileURLWithPath: "/dev/null"),
                                  totalBytes: 0, freeBytes: 0,
                                  isRemovable: false, isInternal: false)
        XCTAssertEqual(empty.usedBytes, 0)
        XCTAssertEqual(empty.usedRatio, 0, accuracy: 1e-9)
        let overflow = MountedVolume(name: "异常", url: URL(fileURLWithPath: "/tmp"),
                                     totalBytes: 100, freeBytes: 300,
                                     isRemovable: false, isInternal: false)
        XCTAssertEqual(overflow.usedBytes, 0, "可用大于总量时已用应为 0 而非负数")
    }

    func testMountedVolumesList() {
        // 沙箱内可能枚举为空，有值时逐项校验结构
        let volumes = SystemInfoKit.mountedVolumes
        for volume in volumes {
            XCTAssertFalse(volume.name.isEmpty)
            XCTAssertFalse(volume.url.path.isEmpty)
            XCTAssertGreaterThanOrEqual(volume.totalBytes, 0)
            XCTAssertGreaterThanOrEqual(volume.freeBytes, 0)
            XCTAssertGreaterThanOrEqual(volume.usedRatio, 0)
            XCTAssertLessThanOrEqual(volume.usedRatio, 1)
            XCTAssertFalse(volume.kindName.isEmpty)
        }
        // 数量、可移除子集应与列表一致
        XCTAssertEqual(SystemInfoKit.mountedVolumeCount, volumes.count)
        XCTAssertEqual(SystemInfoKit.removableVolumes.count,
                       volumes.filter { $0.isRemovable }.count)
        // 排序稳定：按卷名升序
        XCTAssertEqual(volumes.map(\.name), volumes.map(\.name).sorted())
    }

    func testChineseAliasesForVolumes() {
        XCTAssertEqual(SystemInfoKit.存储卷列表.count, SystemInfoKit.mountedVolumes.count)
        XCTAssertEqual(SystemInfoKit.存储卷数量, SystemInfoKit.mountedVolumeCount)
        XCTAssertEqual(SystemInfoKit.可移除存储卷列表.count, SystemInfoKit.removableVolumes.count)
        // 类型别名等价于英文类型
        let _: 存储卷.Type = MountedVolume.self
    }

    // MARK: - App 签名信息 / 代理

    func testAppSigningInfo() {
        XCTAssertFalse(SystemInfoKit.bundleIdentifier.isEmpty)
        // Xcode 直接运行 / 未签名时读不到团队 ID，只保证可取值
        _ = SystemInfoKit.teamIdentifier
        _ = SystemInfoKit.isTestFlight
        if let team = SystemInfoKit.teamIdentifier {
            XCTAssertFalse(team.isEmpty)
        }
    }

    func testProxyInfo() {
        // 是否走代理与代理描述必须一致（描述为空即未启用代理）
        XCTAssertEqual(SystemInfoKit.isUsingProxy, SystemInfoKit.proxyDescription != nil)
        if let description = SystemInfoKit.proxyDescription {
            XCTAssertFalse(description.isEmpty)
            XCTAssertTrue(description.contains("代理"))
        }
        // iOS 恒为 nil；macOS 未连 Wi-Fi 或未授权定位时也可能为 nil
        _ = SystemInfoKit.wifiSSID
    }

    func testChineseAliasesForAppAndProxy() {
        XCTAssertEqual(SystemInfoKit.包标识符, SystemInfoKit.bundleIdentifier)
        XCTAssertEqual(SystemInfoKit.团队ID, SystemInfoKit.teamIdentifier)
        XCTAssertEqual(SystemInfoKit.是否TestFlight, SystemInfoKit.isTestFlight)
        XCTAssertEqual(SystemInfoKit.是否走代理, SystemInfoKit.isUsingProxy)
        XCTAssertEqual(SystemInfoKit.代理描述, SystemInfoKit.proxyDescription)
        XCTAssertEqual(SystemInfoKit.WiFi名称, SystemInfoKit.wifiSSID)
    }

    func testSnapshotIncludesNewItems() {
        let snapshot = SystemInfoKit.snapshot()
        XCTAssertEqual(snapshot["maximumFramesPerSecond"], "\(SystemInfoKit.maximumFramesPerSecond)")
        XCTAssertEqual(snapshot["accessibility"], SystemInfoKit.accessibilitySummary)
        XCTAssertEqual(snapshot["bundleIdentifier"], SystemInfoKit.bundleIdentifier)
        XCTAssertEqual(snapshot["isTestFlight"], "\(SystemInfoKit.isTestFlight)")
        XCTAssertEqual(snapshot["isUsingProxy"], "\(SystemInfoKit.isUsingProxy)")
        XCTAssertEqual(snapshot["mountedVolumeCount"], "\(SystemInfoKit.mountedVolumeCount)")
    }

    // MARK: - 电池细分状态（第九轮）

    func testBatteryState() {
        // 状态恒为四个 case 之一，名称与枚举一致
        let state = SystemInfoKit.batteryState
        XCTAssertTrue(BatteryState.allCases.contains(state))
        XCTAssertEqual(state.chineseName, SystemInfoKit.batteryStateName)
        XCTAssertFalse(SystemInfoKit.电池状态名.isEmpty)
        XCTAssertEqual(SystemInfoKit.电池状态, SystemInfoKit.batteryState)

        // 各 case 的中文名固定
        XCTAssertEqual(BatteryState.charging.chineseName, "充电中")
        XCTAssertEqual(BatteryState.full.chineseName, "已充满")
        XCTAssertEqual(BatteryState.unplugged.chineseName, "未接电源")
        XCTAssertEqual(BatteryState.unknown.chineseName, "未知")

        // 中文静态别名等价
        XCTAssertEqual(BatteryState.充电中, .charging)
        XCTAssertEqual(BatteryState.已充满, .full)
        XCTAssertEqual(BatteryState.未接电源, .unplugged)
        XCTAssertEqual(BatteryState.未知, .unknown)

        // 类型别名等价于英文类型
        let _: 电池状态.Type = BatteryState.self
    }

    func testSnapshotIncludesBatteryState() {
        XCTAssertEqual(SystemInfoKit.snapshot()["batteryState"], SystemInfoKit.batteryStateName)
    }

    // MARK: - 进程占用排行（第九轮）

    func testTopProcessesByMemory() {
        #if os(macOS)
        let top = SystemInfoKit.topProcesses(by: .memory, limit: 10)
        XCTAssertFalse(top.isEmpty, "进程排行不应为空")
        for process in top {
            XCTAssertGreaterThan(process.pid, 0)
            XCTAssertGreaterThanOrEqual(process.memoryBytes, 0)
            XCTAssertGreaterThanOrEqual(process.cpuTime, 0)
            XCTAssertGreaterThanOrEqual(process.cpuPercent, 0)
            XCTAssertFalse(process.memory.isEmpty)
        }
        // 按内存降序
        let memoryValues = top.map(\.memoryBytes)
        XCTAssertEqual(memoryValues, memoryValues.sorted(by: >))

        // 数量上限生效
        XCTAssertLessThanOrEqual(SystemInfoKit.topProcesses(by: .memory, limit: 3).count, 3)
        // limit ≤ 0 返回空
        XCTAssertTrue(SystemInfoKit.topProcesses(by: .memory, limit: 0).isEmpty)
        XCTAssertTrue(SystemInfoKit.topProcesses(by: .memory, limit: -1).isEmpty)
        #else
        XCTAssertTrue(SystemInfoKit.topProcesses(by: .memory, limit: 10).isEmpty, "iOS 无进程排行数据")
        #endif
    }

    func testTopProcessesByCPUAndAliases() {
        #if os(macOS)
        let top = SystemInfoKit.topProcesses(by: .cpu, limit: 5)
        let percents = top.map(\.cpuPercent)
        XCTAssertEqual(percents, percents.sorted(by: >), "按 CPU 排序应降序")
        #endif

        // 中文别名等价（字段级）
        let alias = SystemInfoKit.进程排行(依据: .内存, 数量: 3)
        #if os(macOS)
        XCTAssertLessThanOrEqual(alias.count, 3)
        if let first = alias.first {
            XCTAssertEqual(first.内存, first.memory)
            XCTAssertEqual(first.进程ID, first.pid)
            XCTAssertEqual(first.进程名称, first.name)
            XCTAssertEqual(first.内存字节数, first.memoryBytes)
            XCTAssertEqual(first.CPU时间, first.cpuTime)
            XCTAssertEqual(first.CPU占用, first.cpuPercent)
            XCTAssertEqual(first.启动时间, first.startDate)
        }
        #endif

        // 类型别名等价于英文类型
        let _: 进程占用.Type = ProcessUsage.self
        let _: 进程排序依据.Type = ProcessSortKey.self
        XCTAssertEqual(ProcessSortKey.内存, .memory)
        XCTAssertEqual(ProcessSortKey.CPU, .cpu)
    }

    // MARK: - 网卡物理地址 / MAC（第九轮）

    /// 校验 MAC 形如 `AA:BB:CC:DD:EE:FF`（大写、冒号分隔、6 组两位十六进制）
    private func isWellFormedMAC(_ mac: String) -> Bool {
        let groups = mac.split(separator: ":")
        guard groups.count == 6 else { return false }
        return groups.allSatisfy { group in
            group.count == 2 && group.allSatisfy { $0.isHexDigit && !$0.isLowercase }
        }
    }

    func testNetworkInterfaceMACAddress() {
        let interfaces = SystemInfoKit.networkInterfaces
        XCTAssertFalse(interfaces.isEmpty)
        for interface in interfaces {
            if let mac = interface.macAddress {
                XCTAssertTrue(isWellFormedMAC(mac), "MAC 应为 AA:BB:CC:DD:EE:FF 形式，实际：\(mac)")
                XCTAssertEqual(interface.物理地址, mac)
            }
            // 中文别名等价
            XCTAssertEqual(interface.名称, interface.name)
            XCTAssertEqual(interface.地址, interface.address)
            XCTAssertEqual(interface.已启用, interface.isUp)
            XCTAssertEqual(interface.是否回环, interface.isLoopback)
        }
        // 回环接口没有链路层地址
        if let loopback = interfaces.first(where: { $0.isLoopback }) {
            XCTAssertNil(loopback.macAddress, "回环接口不应有 MAC")
        }
    }

    func testPrimaryMACAddress() {
        // 沙箱里可能取不到（无 en0 / 无权限），有值时校验格式
        if let mac = SystemInfoKit.primaryMACAddress {
            XCTAssertTrue(isWellFormedMAC(mac), "主网卡 MAC 格式应合法，实际：\(mac)")
        }
        XCTAssertEqual(SystemInfoKit.主网卡物理地址, SystemInfoKit.primaryMACAddress)
    }

    // MARK: - 内存明细（第十轮）

    func testMemoryBreakdown() {
        guard let 明细 = SystemInfoKit.memoryBreakdown else {
            XCTFail("memoryBreakdown 在受支持的平台不应为 nil")
            return
        }
        XCTAssertGreaterThan(明细.totalBytes, 0)
        XCTAssertGreaterThanOrEqual(明细.usedPercent, 0)
        XCTAssertLessThanOrEqual(明细.usedPercent, 1)
        // 可用 = 空闲 + 非活跃 + 可丢弃 + 预读
        XCTAssertEqual(明细.availableBytes,
                       明细.freeBytes &+ 明细.inactiveBytes &+ 明细.purgeableBytes &+ 明细.speculativeBytes)
        // 已用 = 总容量 − 可用（总容量小于可用时按 0 计）
        XCTAssertEqual(明细.usedBytes,
                       明细.totalBytes > 明细.availableBytes ? 明细.totalBytes - 明细.availableBytes : 0)
        XCTAssertFalse(明细.text.isEmpty)
        XCTAssertFalse(明细.usedPercentText.isEmpty)

        // 中文别名等价（明细是已取到的结构体副本，别名读的是同一份存储值，可精确比较）
        XCTAssertEqual(明细.总容量, 明细.totalBytes)
        XCTAssertEqual(明细.空闲, 明细.freeBytes)
        XCTAssertEqual(明细.活跃, 明细.activeBytes)
        XCTAssertEqual(明细.非活跃, 明细.inactiveBytes)
        XCTAssertEqual(明细.联动, 明细.wiredBytes)
        XCTAssertEqual(明细.压缩, 明细.compressedBytes)
        XCTAssertEqual(明细.可丢弃, 明细.purgeableBytes)
        XCTAssertEqual(明细.预读, 明细.speculativeBytes)
        XCTAssertEqual(明细.可用字节, 明细.availableBytes)
        XCTAssertEqual(明细.已用字节, 明细.usedBytes)
        XCTAssertEqual(明细.已用占比, 明细.usedPercent)
        XCTAssertEqual(明细.已用占比文本, 明细.usedPercentText)
        XCTAssertEqual(明细.总容量文本, 明细.totalDescription)
        XCTAssertEqual(明细.联动文本, 明细.wiredDescription)
        XCTAssertEqual(明细.压缩文本, 明细.compressedDescription)
        XCTAssertEqual(明细.明细文本, 明细.text)

        // 类型别名等价
        let _: 内存明细.Type = MemoryBreakdown.self
    }

    func testMemoryBreakdownDeterministicArithmetic() {
        // 中文 init + 派生计算（与实时系统值无关，可精确断言）
        let 手造 = 内存明细(总容量: 100, 空闲: 20, 活跃: 30, 非活跃: 10,
                            联动: 25, 压缩: 15, 可丢弃: 5, 预读: 5)
        XCTAssertEqual(手造.可用字节, 40)           // 20 + 10 + 5 + 5
        XCTAssertEqual(手造.已用字节, 60)           // 100 − 40
        XCTAssertEqual(手造.已用占比, 0.6, accuracy: 0.0001)
        XCTAssertEqual(手造.已用占比文本, "60.0%")

        let 空 = MemoryBreakdown(totalBytes: 0, freeBytes: 0, activeBytes: 0, inactiveBytes: 0,
                                 wiredBytes: 0, compressedBytes: 0, purgeableBytes: 0, speculativeBytes: 0)
        XCTAssertEqual(空.已用占比, 0, "总容量为 0 时使用率按 0 计")
    }

    func testMemoryBreakdownConsistentWithMemoryUsed() {
        guard let 明细 = SystemInfoKit.memoryBreakdown else { return }
        // 两者同源，但两次读取之间内存会变动，故用容差比较
        XCTAssertEqual(Double(SystemInfoKit.memoryUsedBytes), Double(明细.usedBytes),
                       accuracy: Double(明细.totalBytes) * 0.1)
        XCTAssertEqual(SystemInfoKit.memoryUsagePercent, 明细.usedPercent, accuracy: 0.1)
        // 中文只读别名（实时重取，只校验取值范围）
        XCTAssertGreaterThanOrEqual(SystemInfoKit.内存使用率, 0)
        XCTAssertLessThanOrEqual(SystemInfoKit.内存使用率, 1)
    }

    // MARK: - 每核 CPU 使用率（第十轮）

    func testPerCoreCPUUsage() {
        let usages = SystemInfoKit.perCoreCPUUsage
        if usages.isEmpty {
            // 极罕见：两次采样核数不一致
            XCTAssertEqual(SystemInfoKit.perCoreCPUUsageText, "不支持")
        } else {
            XCTAssertGreaterThan(usages.count, 0)
            XCTAssertLessThanOrEqual(usages.count, SystemInfoKit.processorCount)
            for value in usages {
                XCTAssertGreaterThanOrEqual(value, 0)
                XCTAssertLessThanOrEqual(value, 1)
            }
            let text = SystemInfoKit.perCoreCPUUsageText
            XCTAssertFalse(text.isEmpty)
            XCTAssertTrue(text.contains("CPU1"), "文本应含首核标签，实际：\(text)")
        }
    }

    // MARK: - 电池温度 / 电源明细（第十轮）

    func testBatteryTemperature() {
        XCTAssertFalse(SystemInfoKit.batteryTemperatureText.isEmpty)
        if let celsius = SystemInfoKit.batteryTemperature {
            XCTAssertGreaterThan(celsius, -20)
            XCTAssertLessThan(celsius, 120)
        }
    }

    func testPowerSourceName() {
        let name = SystemInfoKit.powerSourceName
        XCTAssertFalse(name.isEmpty)
        XCTAssertTrue(["交流电源", "电池", "未知", "不支持"].contains(name), "供电来源取值异常：\(name)")
        XCTAssertEqual(SystemInfoKit.供电来源, name)
    }

    func testPowerAdapter() {
        if let adapter = SystemInfoKit.powerAdapter {
            XCTAssertFalse(adapter.text.isEmpty)
            XCTAssertTrue(adapter.text.hasPrefix("适配器"))
            XCTAssertFalse(adapter.wattsText.isEmpty)
            XCTAssertFalse(adapter.voltageText.isEmpty)
            XCTAssertFalse(adapter.currentText.isEmpty)
            // 中文别名等价（结构体副本，可精确比较）
            XCTAssertEqual(adapter.功率, adapter.watts)
            XCTAssertEqual(adapter.电压毫伏, adapter.voltageMillivolts)
            XCTAssertEqual(adapter.电流毫安, adapter.currentMilliamps)
            XCTAssertEqual(adapter.标识, adapter.adapterID)
            XCTAssertEqual(adapter.功率文本, adapter.wattsText)
            XCTAssertEqual(adapter.电压文本, adapter.voltageText)
            XCTAssertEqual(adapter.电流文本, adapter.currentText)
        } else {
            // 未接电源 / 非 macOS
            XCTAssertEqual(SystemInfoKit.powerAdapterText, "不支持")
        }

        // 中文 init 与派生文本（确定性）
        let 适配器 = 电源适配器(功率: 96, 电压毫伏: 20000, 电流毫安: 4800, 标识: 1)
        XCTAssertEqual(适配器.功率文本, "96W")
        XCTAssertEqual(适配器.电压文本, "20.0V")
        XCTAssertEqual(适配器.电流文本, "4.80A")
        XCTAssertEqual(适配器.text, "适配器 96W · 20.0V · 4.80A")

        // 类型别名等价
        let _: 电源适配器.Type = PowerAdapter.self
    }

    // MARK: - 已安装应用（第十轮）

    func testInstalledApplications() {
        let apps = SystemInfoKit.installedApplications
        XCTAssertEqual(SystemInfoKit.installedApplicationCount, apps.count)

        // 按名称本地化升序：逐对检查不递减（`sorted(by:)` 不稳定，同名项顺序不保证，别整体重排后比）
        let names = apps.map(\.name)
        for (前, 后) in zip(names, names.dropFirst()) {
            XCTAssertNotEqual(前.localizedStandardCompare(后), .orderedDescending,
                              "排序应升序，却出现「\(前)」在「\(后)」之前")
        }

        for app in apps {
            XCTAssertFalse(app.name.isEmpty)
            XCTAssertFalse(app.versionText.isEmpty)
            XCTAssertFalse(app.bundleIdentifierText.isEmpty)
            XCTAssertEqual(app.path, app.url.path)
            XCTAssertEqual(app.id, app.url.path)
            XCTAssertTrue(app.url.pathExtension == "app", "应指向 .app 包，实际：\(app.path)")
            // 中文别名等价
            XCTAssertEqual(app.名称, app.name)
            XCTAssertEqual(app.标识符, app.bundleIdentifier)
            XCTAssertEqual(app.版本, app.version)
            XCTAssertEqual(app.路径, app.url)
            XCTAssertEqual(app.版本文本, app.versionText)
            XCTAssertEqual(app.标识符文本, app.bundleIdentifierText)
        }

        // 中文别名列表（实时重扫，只比数量）
        XCTAssertEqual(SystemInfoKit.已安装应用列表.count, apps.count)

        #if !os(macOS)
        XCTAssertTrue(apps.isEmpty, "iOS 无已安装应用列表")
        #endif
    }

    func testInstalledApplicationDeterministicFields() {
        let 应用 = 已安装应用(名称: "Safari",
                            标识符: "com.apple.Safari",
                            版本: "17.0",
                            路径: URL(fileURLWithPath: "/Applications/Safari.app"))
        XCTAssertEqual(应用.版本文本, "17.0")
        XCTAssertEqual(应用.标识符文本, "com.apple.Safari")
        XCTAssertEqual(应用.id, "/Applications/Safari.app")

        let 未知应用 = InstalledApplication(name: "X", bundleIdentifier: nil, version: nil,
                                            url: URL(fileURLWithPath: "/Applications/X.app"))
        XCTAssertEqual(未知应用.版本文本, "未知")
        XCTAssertEqual(未知应用.标识符文本, "未知")

        // Info.plist 里的空串视同读不到（有些系统 App 的 CFBundleShortVersionString 就是空串）
        let 空版本 = InstalledApplication(name: "Y", bundleIdentifier: "", version: "",
                                          url: URL(fileURLWithPath: "/Applications/Y.app"))
        XCTAssertEqual(空版本.版本文本, "未知")
        XCTAssertEqual(空版本.标识符文本, "未知")

        let _: 已安装应用.Type = InstalledApplication.self
    }

    // MARK: 第十一轮：显卡 / USB / 风扇 / 温度 / 电池剩余时间

    func testBatteryTimeTextFormatting() {
        // 未知 / 负数一律「不支持」
        XCTAssertEqual(SystemInfoKit.batteryTimeText(nil), "不支持")
        XCTAssertEqual(SystemInfoKit.batteryTimeText(-1), "不支持")
        XCTAssertEqual(SystemInfoKit.batteryTimeText(-3600), "不支持")
        // 不满一小时只给分钟
        XCTAssertEqual(SystemInfoKit.batteryTimeText(0), "0 分")
        XCTAssertEqual(SystemInfoKit.batteryTimeText(1800), "30 分")
        // 满一小时给「小时 + 分钟」
        XCTAssertEqual(SystemInfoKit.batteryTimeText(3600), "1 小时 0 分")
        XCTAssertEqual(SystemInfoKit.batteryTimeText(5000), "1 小时 23 分")
        // 中文别名等价
        XCTAssertEqual(SystemInfoKit.电池时长文本(5000), "1 小时 23 分")
    }

    func testBatterySecondsFromMinutes() {
        XCTAssertNil(SystemInfoKit.batterySeconds(fromMinutes: nil))
        XCTAssertNil(SystemInfoKit.batterySeconds(fromMinutes: -1))
        XCTAssertNil(SystemInfoKit.batterySeconds(fromMinutes: 0))
        XCTAssertEqual(SystemInfoKit.batterySeconds(fromMinutes: 1), 60)
        XCTAssertEqual(SystemInfoKit.batterySeconds(fromMinutes: 90), 5400)
    }

    func testFanSpeedStructAndAliases() {
        let 风扇 = FanSpeed(index: 0, rpm: 2400)
        XCTAssertEqual(风扇.index, 0)
        XCTAssertEqual(风扇.rpm, 2400)
        XCTAssertEqual(风扇.text, "风扇 0：2400 RPM")

        // 中文构造与属性
        let 中文风扇 = 风扇转速(序号: 1, 转速: 1800)
        XCTAssertEqual(中文风扇.序号, 1)
        XCTAssertEqual(中文风扇.转速, 1800)
        XCTAssertEqual(中文风扇.text, "风扇 1：1800 RPM")

        let _: 风扇转速.Type = FanSpeed.self
    }

    func testUSBDeviceStructAndAliases() {
        // 全字段：产品名 · 厂商名 · (厂商:产品)
        let 键盘 = USBDevice(name: "键盘", vendorName: "Apple Inc.",
                            vendorID: 0x05AC, productID: 0x0250, serialNumber: "ABC123")
        XCTAssertEqual(键盘.idText, "05AC:0250")
        XCTAssertEqual(键盘.text, "键盘 · Apple Inc. (05AC:0250)")
        XCTAssertEqual(键盘.serialNumber, "ABC123")

        // 只有厂商 ID：标识文本只给厂商部分
        let 半个 = USBDevice(name: "U 盘", vendorName: nil, vendorID: 0x1234,
                            productID: nil, serialNumber: nil)
        XCTAssertEqual(半个.idText, "1234")
        XCTAssertEqual(半个.text, "U 盘 · (1234)")

        // 没有任何 ID：标识文本为 nil，摘要只有名字
        let 纯名 = USBDevice(name: "未知设备", vendorName: nil, vendorID: nil,
                            productID: nil, serialNumber: nil)
        XCTAssertNil(纯名.idText)
        XCTAssertEqual(纯名.text, "未知设备")

        // 厂商名与产品名相同：不重复输出厂商名
        let 同名 = USBDevice(name: "Logitech", vendorName: "Logitech", vendorID: nil,
                            productID: nil, serialNumber: nil)
        XCTAssertEqual(同名.text, "Logitech")

        // 中文构造与属性
        let 中文设备 = USB设备(名称: "鼠标", 厂商: "罗技", 厂商ID: 0x046D, 产品ID: 0xC077, 序列号: nil)
        XCTAssertEqual(中文设备.名称, "鼠标")
        XCTAssertEqual(中文设备.厂商, "罗技")
        XCTAssertEqual(中文设备.厂商ID, 0x046D)
        XCTAssertEqual(中文设备.产品ID, 0xC077)
        XCTAssertEqual(中文设备.标识文本, "046D:C077")
        XCTAssertNil(中文设备.序列号)

        let _: USB设备.Type = USBDevice.self
    }

    func testGPUInfoStructAndAliases() {
        // 只有名字（没有工作内存 / 非统一内存）时摘要就是名字
        let 基础 = GPUInfo(name: "Apple M1", maxWorkingMemoryBytes: 0,
                          hasUnifiedMemory: false, maxThreadsPerThreadgroup: 0)
        XCTAssertEqual(基础.text, "Apple M1")
        XCTAssertEqual(基础.名称, "Apple M1")

        // 统一内存 + 有工作内存：摘要含「统一内存」
        let 完整 = GPUInfo(name: "Apple M1 Pro", maxWorkingMemoryBytes: 5461 * 1024 * 1024,
                          hasUnifiedMemory: true, maxThreadsPerThreadgroup: 1024)
        XCTAssertTrue(完整.text.contains("Apple M1 Pro"))
        XCTAssertTrue(完整.text.contains("统一内存"))
        XCTAssertFalse(完整.maxWorkingMemory.isEmpty)
        XCTAssertEqual(完整.最大线程组, 1024)
        XCTAssertTrue(完整.统一内存)

        // 中文构造
        let 中文显卡 = 显卡信息(名称: "Apple M2", 最大工作内存字节: 0, 统一内存: false, 最大线程组: 512)
        XCTAssertEqual(中文显卡.名称, "Apple M2")
        XCTAssertEqual(中文显卡.最大线程组, 512)

        let _: 显卡信息.Type = GPUInfo.self
    }

    func testHardwareExtendedLiveValues() {
        // 实时值只做「不崩溃 + 类型正确 + 合理范围」的冒烟断言，不断言具体读数

        // 显卡：Metal 可用时应能取到名字，取不到也只要求 `nil`
        if let 显卡 = SystemInfoKit.gpuInfo {
            XCTAssertFalse(显卡.name.isEmpty, "显卡名字不应为空")
            XCTAssertEqual(SystemInfoKit.gpuName, 显卡.name)
            XCTAssertFalse(SystemInfoKit.gpuInfoText.isEmpty)
        }

        // 风扇：带风扇机型才有内容；每台风扇序号非负、转速合理
        for 风扇 in SystemInfoKit.fanSpeeds {
            XCTAssertGreaterThanOrEqual(风扇.index, 0)
            XCTAssertGreaterThanOrEqual(风扇.rpm, 0)
            XCTAssertLessThan(风扇.rpm, 100000, "转速不应离谱")
        }
        XCTAssertFalse(SystemInfoKit.fanSpeedsText.isEmpty)
        XCTAssertEqual(SystemInfoKit.风扇转速列表.count, SystemInfoKit.fanSpeeds.count)

        // 整机温度：读得到必须落在 0~120 ℃
        if let 温度 = SystemInfoKit.machineTemperature {
            XCTAssertGreaterThan(温度, 0)
            XCTAssertLessThan(温度, 120)
        }
        XCTAssertFalse(SystemInfoKit.machineTemperatureText.isEmpty)

        // USB：列表可能为空，但每台设备至少要有名字或 ID
        for 设备 in SystemInfoKit.usbDevices {
            let hasSomething = !设备.name.isEmpty || 设备.vendorID != nil || 设备.productID != nil
            XCTAssertTrue(hasSomething, "USB 设备至少要能标识")
        }
        XCTAssertEqual(SystemInfoKit.usbDeviceCount, SystemInfoKit.usbDevices.count)
        XCTAssertFalse(SystemInfoKit.usbDevicesText.isEmpty)

        // 电池剩余时间：秒数为非负或 `nil`；文本永不为空
        if let 剩余 = SystemInfoKit.batteryTimeRemaining {
            XCTAssertGreaterThanOrEqual(剩余, 0)
        }
        if let 充满 = SystemInfoKit.batteryTimeToFullCharge {
            XCTAssertGreaterThanOrEqual(充满, 0)
        }
        XCTAssertFalse(SystemInfoKit.batteryTimeRemainingText.isEmpty)
        XCTAssertFalse(SystemInfoKit.batteryTimeToFullChargeText.isEmpty)

        #if !os(macOS)
        XCTAssertTrue(SystemInfoKit.fanSpeeds.isEmpty, "iOS 无风扇数据")
        XCTAssertTrue(SystemInfoKit.usbDevices.isEmpty, "iOS 无 USB 外设列表")
        XCTAssertNil(SystemInfoKit.machineTemperature, "iOS 无整机温度")
        XCTAssertNil(SystemInfoKit.batteryTimeRemaining, "iOS 无电池剩余时间")
        #endif
    }
}
