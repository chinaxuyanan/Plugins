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
}
