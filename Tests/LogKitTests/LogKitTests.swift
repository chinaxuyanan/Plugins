import XCTest
import Foundation
@testable import LogKit

final class LogKitTests: XCTestCase {

    // MARK: - 状态重置（LogKit 是静态全局状态，测试间必须复位，避免串扰）

    override func setUp() {
        super.setUp()
        LogKit.minimumLevel = .debug
        LogKit.consoleOutput = false
        LogKit.fileOutput = false
        LogKit.showLocation = true
        LogKit.outputFormat = .text
        LogKit.asyncWrite = true
        LogKit.customFormatter = nil
        LogKit.enabledCategories = nil
        LogKit.ignoredCategories = []
        LogKit.maxFileSize = 0
        LogKit.maxLogFiles = 0
        LogKit.traceId = nil
        LogKit.resetCounts()
        LogKit.resetThrottle()
        LogKit.coloredConsoleOutput = false
        LogKit.redactSensitiveData = true
        LogKit.samplingRate = 0.1
    }

    override func tearDown() {
        LogKit.customFormatter = nil
        LogKit.fileOutput = false
        LogKit.consoleOutput = true
        LogKit.minimumLevel = .debug
        LogKit.enabledCategories = nil
        LogKit.ignoredCategories = []
        LogKit.traceId = nil
        LogKit.resetCounts()
        LogKit.resetThrottle()
        super.tearDown()
    }

    // MARK: - 惰性求值（针对「惰性求值失效」bug 的回归测试）

    func testMessageIsNotEvaluatedWhenFiltered() {
        LogKit.minimumLevel = .error
        var evaluated = false
        func expensive() -> String {
            evaluated = true
            return "昂贵消息"
        }

        // @autoclosure 会包裹 expensive()，被级别过滤时不应求值
        LogKit.debug(expensive())
        XCTAssertFalse(evaluated, "被级别过滤的日志不应执行消息构造")

        LogKit.minimumLevel = .debug
        LogKit.debug(expensive())
        XCTAssertTrue(evaluated, "未被过滤的日志应执行消息构造")
    }

    // MARK: - 级别过滤

    func testLevelFiltering() {
        LogKit.minimumLevel = .warning
        var captured: [String] = []
        LogKit.customFormatter = { entry in captured.append(entry.message); return entry.message }

        LogKit.debug("调试消息")
        LogKit.info("信息消息")
        LogKit.warning("警告消息")
        LogKit.error("错误消息")
        LogKit.critical("严重消息")

        XCTAssertEqual(captured, ["警告消息", "错误消息", "严重消息"])
    }

    func testLogLevelOrdering() {
        XCTAssertLessThan(LogLevel.debug, LogLevel.info)
        XCTAssertLessThan(LogLevel.info, LogLevel.warning)
        XCTAssertLessThan(LogLevel.warning, LogLevel.error)
        XCTAssertLessThan(LogLevel.error, LogLevel.critical)
        XCTAssertEqual(LogLevel.debug.chineseName, "调试")
        XCTAssertEqual(LogLevel.critical.chineseName, "严重")
    }

    // MARK: - 分类过滤

    func testCategoryAllowList() {
        LogKit.enabledCategories = Set(["网络"])
        var captured: [String] = []
        LogKit.customFormatter = { entry in captured.append(entry.category); return entry.message }

        LogKit.info("a", category: "网络")
        LogKit.info("b", category: "存储")

        XCTAssertEqual(captured, ["网络"])
    }

    func testCategoryBlockList() {
        LogKit.ignoredCategories = Set(["轮询"])
        var captured: [String] = []
        LogKit.customFormatter = { entry in captured.append(entry.category); return entry.message }

        LogKit.info("a", category: "轮询")
        LogKit.info("b", category: "网络")

        XCTAssertEqual(captured, ["网络"])
    }

    // MARK: - ScopedLogger

    func testScopedLoggerEffectiveCategory() {
        XCTAssertEqual(ScopedLogger(module: "网络", category: "请求").effectiveCategory, "网络.请求")
        XCTAssertEqual(ScopedLogger(module: "网络").effectiveCategory, "网络")          // 分类为「通用」时省略
        XCTAssertEqual(ScopedLogger(category: "存储").effectiveCategory, "存储")         // 无模块
        XCTAssertEqual(ScopedLogger(module: "网络", category: "请求").child("重试").effectiveCategory, "网络.请求.重试")
    }

    func testScopedLoggerChineseInit() {
        XCTAssertEqual(ScopedLogger(模块: "网络", 分类: "请求").effectiveCategory, "网络.请求")
    }

    // MARK: - PerformanceCounter

