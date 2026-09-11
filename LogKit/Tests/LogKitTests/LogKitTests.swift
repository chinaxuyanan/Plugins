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
        LogKit.maxLogAgeDays = 0
        LogKit.traceId = nil
        LogKit.resetCounts()
        LogKit.resetThrottle()
        LogKit.coloredConsoleOutput = false
        LogKit.redactSensitiveData = true
        LogKit.samplingRate = 0.1
        LogKit.onLog = nil
        LogKit.removeAllSinks()
        LogKit.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        LogKit.timeZone = .current
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
        LogKit.onLog = nil
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

    // MARK: - 日志回调 onLog

    func testOnLogHookReceivesEntry() {
        var captured: [LogEntry] = []
        LogKit.onLog = { entry in captured.append(entry) }

        LogKit.info("回调测试", category: "账号")

        XCTAssertEqual(captured.count, 1)
        XCTAssertEqual(captured[0].message, "回调测试")
        XCTAssertEqual(captured[0].category, "账号")
        XCTAssertEqual(captured[0].level, .info)
    }

    func testOnLogChineseAlias() {
        var captured: [String] = []
        LogKit.日志回调 = { entry in captured.append(entry.message) }
        LogKit.info("中文回调")
        XCTAssertEqual(captured, ["中文回调"])
        XCTAssertNotNil(LogKit.onLog)
    }

    // MARK: - 尾部读取 tail / 归档列表 archivedLogFiles

    func testTailReadsLastLines() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        LogKit.logDirectory = dir
        LogKit.fileOutput = true
        LogKit.asyncWrite = false

        for i in 1...60 {
            LogKit.info("第\(i)行")
        }
        LogKit.flush()

        let lines = LogKit.tail(10)
        XCTAssertEqual(lines.count, 10, "应返回末尾 10 行")
        XCTAssertTrue(lines.last?.contains("第60行") ?? false, "最后一行应为最新日志")
        XCTAssertTrue(lines.first?.contains("第51行") ?? false)

        // 行数超限时返回全部
        let all = LogKit.tail(1000)
        XCTAssertEqual(all.count, 60)

        // 中文别名等价
        XCTAssertEqual(LogKit.尾部读取(10), lines)

        try? FileManager.default.removeItem(at: dir)
    }

    func testTailWithInvalidCountReturnsEmpty() {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        LogKit.logDirectory = dir
        LogKit.fileOutput = true
        LogKit.asyncWrite = false
        LogKit.info("一行")
        LogKit.flush()

        XCTAssertTrue(LogKit.tail(0).isEmpty)
        XCTAssertTrue(LogKit.tail(-1).isEmpty)

        try? FileManager.default.removeItem(at: dir)
    }

    func testArchivedLogFiles() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        LogKit.logDirectory = dir
        LogKit.fileOutput = true
        LogKit.asyncWrite = false
        LogKit.maxFileSize = 1   // 每写一条即超限，触发归档

        LogKit.info("第一条")
        LogKit.flush()
        LogKit.info("第二条")
        LogKit.flush()

        let archived = LogKit.archivedLogFiles
        XCTAssertFalse(archived.isEmpty, "超出 maxFileSize 后应产生归档文件")
        for url in archived {
            XCTAssertTrue(url.lastPathComponent.hasPrefix("LogKit-"))
            XCTAssertTrue(url.lastPathComponent.hasSuffix(".log"))
        }
        // 中文别名等价
        XCTAssertEqual(LogKit.归档日志列表, archived)

        LogKit.maxFileSize = 0
        try? FileManager.default.removeItem(at: dir)
    }

    // MARK: - 输出预判 isEnabled

    func testIsEnabledRespectsLevelAndCategory() {
        LogKit.minimumLevel = .warning
        XCTAssertFalse(LogKit.isEnabled(level: .debug))
        XCTAssertTrue(LogKit.isEnabled(level: .warning))

        LogKit.minimumLevel = .debug
        LogKit.enabledCategories = Set(["网络"])
        XCTAssertTrue(LogKit.isEnabled(level: .info, category: "网络"))
        XCTAssertFalse(LogKit.isEnabled(level: .info, category: "存储"))

        LogKit.enabledCategories = nil
        LogKit.ignoredCategories = Set(["轮询"])
        XCTAssertFalse(LogKit.isEnabled(level: .info, category: "轮询"))
        XCTAssertTrue(LogKit.isEnabled(level: .info, category: "网络"))

        XCTAssertTrue(LogKit.是否输出(级别: .info, 分类: "网络"))
    }

    // MARK: - 作用域追踪 ID withTrace

    func testWithTraceScopesAndRestoresTraceId() {
        LogKit.traceId = "全局"
        var captured: [String?] = []
        LogKit.customFormatter = { entry in captured.append(entry.traceId); return entry.message }

        LogKit.withTrace("请求-1") {
            LogKit.info("块内")
        }
        LogKit.info("块外")

        XCTAssertEqual(captured, ["请求-1", "全局"])
        XCTAssertEqual(LogKit.traceId, "全局", "withTrace 结束后应恢复原 traceId")
    }

    func testWithTraceRestoresOnThrow() {
        LogKit.traceId = "原值"
        enum TestError: Error { case boom }
        XCTAssertThrowsError(try LogKit.withTrace("临时") { () -> Int in throw TestError.boom })
        XCTAssertEqual(LogKit.traceId, "原值")
    }

    func testWithTraceAsyncScopes() async {
        LogKit.traceId = nil
        var captured: String?
        LogKit.customFormatter = { entry in captured = entry.traceId; return entry.message }

        await LogKit.异步追踪执行("异步请求") {
            LogKit.info("异步块内")
        }

        XCTAssertEqual(captured, "异步请求")
        XCTAssertNil(LogKit.traceId)
    }

    // MARK: - LogEntry 序列化

    func testLogEntryJSONSerialization() {
        let entry = LogEntry(timestamp: "2026-09-10 10:00:00.000",
                             level: .info,
                             category: "账号",
                             message: "登录成功",
                             file: "Login.swift",
                             line: 42,
                             fields: ["状态码": 200, "token": "abc"],
                             traceId: "req-1")

        let object = entry.jsonObject
        XCTAssertEqual(object["time"] as? String, "2026-09-10 10:00:00.000")
        XCTAssertEqual(object["level"] as? String, "信息")
        XCTAssertEqual(object["levelValue"] as? Int, LogLevel.info.rawValue)
        XCTAssertEqual(object["category"] as? String, "账号")
        XCTAssertEqual(object["message"] as? String, "登录成功")
        XCTAssertEqual(object["file"] as? String, "Login.swift")
        XCTAssertEqual(object["line"] as? Int, 42)
        XCTAssertEqual(object["traceId"] as? String, "req-1")
        let fields = object["fields"] as? [String: Any]
        XCTAssertEqual(fields?["状态码"] as? Int, 200)

        let json = entry.jsonString
        XCTAssertFalse(json.isEmpty)
        XCTAssertTrue(json.contains("\"message\":\"登录成功\""))

        // 键序稳定（.sortedKeys）：同一份内容两次序列化结果一致
        XCTAssertEqual(entry.JSON字符串, json)

        // 中文别名与英文等价：比较解析后的字典，避免依赖 JSON 键序
        let parsed = try? JSONSerialization.jsonObject(with: Data(json.utf8)) as? [String: Any]
        XCTAssertEqual(parsed?["message"] as? String, "登录成功")
        XCTAssertEqual((parsed?["fields"] as? [String: Any])?["状态码"] as? Int, 200)

        XCTAssertEqual(entry.JSON字典["message"] as? String, "登录成功")
    }

    func testLogEntryJSONOmitsLocationWhenNil() {
        let entry = LogEntry(timestamp: "t",
                             level: .debug,
                             category: "通用",
                             message: "m",
                             file: nil,
                             line: nil,
                             fields: [:],
                             traceId: nil)
        let object = entry.jsonObject
        XCTAssertNil(object["file"])
        XCTAssertNil(object["line"])
        XCTAssertNil(object["traceId"])
        XCTAssertNil(object["fields"])
    }

    // MARK: - 自定义输出去向 / CSV 导出 / 时区 / 按天数清理

    func testAddSinkReceivesEntries() {
        var received: [LogEntry] = []
        let id = LogKit.addSink { received.append($0) }
        XCTAssertEqual(LogKit.sinkCount, 1)

        LogKit.info("送到自定义去向", category: "账号", fields: ["状态码": 200])

        XCTAssertEqual(received.count, 1)
        XCTAssertEqual(received.first?.message, "送到自定义去向")
        XCTAssertEqual(received.first?.category, "账号")
        XCTAssertEqual(received.first?.fields["状态码"] as? Int, 200)

        XCTAssertTrue(LogKit.removeSink(id))
        XCTAssertEqual(LogKit.sinkCount, 0)
        XCTAssertFalse(LogKit.removeSink(id), "重复移除应返回 false")

        LogKit.info("再发一条")
        XCTAssertEqual(received.count, 1, "移除后不应再收到日志")
    }

    func testSinkOnlyGetsFilteredLogsAndChineseAlias() {
        var count = 0
        _ = LogKit.添加输出 { _ in count += 1 }
        XCTAssertEqual(LogKit.输出数量, 1)

        LogKit.minimumLevel = .warning
        LogKit.调试("被过滤，不该送达")
        XCTAssertEqual(count, 0)

        LogKit.警告("会送达")
        XCTAssertEqual(count, 1)

        LogKit.清空输出()
        XCTAssertEqual(LogKit.输出数量, 0)
    }

    func testCSVStringColumnsAndEscaping() {
        let entries = [
            LogEntry(timestamp: "2026-09-10 10:00:00.000", level: .info, category: "账号",
                     message: "登录成功", file: "Login.swift", line: 42,
                     fields: ["订单号": "A100"], traceId: "req-1"),
            LogEntry(timestamp: "2026-09-10 10:00:01.000", level: .error, category: "通用",
                     message: "他说\"你好\", 然后走了", file: nil, line: nil,
                     fields: ["金额": 99], traceId: nil),
        ]

        let rows = LogKit.CSV字符串(条目: entries).components(separatedBy: "\n")
        XCTAssertEqual(rows.count, 3, "表头 + 2 行数据")

        // 表头 = 固定列 + 全部条目 fields 键的并集（按字典序追加）
        let extra = ["订单号", "金额"].sorted().joined(separator: ",")
        XCTAssertEqual(rows[0], "time,level,levelValue,category,message,file,line,traceId,\(extra)")

        // 第一行：缺「金额」→ 该列留空
        XCTAssertEqual(rows[1],
                       "2026-09-10 10:00:00.000,信息,\(LogLevel.info.rawValue),账号,登录成功,Login.swift,42,req-1,A100,")

        // 第二行：缺 file/line/traceId/订单号 → 留空；消息里的引号翻倍转义
        // 列序 time,level,levelValue,category,message,file,line,traceId,订单号,金额
        XCTAssertEqual(rows[2],
                       "2026-09-10 10:00:01.000,错误,\(LogLevel.error.rawValue),通用,\"他说\"\"你好\"\", 然后走了\",,,,,99")

        // 不含表头时只有 2 行
        XCTAssertEqual(LogKit.csvString(from: entries, includeHeader: false).components(separatedBy: "\n").count, 2)
        // 空数组只产生表头
        XCTAssertEqual(LogKit.csvString(from: []).components(separatedBy: "\n").count, 1)
    }

    func testExportCSVWritesFileWithBOM() throws {
        let entry = LogEntry(timestamp: "2026-09-10 10:00:00.000", level: .warning, category: "通用",
                             message: "导出测试", file: "F.swift", line: 1,
                             fields: ["耗时": "12.3"], traceId: nil)
        let url = try LogKit.导出CSV([entry], 文件名: "LogKitTest-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: url) }

        XCTAssertEqual(url.pathExtension, "csv")
        let data = try Data(contentsOf: url)
        XCTAssertTrue(data.starts(with: [0xEF, 0xBB, 0xBF]), "CSV 应以 UTF-8 BOM 开头，Excel 打开中文才不乱码")

        let text = String(data: data, encoding: .utf8) ?? ""
        XCTAssertTrue(text.contains("time,level,levelValue,category,message,file,line,traceId,耗时"))
        XCTAssertTrue(text.contains("导出测试"))
    }

    func testTimeZoneAffectsTimestamp() {
        // 用 "Z" 格式取时区偏移：结果不依赖「当前几点」，不存在跨整点的偶发失败
        LogKit.dateFormat = "Z"
        var captured: LogEntry?
        let id = LogKit.addSink { captured = $0 }
        defer { LogKit.removeSink(id) }

        LogKit.timeZone = TimeZone(secondsFromGMT: 0)!
        LogKit.info("时区测试")
        XCTAssertEqual(captured?.timestamp, "+0000")

        LogKit.时区 = TimeZone(secondsFromGMT: 9 * 3600)!
        LogKit.info("时区测试")
        XCTAssertEqual(captured?.timestamp, "+0900")
    }

    func testMaxLogAgeDaysRemovesExpiredFiles() {
        let fm = FileManager.default
        let dir = fm.temporaryDirectory.appendingPathComponent("LogKitAge-\(UUID().uuidString)", isDirectory: true)
        try? fm.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? fm.removeItem(at: dir) }

        let oldURL = dir.appendingPathComponent("LogKit-2000-01-01.log")
        let recentURL = dir.appendingPathComponent("LogKit-2001-01-01.log")
        _ = fm.createFile(atPath: oldURL.path, contents: Data("旧日志\n".utf8))
        _ = fm.createFile(atPath: recentURL.path, contents: Data("新日志\n".utf8))
        try? fm.setAttributes([.modificationDate: Date().addingTimeInterval(-30 * 86_400)],
                              ofItemAtPath: oldURL.path)
        try? fm.setAttributes([.modificationDate: Date().addingTimeInterval(-86_400)],
                              ofItemAtPath: recentURL.path)

        let previousDir = LogKit.logDirectory
        let previousAge = LogKit.maxLogAgeDays
        let previousOutput = LogKit.fileOutput
        let previousAsync = LogKit.asyncWrite
        defer {
            LogKit.logDirectory = previousDir
            LogKit.maxLogAgeDays = previousAge
            LogKit.fileOutput = previousOutput
            LogKit.asyncWrite = previousAsync
        }

        LogKit.logDirectory = dir
        LogKit.maxLogAgeDays = 7
        LogKit.fileOutput = true
        LogKit.asyncWrite = false
        LogKit.信息("写一条日志触发清理")

        XCTAssertFalse(fm.fileExists(atPath: oldURL.path), "修改时间超过 7 天的日志应被删除")
        XCTAssertTrue(fm.fileExists(atPath: recentURL.path), "7 天内的日志应保留")
        XCTAssertTrue(fm.fileExists(atPath: LogKit.logFileURL.path), "当前日志文件不应被删")
    }

    // MARK: - 条目过滤 LogFilter

    /// 构造一条测试用日志（`date` 显式指定，便于断言时间段过滤）
    private func makeEntry(_ message: String,
                           level: LogLevel = .info,
                           category: String = "通用",
                           fields: [String: Any] = [:],
                           traceId: String? = nil,
                           date: Date = Date()) -> LogEntry {
        LogEntry(timestamp: "2026-09-10 10:00:00.000",
                 date: date,
                 level: level,
                 category: category,
                 message: message,
                 file: "Demo.swift",
                 line: 42,
                 fields: fields,
                 traceId: traceId)
    }

    func testLogFilterByLevelAndCategory() {
        let networkError = makeEntry("网络超时", level: .error, category: "网络")
        let networkInfo = makeEntry("网络正常", level: .info, category: "网络")
        let storageError = makeEntry("磁盘写入失败", level: .error, category: "存储")

        let filter = LogFilter(levels: [.error, .critical], categories: ["网络"])
        XCTAssertTrue(filter.matches(networkError))
        XCTAssertFalse(filter.matches(networkInfo), "级别不符应被过滤")
        XCTAssertFalse(filter.matches(storageError), "分类不符应被过滤")

        let all = [networkError, networkInfo, storageError]
        XCTAssertEqual(filter.filter(all).map(\.message), ["网络超时"])
        XCTAssertEqual(LogKit.filterEntries(all, matching: filter).map(\.message), ["网络超时"])

        // 未设条件时全部通过
        XCTAssertTrue(LogFilter().isEmpty)
        XCTAssertEqual(LogFilter().filter(all).count, 3)
    }

    func testLogFilterKeywordAndTimeRange() {
        let base = Date()
        let old = makeEntry("很久以前", date: base.addingTimeInterval(-600))
        let recent = makeEntry("订单 A100 已支付", fields: ["订单号": "A100"], date: base)
        let entryWithTrace = makeEntry("无关消息", traceId: "req-1", date: base)

        // 关键字命中消息、字段值、追踪 ID（不区分大小写）
        XCTAssertTrue(LogFilter.byKeyword("a100").matches(recent), "应能命中字段值，且忽略大小写")
        XCTAssertTrue(LogFilter.byKeyword("已支付").matches(recent))
        XCTAssertTrue(LogFilter.byKeyword("REQ-1").matches(entryWithTrace))
        XCTAssertFalse(LogFilter.byKeyword("不存在").matches(recent))

        // 时间段：只保留最近 5 分钟
        let range = LogFilter.inRange(from: base.addingTimeInterval(-300))
        XCTAssertFalse(range.matches(old), "超出起始时间的应被过滤")
        XCTAssertTrue(range.matches(recent))

        // 追踪 ID 精确匹配
        XCTAssertTrue(LogFilter.byTraceId("req-1").matches(entryWithTrace))
        XCTAssertFalse(LogFilter.byTraceId("req-2").matches(entryWithTrace))
        XCTAssertFalse(LogFilter.byTraceId("req-1").matches(recent), "无追踪 ID 的条目不应命中")
    }

    func testLogFilterChineseAliases() {
        let entry = makeEntry("超时", level: .error, category: "网络", date: Date())
        let filter = LogFilter(级别: [.error], 分类: ["网络"], 关键字: "超时")
        XCTAssertTrue(filter.matches(entry))
        XCTAssertEqual(LogFilter.按关键字("超时").filter([entry]).count, 1)
        XCTAssertEqual(LogFilter.按级别(.error).filter([entry]).count, 1)
        XCTAssertEqual(LogFilter.按追踪ID("无").filter([entry]).count, 0)
        XCTAssertTrue(LogFilter.时间段(从: Date().addingTimeInterval(-60)).matches(entry))
        // 零参 Filter 没设任何条件 → 为空；下面的中文构造器刚好相反
        XCTAssertTrue(LogFilter().为空)
        // 中文构造器首参「级别」必填（这样零参 LogFilter() 才不会与英文 init 歧义），其余可省
        XCTAssertEqual(LogFilter(级别: nil, 分类: ["网络"]).filter([entry]).count, 1)
        XCTAssertFalse(LogFilter(级别: nil, 分类: ["网络"]).为空)
        XCTAssertTrue(filter.匹配(entry))
        XCTAssertEqual(filter.过滤([entry]).count, 1)
    }

    // MARK: - 内存检索 maxRecentEntries / recentEntries

    func testRecentEntriesBufferKeepsLatest() {
        let previous = LogKit.maxRecentEntries
        defer { LogKit.maxRecentEntries = previous }

        LogKit.maxRecentEntries = 3
        for i in 1...5 {
            LogKit.info("第\(i)条")
        }

        XCTAssertEqual(LogKit.recentEntries.map(\.message), ["第3条", "第4条", "第5条"],
                       "只保留最近 3 条，且按时间从旧到新")

        // 按条件过滤内存中的条目
        let filtered = LogKit.filteredRecentEntries(matching: LogFilter.byKeyword("第4条"))
        XCTAssertEqual(filtered.map(\.message), ["第4条"])

        // 中文别名等价
        XCTAssertEqual(LogKit.最近日志.count, 3)
        XCTAssertEqual(LogKit.过滤最近日志(LogFilter.byKeyword("第5条")).count, 1)

        LogKit.清空最近日志()
        XCTAssertTrue(LogKit.recentEntries.isEmpty)
    }

    func testRecentEntriesDisabledByDefault() {
        XCTAssertEqual(LogKit.maxRecentEntries, 0)
        LogKit.info("不应进内存")
        XCTAssertTrue(LogKit.recentEntries.isEmpty, "maxRecentEntries 为 0 时不保留任何条目")
    }

    // MARK: - 统计摘要 LogSummary

    func testLogSummaryCounts() {
        let base = Date()
        let entries = [
            makeEntry("a", level: .info, category: "网络", date: base.addingTimeInterval(-4)),
            makeEntry("b", level: .info, category: "网络", date: base.addingTimeInterval(-3)),
            makeEntry("c", level: .info, category: "网络", date: base.addingTimeInterval(-2)),
            makeEntry("d", level: .error, category: "存储", date: base.addingTimeInterval(-1)),
            makeEntry("e", level: .critical, category: "通用", date: base),
        ]

        let summary = LogKit.summary(of: entries)
        XCTAssertEqual(summary.total, 5)
        XCTAssertEqual(summary.count(of: .info), 3)
        XCTAssertEqual(summary.count(of: .debug), 0, "未出现的级别应返回 0")
        XCTAssertEqual(summary.errorCount, 2, "错误条数 = 错误 + 严重")
        XCTAssertEqual(summary.errorRate, 0.4, accuracy: 1e-9)
        XCTAssertEqual(summary.topCategories.first?.category, "网络")
        XCTAssertEqual(summary.topCategories.first?.count, 3)
        XCTAssertEqual(summary.duration ?? -1, 4, accuracy: 1e-6)

        let text = summary.text()
        XCTAssertTrue(text.contains("日志共 5 条"))
        XCTAssertTrue(text.contains("错误率：40.0%"))
        XCTAssertTrue(text.contains("分类排行：网络(3)"))

        // 空数组不崩
        let empty = LogSummary(entries: [])
        XCTAssertEqual(empty.total, 0)
        XCTAssertEqual(empty.errorRate, 0, accuracy: 1e-9)
        XCTAssertNil(empty.duration)
    }

    func testLogSummaryChineseAliases() {
        let entry = makeEntry("a", level: .error)
        let summary = LogSummary(条目: [entry], 分类排行数量: 3)
        XCTAssertEqual(summary.总计, 1)
        XCTAssertEqual(summary.各级别条数[.error], 1)
        XCTAssertEqual(summary.最早时间, entry.date)
        XCTAssertEqual(summary.最晚时间, entry.date)
        XCTAssertEqual(summary.级别条数(.error), 1)
        XCTAssertEqual(summary.错误条数, 1)
        XCTAssertEqual(summary.错误率, 1, accuracy: 1e-9)
        XCTAssertEqual(summary.分类排行.count, 1)
        XCTAssertTrue(summary.摘要文本().contains("日志共 1 条"))
    }

    // MARK: - 压缩归档导出 zip

    /// 读取小端 16 位整数（ZIP 头字段用）
    private func le16(_ bytes: [UInt8], _ offset: Int) -> UInt16 {
        UInt16(bytes[offset]) | (UInt16(bytes[offset + 1]) << 8)
    }

    /// 读取小端 32 位整数（ZIP 头字段用）
    private func le32(_ bytes: [UInt8], _ offset: Int) -> UInt32 {
        UInt32(bytes[offset])
            | (UInt32(bytes[offset + 1]) << 8)
            | (UInt32(bytes[offset + 2]) << 16)
            | (UInt32(bytes[offset + 3]) << 24)
    }

    func testZipWriterCRC32() {
        // 已知校验向量：空串 → 0，'123456789' → 0xCBF43926
        XCTAssertEqual(ZipWriter.crc32(Data()), 0)
        XCTAssertEqual(ZipWriter.crc32(Data("123456789".utf8)), 0xCBF43926)
    }

    func testZipWriterArchiveStructure() {
        let content = Data("你好".utf8)     // 6 字节 UTF-8
        let entries = [
            ZipWriter.Entry(name: "a.txt", data: content, modificationDate: Date()),
            ZipWriter.Entry(name: "b.log", data: Data("hello".utf8), modificationDate: Date()),
        ]
        let bytes = [UInt8](ZipWriter.archive(entries))

        // 本地文件头：签名 / 压缩方式 0（存储）/ CRC / 大小 / 文件名长度
        XCTAssertEqual(Array(bytes.prefix(4)), [0x50, 0x4B, 0x03, 0x04])
        XCTAssertEqual(le16(bytes, 8), 0, "应采用存储方式（不压缩）")
        XCTAssertEqual(le32(bytes, 14), ZipWriter.crc32(content))
        XCTAssertEqual(le32(bytes, 18), UInt32(content.count), "存储方式下压缩后大小 = 原始大小")
        XCTAssertEqual(le16(bytes, 26), 5, "文件名 'a.txt' 长度应为 5")

        // 中央目录结束记录在最后 22 字节：签名 + 总条目数
        let eocd = bytes.count - 22
        XCTAssertEqual(Array(bytes[eocd..<(eocd + 4)]), [0x50, 0x4B, 0x05, 0x06])
        XCTAssertEqual(le16(bytes, eocd + 8), 2, "应记录 2 个条目")
        XCTAssertEqual(le16(bytes, eocd + 10), 2)
        // 空数组也应是合法 zip（只有结束记录）
        XCTAssertEqual([UInt8](ZipWriter.archive([])).count, 22)
    }

    func testExportArchive() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: dir) }

        let previousDir = LogKit.logDirectory
        let previousOutput = LogKit.fileOutput
        let previousAsync = LogKit.asyncWrite
        defer {
            LogKit.logDirectory = previousDir
            LogKit.fileOutput = previousOutput
            LogKit.asyncWrite = previousAsync
        }

        LogKit.logDirectory = dir
        LogKit.fileOutput = true
        LogKit.asyncWrite = false
        LogKit.info("压缩包测试内容")
        LogKit.flush()

        let zip = try LogKit.exportArchive()
        XCTAssertEqual(zip.pathExtension, "zip")
        let data = try Data(contentsOf: zip)
        let bytes = [UInt8](data)
        XCTAssertEqual(Array(bytes.prefix(4)), [0x50, 0x4B, 0x03, 0x04], "应是合法的 ZIP 本地文件头")
        let name = LogKit.logFileURL.lastPathComponent
        XCTAssertNotNil(data.range(of: Data(name.utf8)), "包内应包含当前日志文件名")

        // 中文别名等价
        let alias = try LogKit.导出压缩包(含归档: false)
        XCTAssertTrue(FileManager.default.fileExists(atPath: alias.path))
    }

    func testExportArchiveThrowsWhenNoLogFile() {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: dir) }

        let previousDir = LogKit.logDirectory
        let previousOutput = LogKit.fileOutput
        defer {
            LogKit.logDirectory = previousDir
            LogKit.fileOutput = previousOutput
        }

        LogKit.logDirectory = dir
        LogKit.fileOutput = false
        XCTAssertThrowsError(try LogKit.exportArchive()) { error in
            XCTAssertEqual(error as? LogKitError, .logFileNotFound)
        }
    }

    // MARK: - 按天自动轮转 dailyRotation

    func testDailyRotationArchivesPreviousDayFile() throws {
        let fm = FileManager.default
        let dir = fm.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fm.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? fm.removeItem(at: dir) }

        // 放一个「昨天的」按天日志文件（过去某天，名字符合 LogKit-yyyy-MM-dd.log）
        let yesterday = dir.appendingPathComponent("LogKit-2000-01-01.log")
        _ = fm.createFile(atPath: yesterday.path, contents: Data("旧日志\n".utf8))
        // 崩溃日志改名后不应被当成按天文件
        let crash = dir.appendingPathComponent("LogKit-crash.log")
        _ = fm.createFile(atPath: crash.path, contents: Data("崩溃\n".utf8))

        let previousDir = LogKit.logDirectory
        let previousOutput = LogKit.fileOutput
        let previousAsync = LogKit.asyncWrite
        let previousRotation = LogKit.dailyRotation
        defer {
            LogKit.logDirectory = previousDir
            LogKit.fileOutput = previousOutput
            LogKit.asyncWrite = previousAsync
            LogKit.dailyRotation = previousRotation
        }

        LogKit.logDirectory = dir
        LogKit.fileOutput = true
        LogKit.asyncWrite = false
        LogKit.dailyRotation = true
        LogKit.信息("跨天写入")

        XCTAssertFalse(fm.fileExists(atPath: yesterday.path), "非今天的按天文件应被归档改名")
        XCTAssertTrue(LogKit.archivedLogFiles.contains { $0.lastPathComponent.hasPrefix("LogKit-2000-01-01-") },
                      "归档文件名应为 LogKit-旧日期-时间戳.log")
        XCTAssertTrue(fm.fileExists(atPath: crash.path), "崩溃日志不应被归档")
        XCTAssertTrue(fm.fileExists(atPath: LogKit.logFileURL.path), "当前日志文件应正常创建")

        // 中文别名双向等价
        XCTAssertTrue(LogKit.按天轮转)
        LogKit.按天轮转 = false
        XCTAssertFalse(LogKit.dailyRotation)
    }

    func testDailyRotationDisabledKeepsOldFile() throws {
        let fm = FileManager.default
        let dir = fm.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fm.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? fm.removeItem(at: dir) }

        let old = dir.appendingPathComponent("LogKit-2000-01-01.log")
        _ = fm.createFile(atPath: old.path, contents: Data("旧日志\n".utf8))

        let previousDir = LogKit.logDirectory
        let previousOutput = LogKit.fileOutput
        let previousAsync = LogKit.asyncWrite
        let previousRotation = LogKit.dailyRotation
        defer {
            LogKit.logDirectory = previousDir
            LogKit.fileOutput = previousOutput
            LogKit.asyncWrite = previousAsync
            LogKit.dailyRotation = previousRotation
        }

        LogKit.logDirectory = dir
        LogKit.fileOutput = true
        LogKit.asyncWrite = false
        LogKit.dailyRotation = false
        LogKit.信息("普通写入")

        XCTAssertTrue(fm.fileExists(atPath: old.path), "未开启按天轮转时不应动旧文件")
    }

    // MARK: - JSON 导出 jsonString / exportJSON（第九轮）

    private func makeExportEntry(_ message: String,
                                 level: LogLevel = .info,
                                 category: String = "通用",
                                 fields: [String: Any] = [:]) -> LogEntry {
        LogEntry(timestamp: "2026-09-10 10:00:00.000",
                 level: level,
                 category: category,
                 message: message,
                 file: "Demo.swift",
                 line: 42,
                 fields: fields,
                 traceId: nil)
    }

    func testJSONStringFromEntries() {
        let entries = [
            makeExportEntry("登录成功", category: "账号", fields: ["订单号": "A100"]),
            makeExportEntry("超时", level: .error),
        ]

        let json = LogKit.jsonString(from: entries)
        // 能解析回数组，且元素数、字段都对
        let array = try? JSONSerialization.jsonObject(with: Data(json.utf8)) as? [[String: Any]]
        XCTAssertEqual(array?.count, 2)
        XCTAssertEqual(array?[0]["message"] as? String, "登录成功")
        XCTAssertEqual(array?[0]["category"] as? String, "账号")
        XCTAssertEqual(array?[1]["level"] as? String, "错误")
        XCTAssertEqual((array?[0]["fields"] as? [String: Any])?["订单号"] as? String, "A100")

        // 默认美化（带换行）；关闭后应为单行
        XCTAssertTrue(json.contains("\n"))
        XCTAssertFalse(LogKit.jsonString(from: entries, prettyPrinted: false).contains("\n"))

        // 空数组输出合法 JSON
        XCTAssertEqual(LogKit.jsonString(from: []), "[]")

        // 中文别名等价，且键序稳定（.sortedKeys）
        XCTAssertEqual(LogKit.JSON字符串(条目: entries), json)
    }

    func testExportJSONWritesFile() throws {
        let entries = [makeExportEntry("导出成功", fields: ["金额": 99])]
        let url = try LogKit.导出JSON(entries, 文件名: "LogKitTest-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: url) }

        XCTAssertEqual(url.pathExtension, "json")
        let data = try Data(contentsOf: url)
        // JSON 不带 BOM（BOM 会让严格解析器报错）
        XCTAssertFalse(data.starts(with: [0xEF, 0xBB, 0xBF]))

        let array = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]]
        XCTAssertEqual(array?.first?["message"] as? String, "导出成功")
        XCTAssertEqual((array?.first?["fields"] as? [String: Any])?["金额"] as? Int, 99)
    }

    // MARK: - 日志反解析 parseLogLine / parseLogFile（第九轮）

    func testParseLogLineFullLine() {
        let line = "[2026-09-10 10:00:00.000] [信息] [账号] 登录成功 @ Login.swift:42 [traceId: req-1] [金额=99, 订单号=A100]"
        guard let entry = LogKit.parseLogLine(line) else { return XCTFail("应能解析完整日志行") }

        XCTAssertEqual(entry.timestamp, "2026-09-10 10:00:00.000")
        XCTAssertEqual(entry.level, .info)
        XCTAssertEqual(entry.category, "账号")
        XCTAssertEqual(entry.message, "登录成功")
        XCTAssertEqual(entry.file, "Login.swift")
        XCTAssertEqual(entry.line, 42)
        XCTAssertEqual(entry.traceId, "req-1")
        // 字段值一律按字符串
        XCTAssertEqual(entry.fields["金额"] as? String, "99")
        XCTAssertEqual(entry.fields["订单号"] as? String, "A100")

        // 中文别名等价转发
        XCTAssertEqual(LogKit.解析日志行(line)?.message, "登录成功")
    }

    func testParseLogLineOptionalSuffixes() {
        // 只有最小三段：级别 / 分类 / 消息
        let minimal = "[2026-09-10 10:00:00.000] [debug] [通用] 最简一行"
        let entry = LogKit.parseLogLine(minimal)
        XCTAssertEqual(entry?.level, .debug)
        XCTAssertEqual(entry?.message, "最简一行")
        XCTAssertNil(entry?.file)
        XCTAssertNil(entry?.line)
        XCTAssertNil(entry?.traceId)
        XCTAssertTrue(entry?.fields.isEmpty ?? false)

        // 消息里带空格、冒号、方括号也不应被误伤（尾部的都不是合法字段块）
        let tricky = "[2026-09-10 10:00:00.000] [警告] [通用] 处理 [重要] 数据: 完成 @ F.swift:1"
        XCTAssertEqual(LogKit.parseLogLine(tricky)?.message, "处理 [重要] 数据: 完成")

        // 英文级别名也行
        XCTAssertEqual(LogKit.parseLogLine("[t] [warn] [通用] 英文级别")?.level, .warning)

        // 非日志行 / 级别不认识 → nil
        XCTAssertNil(LogKit.parseLogLine("随便一行文本"))
        XCTAssertNil(LogKit.parseLogLine("[只有一段]"))
        XCTAssertNil(LogKit.parseLogLine("[t] [不认识的级别] [通用] 消息"))
    }

    func testParseLogFileSplitsLines() {
        let contents = [
            "[2026-09-10 10:00:00.000] [信息] [网络] 请求开始",
            "这条不是日志，应被跳过",
            "[2026-09-10 10:00:01.000] [错误] [网络] 请求失败 @ Net.swift:9",
        ].joined(separator: "\n")

        let entries = LogKit.日志反解析(contents)
        XCTAssertEqual(entries.count, 2, "无法识别的行应被跳过")
        XCTAssertEqual(entries.map(\.message), ["请求开始", "请求失败"])
        XCTAssertEqual(entries[1].level, .error)
        XCTAssertEqual(entries[1].line, 9)
    }

    func testParseLogFileReadsURL() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: dir) }
        let file = dir.appendingPathComponent("sample.log")
        try "[2026-09-10 10:00:00.000] [信息] [通用] 来自文件\n".write(to: file, atomically: true, encoding: .utf8)

        let entries = LogKit.日志反解析(文件: file)
        XCTAssertEqual(entries.map(\.message), ["来自文件"])

        // 文件不存在 → 空数组，不抛错
        XCTAssertTrue(LogKit.parseLogFile(at: dir.appendingPathComponent("不存在.log")).isEmpty)
    }

    /// 真实落盘 → 反解析 的往返：比手搓字符串更能锁住 `.text` 格式契约
    func testTextLogRoundTripThroughFile() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: dir) }

        let previousDir = LogKit.logDirectory
        let previousOutput = LogKit.fileOutput
        let previousAsync = LogKit.asyncWrite
        defer {
            LogKit.logDirectory = previousDir
            LogKit.fileOutput = previousOutput
            LogKit.asyncWrite = previousAsync
        }

        LogKit.logDirectory = dir
        LogKit.fileOutput = true
        LogKit.asyncWrite = false
        LogKit.outputFormat = .text
        LogKit.info("登录成功", category: "账号", fields: ["订单号": "A100"])

        guard let line = LogKit.tail(1).first else { return XCTFail("应写入一行日志") }
        guard let entry = LogKit.parseLogLine(line) else { return XCTFail("应能反解析刚写入的日志") }

        XCTAssertEqual(entry.message, "登录成功")
        XCTAssertEqual(entry.category, "账号")
        XCTAssertEqual(entry.level, .info)
        XCTAssertEqual(entry.fields["订单号"] as? String, "A100")
        XCTAssertEqual(entry.file, "LogKitTests.swift")
    }

    // MARK: - 摘要导出 exportSummary（第九轮）

    func testExportSummaryWritesFile() throws {
        let entries = [
            makeExportEntry("a", level: .info, category: "网络"),
            makeExportEntry("b", level: .error, category: "网络"),
            makeExportEntry("c", level: .critical, category: "存储"),
        ]
        let url = try LogKit.导出摘要(条目: entries, 文件名: "LogKitTest-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: url) }

        XCTAssertEqual(url.pathExtension, "txt")
        let text = try String(contentsOf: url, encoding: .utf8)
        XCTAssertTrue(text.contains("LogKit 日志摘要"))
        XCTAssertTrue(text.contains("生成时间："))
        XCTAssertTrue(text.contains("日志共 3 条"))
        XCTAssertTrue(text.contains("网络(2)"), "分类排行应列出出现最多的分类")

        // 直接导出已有摘要对象也等价
        let summary = LogKit.summary(of: entries)
        let url2 = try LogKit.exportSummary(summary)
        defer { try? FileManager.default.removeItem(at: url2) }
        XCTAssertTrue(try String(contentsOf: url2, encoding: .utf8).contains("日志共 3 条"))
    }

    // MARK: - 按小时自动轮转 hourlyRotation（第九轮）

    func testHourlyRotationUsesHourlyFileName() throws {
        let dir = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: dir) }

        let previousDir = LogKit.logDirectory
        let previousOutput = LogKit.fileOutput
        let previousAsync = LogKit.asyncWrite
        let previousHourly = LogKit.hourlyRotation
        defer {
            LogKit.logDirectory = previousDir
            LogKit.fileOutput = previousOutput
            LogKit.asyncWrite = previousAsync
            LogKit.hourlyRotation = previousHourly
        }

        LogKit.logDirectory = dir
        LogKit.fileOutput = true
        LogKit.asyncWrite = false
        LogKit.hourlyRotation = true
        LogKit.info("按小时轮转")

        // 文件名应为 LogKit-yyyy-MM-dd-HH.log —— 拆段判断，不依赖「当前几点」
        let name = LogKit.logFileURL.lastPathComponent
        XCTAssertTrue(name.hasPrefix("LogKit-"))
        XCTAssertTrue(name.hasSuffix(".log"))
        let body = name.dropFirst("LogKit-".count).dropLast(".log".count)
        let parts = body.split(separator: "-", omittingEmptySubsequences: false)
        XCTAssertEqual(parts.count, 4, "按小时文件名应为 LogKit-yyyy-MM-dd-HH.log")
        XCTAssertEqual(parts.first?.count, 4, "年份 4 位")
        XCTAssertTrue(parts.dropFirst().allSatisfy { $0.count == 2 && $0.allSatisfy(\.isNumber) })

        // 中文别名双向等价
        XCTAssertTrue(LogKit.按小时轮转)
        LogKit.按小时轮转 = false
        XCTAssertFalse(LogKit.hourlyRotation)
    }

    func testHourlyRotationArchivesStalePeriodFileOnly() throws {
        let fm = FileManager.default
        let dir = fm.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try fm.createDirectory(at: dir, withIntermediateDirectories: true)
        defer { try? fm.removeItem(at: dir) }

        // 一个「过去的」按小时文件（LogKit-yyyy-MM-dd-HH.log）→ 应被归档改名
        let stale = dir.appendingPathComponent("LogKit-2000-01-01-03.log")
        _ = fm.createFile(atPath: stale.path, contents: Data("旧小时日志\n".utf8))
        // 一个已经归档过的名字（末尾多了 9 位 HHmmssSSS）→ 不应被二次归档
        let alreadyArchived = dir.appendingPathComponent("LogKit-2000-01-01-030000123.log")
        _ = fm.createFile(atPath: alreadyArchived.path, contents: Data("已归档\n".utf8))

        let previousDir = LogKit.logDirectory
        let previousOutput = LogKit.fileOutput
        let previousAsync = LogKit.asyncWrite
        let previousHourly = LogKit.hourlyRotation
        defer {
            LogKit.logDirectory = previousDir
            LogKit.fileOutput = previousOutput
            LogKit.asyncWrite = previousAsync
            LogKit.hourlyRotation = previousHourly
        }

        LogKit.logDirectory = dir
        LogKit.fileOutput = true
        LogKit.asyncWrite = false
        LogKit.hourlyRotation = true
        LogKit.info("触发轮转")

        XCTAssertFalse(fm.fileExists(atPath: stale.path), "非当前小时的按小时文件应被归档改名")
        XCTAssertTrue(LogKit.archivedLogFiles.contains { $0.lastPathComponent.hasPrefix("LogKit-2000-01-01-03") },
                      "归档名应为 LogKit-原小时-时间戳.log")
        XCTAssertTrue(fm.fileExists(atPath: alreadyArchived.path),
                      "已带 9 位时间戳的归档名不应被再次归档")
    }
}
