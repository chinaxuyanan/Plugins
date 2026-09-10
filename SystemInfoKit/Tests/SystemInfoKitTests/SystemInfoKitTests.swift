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
}
