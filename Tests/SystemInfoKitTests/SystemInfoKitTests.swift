import XCTest
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
        XCTAssertEqual(SystemInfoKit.可用内存, SystemInfoKit.availableMemory)
        XCTAssertEqual(SystemInfoKit.卷名, SystemInfoKit.volumeName)
        XCTAssertEqual(SystemInfoKit.文件系统名称, SystemInfoKit.fileSystemName)
    }
}