    func testPerformanceCounterAccumulates() {
        let counter = PerformanceCounter("图片解码")
        counter.record(0.01)
        counter.record(0.02)
        counter.record(0.005)

        XCTAssertEqual(counter.callCount, 3)
        XCTAssertEqual(counter.totalDuration, 0.035, accuracy: 1e-9)
        XCTAssertEqual(counter.maxDuration, 0.02, accuracy: 1e-9)
        XCTAssertEqual(counter.minDuration, 0.005, accuracy: 1e-9)

        let summary = counter.summary()
        XCTAssertTrue(summary.contains("图片解码"))
        XCTAssertTrue(summary.contains("3 次"))
    }

    func testPerformanceCounterMeasure() {
        let counter = PerformanceCounter("测量")
        // `{ 42 }` 瞬时完成，Date 的 Double 精度下耗时可能取到 0.0，故睡 10ms 保证非零。
        let result = counter.measure {
            Thread.sleep(forTimeInterval: 0.01)
            return 42
        }
        XCTAssertEqual(result, 42)
        XCTAssertEqual(counter.callCount, 1)
        XCTAssertGreaterThan(counter.totalDuration, 0)
    }

    func testPerformanceCounterMeasureRethrows() {
        let counter = PerformanceCounter("抛错")
        enum TestError: Error { case boom }
        XCTAssertThrowsError(try counter.measure { () -> Int in throw TestError.boom })
        XCTAssertEqual(counter.callCount, 1, "抛错时也应累计一次")
        XCTAssertGreaterThan(counter.totalDuration, 0)
    }

    func testPerformanceCounterReset() {
        let counter = PerformanceCounter("重置")
        counter.record(0.1)
        counter.reset()
        XCTAssertEqual(counter.callCount, 0)
        XCTAssertEqual(counter.totalDuration, 0)
        XCTAssertEqual(counter.averageDuration, 0)
    }

    // MARK: - OSLogger

    func testOSLoggerSmoke() {
        let logger = OSLogger(subsystem: "com.example.test", category: "测试")
        logger.debug("调试")
        logger.info("信息")
        logger.notice("通知")
        logger.error("错误")
        logger.critical("严重")
        logger.fault("故障")
    }

    // MARK: - 中文别名

    func testChineseAliasForwards() {
        var captured: [String] = []
        LogKit.customFormatter = { entry in captured.append(entry.message); return entry.message }
        LogKit.调试("中文消息")
        XCTAssertEqual(captured, ["中文消息"])
    }

    // MARK: - 文件输出

    func testFileOutputWrites() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        LogKit.logDirectory = dir
        LogKit.fileOutput = true
        LogKit.asyncWrite = false

        LogKit.info("文件输出测试")
        LogKit.flush()

        let content = try String(contentsOf: LogKit.logFileURL, encoding: .utf8)
        XCTAssertTrue(content.contains("文件输出测试"))

        try? FileManager.default.removeItem(at: dir)
    }

    // MARK: - 追踪 ID traceId

    func testTraceIdInEntry() {
        LogKit.traceId = "req-123"
        var captured: String? = nil
        LogKit.customFormatter = { entry in captured = entry.traceId; return entry.message }

        LogKit.info("带追踪ID的消息")

        XCTAssertEqual(captured, "req-123")
    }

    func testScopedLoggerTraceIdOverridesGlobal() {
        LogKit.traceId = "全局"
        let 网络 = ScopedLogger(module: "网络", traceId: "请求-1")
        let 存储 = ScopedLogger(module: "存储")   // 未设置，应回退到全局

        var captured: [(String?, String)] = []   // (traceId, category)
        LogKit.customFormatter = { entry in captured.append((entry.traceId, entry.category)); return entry.message }

        网络.info("a")
        存储.info("b")

        XCTAssertEqual(captured.count, 2)
        XCTAssertEqual(captured[0].0, "请求-1")
        XCTAssertEqual(captured[0].1, "网络")
        XCTAssertEqual(captured[1].0, "全局")
        XCTAssertEqual(captured[1].1, "存储")
    }

    func testTraceIdInJSONOutput() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        LogKit.logDirectory = dir
        LogKit.fileOutput = true
        LogKit.asyncWrite = false
        LogKit.outputFormat = .json
        LogKit.traceId = "trace-json"

        LogKit.info("JSON追踪测试")
        LogKit.flush()

        let content = try String(contentsOf: LogKit.logFileURL, encoding: .utf8)
        XCTAssertTrue(content.contains("\"traceId\":\"trace-json\""), "JSON 输出应包含 traceId 字段")

        try? FileManager.default.removeItem(at: dir)
    }

    // MARK: - 环境自适应级别

    func testAdaptiveMinimumLevelMatchesBuildConfig() {
        #if DEBUG
        XCTAssertEqual(LogKit.adaptiveMinimumLevel, .debug)
        #else
        XCTAssertEqual(LogKit.adaptiveMinimumLevel, .warning)
        #endif
    }

    // MARK: - 级别计数统计

    func testLevelCounting() {
        LogKit.resetCounts()
        LogKit.minimumLevel = .debug

        LogKit.debug("d1")
        LogKit.info("i1")
        LogKit.error("e1")
        LogKit.error("e2")

        XCTAssertEqual(LogKit.totalCount(by: .debug), 1)
        XCTAssertEqual(LogKit.totalCount(by: .info), 1)
        XCTAssertEqual(LogKit.totalCount(by: .warning), 0)
        XCTAssertEqual(LogKit.totalCount(by: .error), 2)
        XCTAssertEqual(LogKit.totalCount(), 4)
    }

    func testLevelCountingSkipsFiltered() {
        LogKit.resetCounts()
        LogKit.minimumLevel = .error

        LogKit.debug("被过滤")
        LogKit.info("被过滤")
        LogKit.error("通过")

        XCTAssertEqual(LogKit.totalCount(), 1)
        XCTAssertEqual(LogKit.totalCount(by: .error), 1)
        XCTAssertEqual(LogKit.totalCount(by: .debug), 0)
    }

    // MARK: - 限流 throttle

    func testThrottleSkipsWithinInterval() {
        var captured: [String] = []
        LogKit.customFormatter = { entry in captured.append(entry.message); return entry.message }

        LogKit.throttled("滚动", interval: 10, key: "滚动-key")
        LogKit.throttled("滚动", interval: 10, key: "滚动-key")
        LogKit.throttled("滚动", interval: 10, key: "滚动-key")

        XCTAssertEqual(captured, ["滚动"], "限流窗口内同一键只应输出一次")
    }

    func testThrottleDifferentKeysIndependent() {
        var captured: [String] = []
        LogKit.customFormatter = { entry in captured.append(entry.message); return entry.message }

        LogKit.throttled("a", interval: 10, key: "k1")
        LogKit.throttled("b", interval: 10, key: "k2")

        XCTAssertEqual(captured, ["a", "b"])
    }

    func testThrottleResetAllowsAgain() {
        var captured: [String] = []
        LogKit.customFormatter = { entry in captured.append(entry.message); return entry.message }

        LogKit.throttled("x", interval: 10, key: "reset-key")
        LogKit.resetThrottle()
        LogKit.throttled("x", interval: 10, key: "reset-key")

        XCTAssertEqual(captured, ["x", "x"], "重置限流后同一键应立即再次输出")
    }

    // MARK: - 敏感信息脱敏

    func testRedactSensitiveFields() {
        let redacted = LogKit.redact([
            "password": "123456",
            "accessToken": "abc",
            "userName": "张三",
            "score": 98
        ])
        XCTAssertEqual(redacted["password"] as? String, "***")
        XCTAssertEqual(redacted["accessToken"] as? String, "***")
        XCTAssertEqual(redacted["userName"] as? String, "张三")
        XCTAssertEqual(redacted["score"] as? Int, 98)
    }

    func testRedactDisabledReturnsOriginal() {
        LogKit.redactSensitiveData = false
        let redacted = LogKit.redact(["password": "123456"])
        XCTAssertEqual(redacted["password"] as? String, "123456")
    }

    func testRedactCustomKeyword() {
        LogKit.sensitiveFieldKeywords.insert("card")
        let redacted = LogKit.redact(["cardNumber": "4111"])
        XCTAssertEqual(redacted["cardNumber"] as? String, "***")
    }

    // MARK: - 终端彩色输出

    func testColoredOutputDoesNotLeakToFile() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        LogKit.logDirectory = dir
        LogKit.fileOutput = true
        LogKit.asyncWrite = false
        LogKit.outputFormat = .text
        LogKit.coloredConsoleOutput = true   // 彩色只作用于控制台，不应写入文件

        LogKit.info("彩色测试")
        LogKit.flush()

        let content = try String(contentsOf: LogKit.logFileURL, encoding: .utf8)
        XCTAssertTrue(content.contains("彩色测试"))
        XCTAssertFalse(content.contains("\u{001B}"), "文件输出不应包含 ANSI 转义序列")

        try? FileManager.default.removeItem(at: dir)
    }

    // MARK: - 日志检索

    func testSearchWithinFile() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        let file = dir.appendingPathComponent("test.log")
        let content = "第一行 启动完成\n第二行 网络请求失败\n第三行 网络重试成功\n"
        try content.write(to: file, atomically: true, encoding: .utf8)

        let matches = LogKit.search(containing: "网络", in: file)
        XCTAssertEqual(matches, ["第二行 网络请求失败", "第三行 网络重试成功"])

        let all = LogKit.search(containing: "", in: file)
        XCTAssertEqual(all.count, 3)

        let limited = LogKit.search(containing: "网络", in: file, limit: 1)
        XCTAssertEqual(limited, ["第三行 网络重试成功"], "limit 非零时取最后 N 行")

        try? FileManager.default.removeItem(at: dir)
    }

    func testSearchMissingFileReturnsEmpty() {
        let missing = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathComponent("不存在.log")
        XCTAssertEqual(LogKit.search(containing: "任意", in: missing), [])
    }

    func testChineseAliasForNewFeatures() {
        var captured: [String] = []
        LogKit.customFormatter = { entry in captured.append(entry.message); return entry.message }
        LogKit.限流日志("限流", 间隔: 10, 键: "alias-key")
        LogKit.限流日志("限流", 间隔: 10, 键: "alias-key")
        XCTAssertEqual(captured, ["限流"])

        XCTAssertEqual(LogKit.脱敏(["password": "1"])["password"] as? String, "***")
        XCTAssertEqual(LogKit.敏感字段关键词, LogKit.sensitiveFieldKeywords)
        XCTAssertEqual(LogKit.脱敏敏感字段, LogKit.redactSensitiveData)
        XCTAssertEqual(LogKit.彩色控制台, LogKit.coloredConsoleOutput)
    }

    // MARK: - 日志采样

    func testSamplingRateZeroDropsAllAndIsLazy() {
        LogKit.samplingRate = 0
        var evaluated = false
        func expensive() -> String {
            evaluated = true
            return "昂贵消息"
        }
        var captured: [String] = []
        LogKit.customFormatter = { entry in captured.append(entry.message); return entry.message }

        LogKit.sampled(expensive())

        XCTAssertFalse(evaluated, "采样率 0 时消息不应被求值")
        XCTAssertTrue(captured.isEmpty)
    }

    func testSamplingRateOneAlwaysEmits() {
        var captured: [String] = []
        LogKit.customFormatter = { entry in captured.append(entry.message); return entry.message }

        LogKit.sampled("必然输出", rate: 1.0)

        XCTAssertEqual(captured, ["必然输出"])
    }

    func testSamplingRateIsClamped() {
        // rate 传超界值不应崩溃，仍按 0...1 处理
        LogKit.sampled("a", rate: -5)   // 钳到 0，丢弃
        LogKit.sampled("b", rate: 99)   // 钳到 1，必然输出
    }

    func testSamplingChineseAlias() {
        var captured: [String] = []
        LogKit.customFormatter = { entry in captured.append(entry.message); return entry.message }

        LogKit.采样日志("中文采样", 采样率: 1.0)

        XCTAssertEqual(captured, ["中文采样"])

        // 采样率 属性双向等价
        LogKit.采样率 = 0.3
        XCTAssertEqual(LogKit.采样率, LogKit.samplingRate)
        XCTAssertEqual(LogKit.采样率, 0.3, accuracy: 1e-9)
    }

    // MARK: - 日志导出

    func testExportLogsCopiesCurrentFile() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        LogKit.logDirectory = dir
        LogKit.fileOutput = true
        LogKit.asyncWrite = false

        LogKit.info("导出测试内容")
        LogKit.flush()

        let exported = try LogKit.exportLogs()
        let content = try String(contentsOf: exported, encoding: .utf8)
        XCTAssertTrue(content.contains("导出测试内容"))
        XCTAssertNotEqual(exported.path, LogKit.logFileURL.path, "导出应为独立副本")

        try? FileManager.default.removeItem(at: dir)
    }

    func testExportLogsThrowsWhenMissing() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        LogKit.logDirectory = dir
        LogKit.fileOutput = false   // 不写文件

        XCTAssertThrowsError(try LogKit.exportLogs()) { error in
            XCTAssertEqual(error as? LogKitError, .logFileNotFound)
        }

        try? FileManager.default.removeItem(at: dir)
    }

    func testExportLogsChineseAlias() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        LogKit.logDirectory = dir
        LogKit.fileOutput = true
        LogKit.asyncWrite = false

        LogKit.info("中文导出")
        LogKit.flush()

        let exported = try LogKit.导出日志()
        XCTAssertTrue(try String(contentsOf: exported, encoding: .utf8).contains("中文导出"))

        try? FileManager.default.removeItem(at: dir)
    }

    // MARK: - 崩溃兜底

    func testInstallCrashHandler() {
        LogKit.installCrashHandler()
        LogKit.installCrashHandler()   // 重复调用应被忽略，不崩溃

        XCTAssertTrue(LogKit.crashLogFileURL.lastPathComponent.contains("LogKit-crash"))
        XCTAssertEqual(LogKit.崩溃日志路径, LogKit.crashLogFileURL)
    }
}
