import Foundation
import Dispatch
import Darwin

/// LogKit —— 中文友好的日志打印工具库
///
/// 解决「日志级别混乱、输出格式不统一」的痛点：
/// - 内置调试 / 信息 / 警告 / 错误 / 严重五级日志，见名知意；
/// - 统一输出格式（时间 / 级别 / 分类 / 消息 / 位置），可选控制台或文件输出；
/// - 支持单行文本 / JSON 两种输出格式，文件写入可异步，避免阻塞主线程；
/// - 支持 `measure` 耗时测量、附加结构化字段 `fields`、自定义格式闭包 `customFormatter`；
/// - 支持 `ScopedLogger` 作用域日志器（分模块分类）、`PerformanceCounter` 性能计数器（累计耗时）、`OSLogger` 系统日志桥接（os.Logger）；
/// - 支持追踪 ID `traceId`（全局 / 作用域日志器两级，串联一次请求的全部日志）、按构建环境自适应默认级别（DEBUG `.debug` / RELEASE `.warning`）、级别计数统计（`totalCount(by:)` / `totalCount()` / `resetCounts()`）；
/// - 支持自定义输出去向 `addSink`（控制台 / 文件之外的第三方接收者，可移除）、按天数清理 `maxLogAgeDays`、CSV 导出 `exportCSV`、时区配置 `timeZone`；
/// - 支持内存检索（`maxRecentEntries` 保留最近若干条 + `LogFilter` 按级别 / 分类 / 关键字 / 时间段 / 追踪 ID 过滤）、统计摘要 `LogSummary`、压缩归档导出 `exportArchive`（纯 Foundation 打包 zip）、按天自动轮转 `dailyRotation`；
/// - 提供中文命名别名（`LogKit.调试(...)` 等），补全列表直接显示中文。
///
/// 快速开始：
/// ```swift
/// import LogKit
///
/// LogKit.minimumLevel = .debug   // 只输出 debug 及以上级别
/// LogKit.fileOutput = true       // 同时写入日志文件
///
/// LogKit.调试("视图已加载，耗时 \(elapsed) ms")
/// LogKit.警告("网络请求超时", 分类: "网络")
///
/// // 耗时测量
/// LogKit.measure("解析数据") { try parser.parse(data) }
///
/// // 结构化字段（配合 JSON 输出）
/// LogKit.info("请求完成", fields: ["接口": "/api/user", "状态码": 200])
/// ```
public enum LogKit {

    /// 库版本号
    public static let version = "0.12.0"

    // MARK: - 配置

    /// 最低输出级别：低于该级别的日志会被过滤
    ///
    /// 默认值随构建环境自适应：DEBUG 构建为 `.debug`（全部输出），RELEASE 构建为 `.warning`（只输出警告及以上）。
    /// 可随时手动覆盖为任意级别。
    public static var minimumLevel: LogLevel = LogKit.adaptiveMinimumLevel

    /// 环境自适应的默认最低级别：DEBUG 构建返回 `.debug`，RELEASE 构建返回 `.warning`
    ///
    /// 一般用于 App 启动时按构建环境初始化日志级别：
    /// ```swift
    /// LogKit.minimumLevel = LogKit.adaptiveMinimumLevel
    /// ```
    /// - Note: `minimumLevel` 的默认值本身就是这个自适应值；只有在你手动改过之后才需要重新套用。
    public static var adaptiveMinimumLevel: LogLevel {
        #if DEBUG
        return .debug
        #else
        return .warning
        #endif
    }

    /// 全局追踪 ID：设置后，后续每条日志都会附带该 ID
    ///
    /// 用于把同一次请求 / 同一次用户操作产生的多条日志串联起来（配合 JSON 输出的 `traceId` 字段）。
    /// 作用域日志器 `ScopedLogger` 也可以单独设置 `traceId`，会覆盖此全局值。
    /// 设为 `nil` 表示不带追踪 ID（默认 `nil`）。
    ///
    /// - Example:
    ///   ```swift
    ///   LogKit.traceId = "req-\(UUID().uuidString)"
    ///   LogKit.info("开始处理订单")   // → {"traceId":"req-...", ...}
    ///   ```
    public static var traceId: String? = nil

    /// 是否输出到控制台（默认 `true`）
    public static var consoleOutput: Bool = true

    /// 是否同时写入日志文件（默认 `false`）
    public static var fileOutput: Bool = false

    /// 是否在输出中附带「文件:行」位置（默认 `true`）
    public static var showLocation: Bool = true

    /// 输出格式（默认 `.text` 单行文本）
    ///
    /// - `.text`：人类可读的单行文本，形如 `[时间] [级别] [分类] 消息 @ 文件:行`
    /// - `.json`：结构化 JSON 对象，便于日志采集 / 机器解析
    ///
    /// - Note: 设置 `customFormatter` 后本项失效。
    public static var outputFormat: LogOutputFormat = .text

    /// 是否异步写文件（默认 `true`）
    ///
    /// 开启后，文件写入在后台串行队列执行，不阻塞当前线程（尤其是主线程）。
    /// 关闭则同步写入，调用返回时日志已落盘。
    ///
    /// - Note: `.critical` 严重日志无论此开关如何，始终同步落盘，避免进程崩溃时丢失。
    public static var asyncWrite: Bool = true

    /// 日志文件所在目录（默认 Application Support/LogKit）
    public static var logDirectory: URL = {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return base.appendingPathComponent("LogKit", isDirectory: true)
    }()

    /// 时间戳格式（默认 `yyyy-MM-dd HH:mm:ss.SSS`）
    public static var dateFormat: String = "yyyy-MM-dd HH:mm:ss.SSS"

    /// 时间戳使用的时区（默认 `.current` 跟随系统）
    ///
    /// 影响日志行里的时间戳，以及日志文件名里的日期（`LogKit-yyyy-MM-dd.log`）。
    /// 需要统一多端日志时间（比如都按 UTC 记录）时设置：
    ///
    /// - Example:
    ///   ```swift
    ///   LogKit.timeZone = TimeZone(identifier: "UTC")!   // 时间戳按 UTC 记录
    ///   ```
    public static var timeZone: TimeZone = .current

    /// 单个日志文件大小上限（字节）
    ///
    /// 当前日志文件达到该大小时，会自动归档（重命名为带时间戳的文件）并开启新文件。
    /// 设为 `0` 表示不按大小轮转（默认 `0`）。
    public static var maxFileSize: Int = 0

    /// 最多保留的日志文件数量
    ///
    /// 日志目录里 `LogKit-*.log` 文件超过该数量时，自动删除最旧的。
    /// 设为 `0` 表示不清理（默认 `0`）。
    public static var maxLogFiles: Int = 0

    /// 日志文件最长保留天数
    ///
    /// 日志目录里修改时间超过该天数的 `LogKit-*.log` 文件会被自动删除（当前正在写的文件除外）。
    /// 设为 `0` 表示不按天数清理（默认 `0`）。
    ///
    /// - Note: 与 `maxLogFiles` 可同时生效：先按天数清掉过期文件，再按数量只留最新的若干个。
    public static var maxLogAgeDays: Int = 0

    /// 是否按天自动轮转日志文件（默认 `false`）
    ///
    /// 日志文件名本身就带日期（`LogKit-yyyy-MM-dd.log`），跨天后自然写入新文件；
    /// 打开本开关后，跨天第一次写日志时还会把**昨天的文件归档**（重命名为
    /// `LogKit-旧日期-时间戳.log`），让日志目录里「当前文件」永远只有一个。
    ///
    /// - Note: 归档后的文件同样受 `maxLogFiles` / `maxLogAgeDays` 管理。
    ///
    /// - Example:
    ///   ```swift
    ///   LogKit.fileOutput = true
    ///   LogKit.dailyRotation = true       // 每天一个文件，跨天自动归档昨天
    ///   LogKit.maxLogFiles = 7            // 只留最近 7 个
    ///   ```
    public static var dailyRotation: Bool = false

    /// 内存中保留的最近日志条数上限（默认 `0`，即不保留）
    ///
    /// 设为正数后，日志除了写控制台 / 文件，还会在内存里保留最近 `maxRecentEntries` 条
    /// `LogEntry`，供 `recentEntries` 读取、`filteredRecentEntries(matching:)` 检索、
    /// `summaryOfRecentEntries()` 汇总——用于做「App 内日志面板」这类功能，无需读文件。
    ///
    /// - Note: 会带来额外的内存占用与一次 `LogEntry` 组装开销；只在确有用处时打开。
    ///   每条日志都会保留，因此级别 / 分类过滤（`minimumLevel` 等）依然生效——被过滤掉的日志不会进内存。
    public static var maxRecentEntries: Int = 0

    /// 分类白名单：只输出这些分类的日志
    ///
    /// `nil` 表示全部输出（默认 `nil`）。设置后，不在名单里的分类会被直接跳过。
    ///
    /// - Example:
    ///   ```swift
    ///   LogKit.enabledCategories = ["网络", "存储"]
    ///   ```
    public static var enabledCategories: Set<String>? = nil

    /// 分类黑名单：跳过这些分类的日志
    ///
    /// 默认空集合。
    ///
    /// - Example:
    ///   ```swift
    ///   LogKit.ignoredCategories = ["轮询"]
    ///   ```
    public static var ignoredCategories: Set<String> = []

    /// 自定义格式闭包：完全接管每条日志的最终字符串
    ///
    /// 设置后，`outputFormat` 将被忽略；每条日志会先组装成 `LogEntry`（时间 / 级别 / 分类 / 消息 / 位置 / 字段），
    /// 再交给此闭包拼出最终字符串。设为 `nil` 恢复内置的文本 / JSON 格式（默认 `nil`）。
    ///
    /// - Example:
    ///   ```swift
    ///   LogKit.customFormatter = { entry in
    ///       "\(entry.timestamp) | \(entry.level.chineseName) | \(entry.message)"
    ///   }
    ///   ```
    public static var customFormatter: ((LogEntry) -> String)? = nil

    /// 是否对敏感字段值脱敏（默认 `true`）
    ///
    /// 开启后，`fields` 里键名命中 `sensitiveFieldKeywords` 的值会被替换为 `***`，
    /// 防止密码、令牌等敏感信息写进日志。关闭则不脱敏。
    public static var redactSensitiveData: Bool = true

    /// 敏感字段名关键词（不区分大小写，命中即脱敏）
    ///
    /// 键名包含任一关键词即视为敏感字段。可自行增删。
    public static var sensitiveFieldKeywords: Set<String> = [
        "password", "token", "secret", "authorization", "apikey", "api_key",
        "privatekey", "private_key", "accesskey", "access_key", "credential"
    ]

    /// 是否在控制台按级别输出 ANSI 彩色（默认 `false`）
    ///
    /// 仅控制台、仅 `.text` 格式、且未设置 `customFormatter` 时生效；日志文件与 JSON 输出始终不含颜色码。
    /// 在支持 ANSI 的终端里，不同级别显示不同颜色：调试灰 / 信息青 / 警告黄 / 错误红 / 严重红底白字。
    public static var coloredConsoleOutput: Bool = false

    // MARK: - 输出方法

    /// 调试日志
    ///
    /// - Parameters:
    ///   - message: 日志内容（惰性求值，被过滤时不会执行）
    ///   - category: 分类名，默认「通用」
    ///   - fields: 附加的扩展字段（键值对，配合 `.json` 输出会成为 `fields` 子对象）
    ///   - file: 调用处文件名（默认自动填充）
    ///   - line: 调用处行号（默认自动填充）
    public static func debug(_ message: @autoclosure () -> Any,
                             category: String = "通用",
                             fields: [String: Any] = [:],
                             file: String = #file, line: Int = #line) {
        log(.debug, message, category: category, fields: fields, file: file, line: line)
    }

    /// 信息日志
    ///
    /// - Parameters:
    ///   - message: 日志内容（惰性求值）
    ///   - category: 分类名，默认「通用」
    ///   - fields: 附加的扩展字段（键值对）
    public static func info(_ message: @autoclosure () -> Any,
                            category: String = "通用",
                            fields: [String: Any] = [:],
                            file: String = #file, line: Int = #line) {
        log(.info, message, category: category, fields: fields, file: file, line: line)
    }

    /// 警告日志
    ///
    /// - Parameters:
    ///   - message: 日志内容（惰性求值）
    ///   - category: 分类名，默认「通用」
    ///   - fields: 附加的扩展字段（键值对）
    public static func warning(_ message: @autoclosure () -> Any,
                               category: String = "通用",
                               fields: [String: Any] = [:],
                               file: String = #file, line: Int = #line) {
        log(.warning, message, category: category, fields: fields, file: file, line: line)
    }

    /// 错误日志
    ///
    /// - Parameters:
    ///   - message: 日志内容（惰性求值）
    ///   - category: 分类名，默认「通用」
    ///   - fields: 附加的扩展字段（键值对）
    public static func error(_ message: @autoclosure () -> Any,
                             category: String = "通用",
                             fields: [String: Any] = [:],
                             file: String = #file, line: Int = #line) {
        log(.error, message, category: category, fields: fields, file: file, line: line)
    }

    /// 严重日志
    ///
    /// - Parameters:
    ///   - message: 日志内容（惰性求值）
    ///   - category: 分类名，默认「通用」
    ///   - fields: 附加的扩展字段（键值对）
    public static func critical(_ message: @autoclosure () -> Any,
                                category: String = "通用",
                                fields: [String: Any] = [:],
                                file: String = #file, line: Int = #line) {
        log(.critical, message, category: category, fields: fields, file: file, line: line)
    }

    // MARK: - 限流输出

    /// 限流日志：同一调用点（或同一 `key`）在 `interval` 秒内只输出一次
    ///
    /// 用于高频日志防刷屏——轮询、手势拖动、逐帧回调等场景，只在窗口期内输出第一条，其余跳过。
    /// 默认按「文件:行:级别」作为调用点标识；也可用 `key` 自定义去重维度。
    ///
    /// - Parameters:
    ///   - message: 日志内容（惰性求值，被限流时不会执行）
    ///   - level: 日志级别，默认 `.debug`
    ///   - interval: 限流窗口（秒），默认 `1`
    ///   - key: 自定义去重键（可选）；不传则用「文件:行:级别」
    ///   - category: 分类名，默认「通用」
    ///   - fields: 附加的扩展字段（键值对）
    ///
    /// - Example:
    ///   ```swift
    ///   // 同一调用点 1 秒内只输出一次
    ///   LogKit.throttled("滚动位置 \(offset)", level: .debug, interval: 1)
    ///   ```
    public static func throttled(_ message: @autoclosure () -> Any,
                                 level: LogLevel = .debug,
                                 interval: TimeInterval = 1,
                                 key: String? = nil,
                                 category: String = "通用",
                                 fields: [String: Any] = [:],
                                 file: String = #file, line: Int = #line) {
        let throttleKey = key ?? "\(file):\(line):\(level.rawValue)"
        let now = Date()
        throttleLock.lock()
        defer { throttleLock.unlock() }
        if let last = throttleLastEmit[throttleKey], now.timeIntervalSince(last) < interval {
            return   // 限流窗口内，跳过
        }
        throttleLastEmit[throttleKey] = now
        log(level, message, category: category, fields: fields, file: file, line: line)
    }

    /// 清除全部限流记录
    ///
    /// 清空后，下一次限流日志会立即输出。
    public static func resetThrottle() {
        throttleLock.lock()
        defer { throttleLock.unlock() }
        throttleLastEmit.removeAll()
    }

    // MARK: - 日志回调

    /// 日志回调钩子：每条「通过过滤、真正输出」的日志都会回调一次
    ///
    /// 在日志写入控制台 / 文件之前，把组装好的 `LogEntry` 交给开发者，可用于自定义日志面板、
    /// 实时刷新日志界面等场景。回调在调用日志方法的线程同步执行，请避免在其中做重活。
    /// 设为 `nil` 可取消回调。
    public static var onLog: ((LogEntry) -> Void)?

    // MARK: - 自定义输出去向（Sink）

    /// 注册一个自定义输出去向
    ///
    /// 在控制台 / 文件之外，把每条「通过过滤、真正输出」的日志额外送到这里——比如上报到服务端、
    /// 写进自建日志面板、转发给第三方 SDK。可注册多个，按注册顺序依次调用。
    ///
    /// - Parameter sink: 收到 `LogEntry` 的回调（可多次注册；`onLog` 先于 sink 执行）
    /// - Returns: 该去向的标识，用于 `removeSink` 移除
    ///
    /// - Note: 回调在调用日志方法的线程同步执行，请避免在其中做重活；
    ///   回调里再调用 LogKit 写日志不会死锁（内部先复制列表、放锁后再回调）。
    ///
    /// - Example:
    ///   ```swift
    ///   let id = LogKit.addSink { entry in
    ///       guard entry.level >= .error else { return }
    ///       uploadToServer(entry.jsonObject)
    ///   }
    ///   LogKit.removeSink(id)   // 不再需要时移除
    ///   ```
    @discardableResult
    public static func addSink(_ sink: @escaping (LogEntry) -> Void) -> UUID {
        let id = UUID()
        sinkLock.lock()
        sinks[id] = sink
        sinkLock.unlock()
        return id
    }

    /// 移除一个自定义输出去向
    ///
    /// - Parameter id: `addSink` 返回的标识
    /// - Returns: `true` 表示移除了该去向；`false` 表示该标识不存在（已移除过）
    @discardableResult
    public static func removeSink(_ id: UUID) -> Bool {
        sinkLock.lock()
        defer { sinkLock.unlock() }
        return sinks.removeValue(forKey: id) != nil
    }

    /// 移除全部自定义输出去向
    public static func removeAllSinks() {
        sinkLock.lock()
        defer { sinkLock.unlock() }
        sinks.removeAll()
    }

    /// 当前已注册的自定义输出去向数量
    public static var sinkCount: Int {
        sinkLock.lock()
        defer { sinkLock.unlock() }
        return sinks.count
    }

    private static let sinkLock = NSLock()
    private static var sinks: [UUID: (LogEntry) -> Void] = [:]

    /// 内部：把日志条目分发给全部自定义输出去向（先复制、放锁后再调用，避免回调里写日志造成死锁）
    private static func dispatchToSinks(_ entry: LogEntry) {
        sinkLock.lock()
        let current = Array(sinks.values)
        sinkLock.unlock()
        for sink in current {
            sink(entry)
        }
    }

    // MARK: - 采样输出

    /// 全局默认采样率（`0.0` ~ `1.0`，默认 `0.1`）
    ///
    /// 供 `sampled` 在未显式传 `rate` 时使用。采样率表示每条采样日志被输出的概率：
    /// `1.0` 全部输出、`0.1` 约 10%、`0.0` 全部丢弃。
    public static var samplingRate: Double = 0.1

    /// 采样日志：以给定概率随机决定是否输出
    ///
    /// 用于高频日志降噪——只希望按比例保留日志时（如每 100 条保留约 10 条），
    /// 用随机采样替代 `throttled` 的按时间限流。被丢弃时消息不会求值（惰性）。
    ///
    /// - Parameters:
    ///   - message: 日志内容（惰性求值，被丢弃时不会执行）
    ///   - rate: 采样率（`0.0` ~ `1.0`）；`nil` 时用全局 `samplingRate`
    ///   - level: 日志级别，默认 `.debug`
    ///   - category: 分类名，默认「通用」
    ///   - fields: 附加的扩展字段（键值对）
    ///
    /// - Example:
    ///   ```swift
    ///   // 每条约 10% 概率输出
    ///   LogKit.sampled("高频事件 \(index)", rate: 0.1)
    ///   ```
    public static func sampled(_ message: @autoclosure () -> Any,
                               rate: Double? = nil,
                               level: LogLevel = .debug,
                               category: String = "通用",
                               fields: [String: Any] = [:],
                               file: String = #file, line: Int = #line) {
        let r = min(1, max(0, rate ?? samplingRate))
        guard r > 0, Double.random(in: 0..<1) < r else { return }
        log(level, message, category: category, fields: fields, file: file, line: line)
    }

    // MARK: - 计时测量

    /// 测量一段同步代码的耗时，执行后自动输出一条耗时日志
    ///
    /// 返回代码块的结果（`@discardableResult`，可忽略）。
    /// 代码块抛出错误时，仍会输出「失败 · 耗时」日志，然后把错误原样抛出（`rethrows`）。
    ///
    /// - Parameters:
    ///   - message: 计时标签（会拼进日志，如「解析数据」）
    ///   - level: 日志级别，默认 `.debug`
    ///   - traceId: 追踪 ID（可选，默认用全局 `LogKit.traceId`）
    ///   - category: 分类名，默认「通用」
    ///   - fields: 附加到这条耗时日志的扩展字段
    ///   - file: 调用处文件名（默认自动填充）
    ///   - line: 调用处行号（默认自动填充）
    ///   - block: 要计时的代码块
    ///
    /// - Example:
    ///   ```swift
    ///   let result = LogKit.measure("解析数据") {
    ///       try parser.parse(data)   // → [时间] [调试] [通用] 解析数据 耗时 12.3 ms @ 文件:行
    ///   }
    ///   ```
    @discardableResult
    public static func measure<T>(_ message: String,
                                  level: LogLevel = .debug,
                                  traceId: String? = nil,
                                  category: String = "通用",
                                  fields: [String: Any] = [:],
                                  file: String = #file, line: Int = #line,
                                  _ block: () throws -> T) rethrows -> T {
        let start = Date()
        do {
            let result = try block()
            log(level, { "\(message) 耗时 \(formatDuration(Date().timeIntervalSince(start)))" },
                traceId: traceId, category: category, fields: fields, file: file, line: line)
            return result
        } catch {
            log(level, { "\(message) 失败 · 耗时 \(formatDuration(Date().timeIntervalSince(start)))" },
                traceId: traceId, category: category, fields: fields, file: file, line: line)
            throw error
        }
    }

    /// 测量一段异步代码的耗时（`async` 版本）
    ///
    /// 与 `measure` 相同，只是代码块为 `async throws`，适合网络请求、异步解析等场景。
    ///
    /// - Example:
    ///   ```swift
    ///   let data = try await LogKit.measureAsync("拉取用户信息") {
    ///       try await api.fetchUser(id)
    ///   }
    ///   ```
    @discardableResult
    public static func measureAsync<T>(_ message: String,
                                       level: LogLevel = .debug,
                                       traceId: String? = nil,
                                       category: String = "通用",
                                       fields: [String: Any] = [:],
                                       file: String = #file, line: Int = #line,
                                       _ block: () async throws -> T) async rethrows -> T {
        let start = Date()
        do {
            let result = try await block()
            log(level, { "\(message) 耗时 \(formatDuration(Date().timeIntervalSince(start)))" },
                traceId: traceId, category: category, fields: fields, file: file, line: line)
            return result
        } catch {
            log(level, { "\(message) 失败 · 耗时 \(formatDuration(Date().timeIntervalSince(start)))" },
                traceId: traceId, category: category, fields: fields, file: file, line: line)
            throw error
        }
    }

    // MARK: - 级别计数统计

    /// 查询某个级别累计输出的日志条数（只统计通过过滤、真正输出的日志）
    ///
    /// - Parameter level: 日志级别
    /// - Returns: 该级别累计输出的条数
    ///
    /// - Example:
    ///   ```swift
    ///   LogKit.error("请求失败")
    ///   LogKit.error("重试也失败")
    ///   print(LogKit.totalCount(by: .error))   // 2
    ///   ```
    public static func totalCount(by level: LogLevel) -> Int {
        countLock.lock()
        defer { countLock.unlock() }
        return levelCounts[level] ?? 0
    }

    /// 所有级别累计输出的日志总数
    public static func totalCount() -> Int {
        countLock.lock()
        defer { countLock.unlock() }
        return levelCounts.values.reduce(0, +)
    }

    /// 清零各级别计数
    public static func resetCounts() {
        countLock.lock()
        defer { countLock.unlock() }
        levelCounts.removeAll()
    }

    private static let countLock = NSLock()
    private static var levelCounts: [LogLevel: Int] = [:]

    /// 内部：某级别计数 +1（`log` 通过过滤后调用）
    private static func incrementCount(level: LogLevel) {
        countLock.lock()
        defer { countLock.unlock() }
        levelCounts[level, default: 0] += 1
    }

    // MARK: - 敏感信息脱敏

    /// 对字段字典按敏感关键词脱敏（供外部单独使用）
    ///
    /// 键名命中 `sensitiveFieldKeywords` 的值会被替换为 `***`，其余原样保留。
    /// 若 `redactSensitiveData` 关闭则原样返回。
    ///
    /// - Parameter fields: 原始字段
    /// - Returns: 脱敏后的字段
    public static func redact(_ fields: [String: Any]) -> [String: Any] {
        redactedFields(fields)
    }

    /// 内部：按配置对字段脱敏
    private static func redactedFields(_ fields: [String: Any]) -> [String: Any] {
        guard redactSensitiveData, !fields.isEmpty else { return fields }
        var result = fields
        for key in fields.keys {
            if isSensitiveKey(key) {
                result[key] = "***"
            }
        }
        return result
    }

    /// 判断字段名是否命中敏感关键词（不区分大小写、包含即命中）
    private static func isSensitiveKey(_ key: String) -> Bool {
        let lowered = key.lowercased()
        return sensitiveFieldKeywords.contains { lowered.contains($0) }
    }

    // MARK: - 控制台彩色（内部）

    /// 给控制台文本套上级别对应的 ANSI 颜色
    private static func colored(_ text: String, level: LogLevel) -> String {
        "\u{001B}[\(ansiCode(level))m\(text)\u{001B}[0m"
    }

    /// 级别对应的 ANSI 颜色码
    private static func ansiCode(_ level: LogLevel) -> String {
        switch level {
        case .debug: return "90"        // 亮黑（灰）
        case .info: return "36"         // 青
        case .warning: return "33"      // 黄
        case .error: return "31"        // 红
        case .critical: return "41;97"  // 红底白字
        }
    }

    /// 限流记录存储（键 → 上次输出时间）
    private static let throttleLock = NSLock()
    private static var throttleLastEmit: [String: Date] = [:]

    // MARK: - 文件管理

    /// 当前日志文件完整路径
    public static var logFileURL: URL {
        logDirectory.appendingPathComponent(logFileName())
    }

    /// 清空当前日志文件
    public static func clearLog() {
        writeQueue.sync {
            try? FileManager.default.removeItem(at: logFileURL)
        }
    }

    /// 立即轮转当前日志文件
    ///
    /// 把当前日志文件归档（重命名为带时间戳的文件），下一个日志会写入全新的文件。
    /// 一般用于主动切分日志，比如 App 启动时调用一次。
    public static func rotateLogFile() {
        writeQueue.sync {
            fileLock.lock()
            defer { fileLock.unlock() }
            if FileManager.default.fileExists(atPath: logFileURL.path) {
                archiveCurrentFile(logFileURL)
            }
            cleanupOldFiles()
        }
    }

    /// 等待所有待写入的日志落盘
    ///
    /// 异步写入开启时，日志会先进入后台队列；调用本方法会阻塞直到队列排空，
    /// 一般用于 App 即将进入后台 / 退出前，确保日志不丢失。
    public static func flush() {
        writeQueue.sync {}
    }

    // MARK: - 日志检索

    /// 检索某个日志文件中包含关键字的行
    ///
    /// - Parameters:
    ///   - keyword: 关键字；传空字符串返回全部行
    ///   - fileURL: 日志文件路径；默认当前日志文件
    ///   - limit: 最多返回的行数，`0` 表示不限（默认 `0`；非零时取匹配到的最后 `limit` 行）
    /// - Returns: 匹配的日志行（含原始时间戳与级别）
    public static func search(containing keyword: String,
                              in fileURL: URL? = nil,
                              limit: Int = 0) -> [String] {
        let url = fileURL ?? logFileURL
        guard let content = try? String(contentsOf: url, encoding: .utf8) else { return [] }
        var lines = content.components(separatedBy: .newlines).filter { !$0.isEmpty }
        if !keyword.isEmpty {
            lines = lines.filter { $0.contains(keyword) }
        }
        if limit > 0, lines.count > limit {
            lines = Array(lines.suffix(limit))
        }
        return lines
    }

    /// 检索日志目录下所有 `LogKit-*.log` 文件中包含关键字的行
    ///
    /// 按文件名升序遍历（当前日志文件在后），行内不额外标注来源文件。
    ///
    /// - Parameters:
    ///   - keyword: 关键字；传空字符串返回全部行
    ///   - limit: 最多返回的行数，`0` 表示不限（默认 `0`）
    /// - Returns: 匹配的日志行
    public static func searchAllFiles(containing keyword: String, limit: Int = 0) -> [String] {
        let fm = FileManager.default
        guard let files = try? fm.contentsOfDirectory(at: logDirectory,
                                                      includingPropertiesForKeys: nil,
                                                      options: []) else { return [] }
        let logs = files
            .filter { $0.pathExtension == "log" && $0.lastPathComponent.hasPrefix("LogKit-") }
            .sorted { $0.lastPathComponent < $1.lastPathComponent }
        var results: [String] = []
        for url in logs {
            results.append(contentsOf: search(containing: keyword, in: url))
        }
        if limit > 0, results.count > limit {
            results = Array(results.suffix(limit))
        }
        return results
    }

    // MARK: - 导出与崩溃兜底

    /// 导出当前日志文件，返回可供系统分享面板使用的文件 URL
    ///
    /// 把当前日志文件复制到临时目录，返回一个独立副本的路径，可直接交给
    /// `UIActivityViewController`（iOS）或 `NSSharingServicePicker`（macOS）分享。
    /// 会先 `flush()` 确保未落盘的日志已写入。
    ///
    /// - Returns: 导出副本的文件 URL
    /// - Throws: `LogKitError.logFileNotFound`（当前日志文件不存在时）
    ///
    /// - Example:
    ///   ```swift
    ///   let url = try LogKit.exportLogs()
    ///   // 交给系统分享面板分享该 url
    ///   ```
    public static func exportLogs() throws -> URL {
        flush()
        let fm = FileManager.default
        guard fm.fileExists(atPath: logFileURL.path) else {
            throw LogKitError.logFileNotFound
        }
        let dir = fm.temporaryDirectory.appendingPathComponent("LogKitExport", isDirectory: true)
        try fm.createDirectory(at: dir, withIntermediateDirectories: true)
        // 时间戳只有毫秒精度，同一毫秒内多次导出会撞名导致 copy 失败，加短 UUID 保证唯一
        let dest = dir.appendingPathComponent("LogKit-\(archiveStamp())-\(UUID().uuidString.prefix(8)).log")
        try fm.copyItem(at: logFileURL, to: dest)
        return dest
    }

    // MARK: - CSV 导出

    /// CSV 固定列（字段名与 JSON 输出一致，方便两种格式互通）
    static let csvFixedColumns = ["time", "level", "levelValue", "category", "message", "file", "line", "traceId"]

    /// 把日志条目转成 CSV 文本
    ///
    /// 列为「固定列 + 全部条目 `fields` 键的并集」（并集按字典序追加在末尾，即字段展开：
    /// 每条日志自己的扩展字段都有独立的一列）。含逗号 / 引号 / 换行的值会按 CSV 规范
    /// 用双引号包裹并转义，可直接被 Excel / Numbers 打开。
    ///
    /// - Parameters:
    ///   - entries: 日志条目数组（可从 `onLog` 回调或 `addSink` 收集）
    ///   - includeHeader: 是否输出表头行，默认 `true`
    /// - Returns: CSV 文本；空数组时只返回表头
    ///
    /// - Example:
    ///   ```swift
    ///   var collected: [LogEntry] = []
    ///   LogKit.onLog = { collected.append($0) }
    ///   LogKit.info("下单成功", fields: ["订单号": "A100", "金额": 99])
    ///   print(LogKit.csvString(from: collected))
    ///   ```
    public static func csvString(from entries: [LogEntry], includeHeader: Bool = true) -> String {
        var fieldKeys: Set<String> = []
        for entry in entries {
            fieldKeys.formUnion(entry.fields.keys)
        }
        let extraColumns = fieldKeys.sorted()
        let columns = csvFixedColumns + extraColumns

        var rows: [String] = []
        if includeHeader {
            rows.append(columns.map(csvField).joined(separator: ","))
        }
        for entry in entries {
            var values: [String] = [
                entry.timestamp,
                entry.level.chineseName,
                String(entry.level.rawValue),
                entry.category,
                entry.message,
                entry.file ?? "",
                entry.line.map(String.init) ?? "",
                entry.traceId ?? ""
            ]
            for key in extraColumns {
                values.append(entry.fields[key].map { String(describing: $0) } ?? "")
            }
            rows.append(values.map(csvField).joined(separator: ","))
        }
        return rows.joined(separator: "\n")
    }

    /// 把日志条目导出为 CSV 文件，返回可供系统分享面板使用的文件 URL
    ///
    /// 内容与 `csvString(from:includeHeader:)` 一致，并在开头写入 UTF-8 BOM，
    /// 保证 Excel 打开中文不乱码。文件写入临时目录，可直接交给
    /// `UIActivityViewController`（iOS）或 `NSSharingServicePicker`（macOS）分享。
    ///
    /// - Parameters:
    ///   - entries: 日志条目数组
    ///   - fileName: 目标文件名（不含扩展名）；默认 `LogKit-时间戳-短UUID`
    /// - Returns: 导出的 CSV 文件 URL
    /// - Throws: 创建目录或写文件失败时抛出
    ///
    /// - Example:
    ///   ```swift
    ///   let url = try LogKit.exportCSV(collected)
    ///   ```
    public static func exportCSV(_ entries: [LogEntry], fileName: String? = nil) throws -> URL {
        flush()
        let fm = FileManager.default
        let dir = fm.temporaryDirectory.appendingPathComponent("LogKitExport", isDirectory: true)
        try fm.createDirectory(at: dir, withIntermediateDirectories: true)
        // 时间戳只到毫秒，同一毫秒内多次导出会撞名，加短 UUID 保证唯一
        let name = fileName ?? "LogKit-\(archiveStamp())-\(UUID().uuidString.prefix(8))"
        let dest = dir.appendingPathComponent("\(name).csv")
        // 前置 UTF-8 BOM：Excel 靠它识别编码，否则中文会乱码
        try ("\u{FEFF}" + csvString(from: entries) + "\n").write(to: dest, atomically: true, encoding: .utf8)
        return dest
    }

    /// 内部：按 CSV 规范转义单个字段（含逗号 / 引号 / 换行时用双引号包裹，内部引号翻倍）
    private static func csvField(_ value: String) -> String {
        let needsQuote = value.contains(",") || value.contains("\"")
            || value.contains("\n") || value.contains("\r")
        guard needsQuote else { return value }
        return "\"" + value.replacingOccurrences(of: "\"", with: "\"\"") + "\""
    }

    /// 崩溃日志文件路径（安装崩溃兜底后才会写入）
    public static var crashLogFileURL: URL {
        logDirectory.appendingPathComponent("LogKit-crash.log")
    }
    /// 安装崩溃兜底：捕获未捕获异常与常见致命信号，写入崩溃日志文件
    ///
    /// 调用一次即可（重复调用会被忽略）。安装后：
    /// - 未捕获的 `NSException`（含 Swift 运行时抛出的部分异常）会记录到崩溃日志；
    /// - `SIGABRT` / `SIGSEGV` / `SIGBUS` / `SIGFPE` / `SIGILL` 等致命信号会做最小化落盘。
    ///
    /// - Note: 信号处理是「尽力而为」的兜底，无法保证 100% 捕获所有崩溃；
    ///   建议在 App 启动早期调用，崩溃日志路径见 `crashLogFileURL`。
    public static func installCrashHandler() {
        guard !crashHandlerInstalled else { return }
        crashHandlerInstalled = true

        try? FileManager.default.createDirectory(at: logDirectory, withIntermediateDirectories: true)
        let crashURL = crashLogFileURL
        logKitCrashFilePath = crashURL.path
        logKitCrashPathBuffer = Array(crashURL.path.utf8CString)

        // 1) 未捕获的 NSException（正常上下文，可安全用 Foundation）
        NSSetUncaughtExceptionHandler(logKitExceptionHandler)

        // 2) 致命信号（异步信号安全的最小写入）
        _ = signal(SIGABRT, logKitCrashSignalHandler)
        _ = signal(SIGSEGV, logKitCrashSignalHandler)
        _ = signal(SIGBUS, logKitCrashSignalHandler)
        _ = signal(SIGFPE, logKitCrashSignalHandler)
        _ = signal(SIGILL, logKitCrashSignalHandler)
    }

    private static var crashHandlerInstalled = false

    // MARK: - 尾部读取与归档列表

    /// 读取当前日志文件末尾的若干行（最新的在末尾）
    ///
    /// 先 `flush` 确保异步写入的日志已落盘，再读取当前日志文件并返回最后 `count` 行。
    /// 用于「最近发生了什么」式排查。
    ///
    /// - Parameter count: 返回的最大行数，默认 `50`；传 `0` 或负数返回空数组
    /// - Returns: 末尾若干行（保持文件顺序）；文件不存在或为空时返回空数组
    public static func tail(_ count: Int = 50) -> [String] {
        guard count > 0 else { return [] }
        flush()
        guard let content = try? String(contentsOf: logFileURL, encoding: .utf8), !content.isEmpty else { return [] }
        let trimmed = content.hasSuffix("\n") ? String(content.dropLast()) : content
        let lines = trimmed.isEmpty ? [] : trimmed.split(separator: "\n", omittingEmptySubsequences: false).map(String.init)
        return Array(lines.suffix(count))
    }

    /// 已归档的日志文件列表（不含当前日志文件）
    ///
    /// 文件按修改时间从新到旧排序。当未发生过轮转（`rotateLogFile` 或按大小自动轮转）时为空。
    public static var archivedLogFiles: [URL] {
        let fm = FileManager.default
        guard let files = try? fm.contentsOfDirectory(at: logDirectory,
                                                      includingPropertiesForKeys: [.contentModificationDateKey],
                                                      options: []) else { return [] }
        let current = logFileURL.lastPathComponent
        return files
            .filter { $0.pathExtension == "log" && $0.lastPathComponent.hasPrefix("LogKit-") && $0.lastPathComponent != current }
            .sorted { (a: URL, b: URL) -> Bool in
                let ta = (try? a.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? .distantPast
                let tb = (try? b.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? .distantPast
                return ta > tb
            }
    }

    // MARK: - 内存检索与统计摘要

    /// 内存里保留的最近日志条目（从旧到新）
    ///
    /// 只有把 `maxRecentEntries` 设为正数后才有内容。返回的是快照副本，改动它不影响内部缓存。
    ///
    /// - Example:
    ///   ```swift
    ///   LogKit.maxRecentEntries = 200
    ///   // …运行一段时间…
    ///   for entry in LogKit.recentEntries { print(entry.message) }
    ///   ```
    public static var recentEntries: [LogEntry] {
        recentLock.lock()
        defer { recentLock.unlock() }
        return recentBuffer
    }

    /// 清空内存中保留的日志条目
    public static func clearRecentEntries() {
        recentLock.lock()
        defer { recentLock.unlock() }
        recentBuffer.removeAll()
    }

    /// 按条件过滤一批日志条目
    ///
    /// 适合过滤自己用 `onLog` / `addSink` 收集到的条目。
    ///
    /// - Parameters:
    ///   - entries: 待过滤的日志条目
    ///   - filter: 过滤条件（`LogFilter`）
    /// - Returns: 满足条件的条目（保持原顺序）
    ///
    /// - Example:
    ///   ```swift
    ///   let errors = LogKit.filterEntries(collected, matching: LogFilter(levels: [.error, .critical]))
    ///   ```
    public static func filterEntries(_ entries: [LogEntry], matching filter: LogFilter) -> [LogEntry] {
        filter.filter(entries)
    }

    /// 按条件过滤内存中保留的最近日志（需先设置 `maxRecentEntries`）
    ///
    /// - Parameter filter: 过滤条件（`LogFilter`）
    /// - Returns: 满足条件的条目（从旧到新）
    ///
    /// - Example:
    ///   ```swift
    ///   let 近期错误 = LogKit.filteredRecentEntries(matching: LogFilter(levels: [.error, .critical], keyword: "超时"))
    ///   ```
    public static func filteredRecentEntries(matching filter: LogFilter) -> [LogEntry] {
        filter.filter(recentEntries)
    }

    /// 汇总一批日志条目的统计信息
    ///
    /// - Parameters:
    ///   - entries: 日志条目数组
    ///   - topCategories: 分类排行最多保留几项，默认 `5`
    /// - Returns: `LogSummary` 统计摘要
    ///
    /// - Example:
    ///   ```swift
    ///   let 摘要 = LogKit.summary(of: collected)
    ///   print(摘要.text())     // 一段可直接展示的中文摘要
    ///   ```
    public static func summary(of entries: [LogEntry], topCategories: Int = 5) -> LogSummary {
        LogSummary(entries: entries, topCategories: topCategories)
    }

    /// 汇总内存中保留的最近日志（需先设置 `maxRecentEntries`）
    ///
    /// - Parameter topCategories: 分类排行最多保留几项，默认 `5`
    /// - Returns: `LogSummary` 统计摘要
    public static func summaryOfRecentEntries(topCategories: Int = 5) -> LogSummary {
        LogSummary(entries: recentEntries, topCategories: topCategories)
    }

    private static let recentLock = NSLock()
    private static var recentBuffer: [LogEntry] = []

    /// 内部：把条目追加进内存缓存，超出 `maxRecentEntries` 时丢弃最旧的
    private static func appendRecent(_ entry: LogEntry) {
        guard maxRecentEntries > 0 else { return }
        recentLock.lock()
        defer { recentLock.unlock() }
        recentBuffer.append(entry)
        if recentBuffer.count > maxRecentEntries {
            recentBuffer.removeFirst(recentBuffer.count - maxRecentEntries)
        }
    }

    // MARK: - 压缩归档导出

    /// 把日志文件打包成 zip，返回可供系统分享面板使用的文件 URL
    ///
    /// 打包内容：当前日志文件 + 崩溃日志（若存在）+ 已归档的日志文件（`includeArchived` 为 `true` 时）。
    /// 用纯 Foundation 实现的标准 ZIP（存储方式，不压缩），macOS 访达 / Windows 资源管理器 /
    /// `unzip` 都能直接打开。先 `flush()` 确保未落盘的日志已写入。
    ///
    /// - Parameters:
    ///   - includeArchived: 是否连历史归档文件一起打包，默认 `true`
    ///   - fileName: 压缩包文件名（不含扩展名）；默认 `LogKit-时间戳-短UUID`
    /// - Returns: 压缩包的 URL（位于临时目录）
    /// - Throws: `LogKitError.logFileNotFound`（一个日志文件都没有时）；写文件失败时抛出
    ///
    /// - Example:
    ///   ```swift
    ///   let zip = try LogKit.exportArchive()
    ///   // 交给系统分享面板分享该 zip
    ///   ```
    public static func exportArchive(includeArchived: Bool = true, fileName: String? = nil) throws -> URL {
        flush()
        let fm = FileManager.default

        var sources: [URL] = []
        if fm.fileExists(atPath: logFileURL.path) { sources.append(logFileURL) }
        if fm.fileExists(atPath: crashLogFileURL.path) { sources.append(crashLogFileURL) }
        if includeArchived { sources.append(contentsOf: archivedLogFiles) }
        guard !sources.isEmpty else { throw LogKitError.logFileNotFound }

        let entries: [ZipWriter.Entry] = sources.compactMap { url in
            guard let data = try? Data(contentsOf: url) else { return nil }
            let date = (try? url.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate
                ?? Date()
            return ZipWriter.Entry(name: url.lastPathComponent, data: data, modificationDate: date)
        }
        guard !entries.isEmpty else { throw LogKitError.logFileNotFound }

        let dir = fm.temporaryDirectory.appendingPathComponent("LogKitExport", isDirectory: true)
        try fm.createDirectory(at: dir, withIntermediateDirectories: true)
        let name = fileName ?? "LogKit-\(archiveStamp())-\(UUID().uuidString.prefix(8))"
        let dest = dir.appendingPathComponent("\(name).zip")
        try ZipWriter.archive(entries).write(to: dest)
        return dest
    }

    // MARK: - 输出预判与作用域追踪 ID

    /// 预判某条日志是否会被输出
    ///
    /// 当你想在「构造昂贵消息」之前先判断这条日志会不会被写出来时使用（级别 / 分类过滤）。
    /// 与内部输出入口使用同一套过滤规则，结果一致。
    ///
    /// - Parameters:
    ///   - level: 日志级别
    ///   - category: 分类名，默认「通用」
    /// - Returns: `true` 表示该日志会被输出
    ///
    /// - Example:
    ///   ```swift
    ///   if LogKit.isEnabled(level: .debug, category: "网络") {
    ///       LogKit.debug("响应体：\(try await fetchBody())")   // 仅在会输出时才拉取
    ///   }
    ///   ```
    public static func isEnabled(level: LogLevel, category: String = "通用") -> Bool {
        guard level >= minimumLevel else { return false }
        if let enabled = enabledCategories, !enabled.contains(category) { return false }
        if ignoredCategories.contains(category) { return false }
        return true
    }

    /// 在指定追踪 ID 作用域内执行代码块，结束后恢复原 `traceId`
    ///
    /// 适合「一次请求」的边界：进入时设置 `traceId`，块内所有日志自动携带，
    /// 退出时自动还原（含抛错路径）。
    ///
    /// - Parameters:
    ///   - traceId: 该作用域使用的追踪 ID
    ///   - operation: 要执行的代码块
    /// - Returns: 代码块的返回值
    ///
    /// - Example:
    ///   ```swift
    ///   let user = try LogKit.withTrace("req-42") {
    ///       LogKit.info("开始拉取用户")   // 自动带 traceId: req-42
    ///       return try api.fetchUser()
    ///   }
    ///   ```
    @discardableResult
    public static func withTrace<T>(_ traceId: String, _ operation: () throws -> T) rethrows -> T {
        let previous = Self.traceId
        Self.traceId = traceId
        defer { Self.traceId = previous }
        return try operation()
    }

    /// 异步版的「作用域追踪 ID」，用法同 `withTrace`
    ///
    /// - Parameters:
    ///   - traceId: 该作用域使用的追踪 ID
    ///   - operation: 要执行的异步代码块
    /// - Returns: 代码块的返回值
    @discardableResult
    public static func withTraceAsync<T>(_ traceId: String, _ operation: () async throws -> T) async rethrows -> T {
        let previous = Self.traceId
        Self.traceId = traceId
        defer { Self.traceId = previous }
        return try await operation()
    }

    // MARK: - 内部实现

    /// 内部统一输出入口：`message` 为普通闭包（非 `@autoclosure`），供各输出方法转发其 `@autoclosure` 参数，
    /// 保证先过滤、后求值。
    static func log(_ level: LogLevel, _ message: () -> Any,
                    traceId: String? = nil,
                    category: String, fields: [String: Any], file: String, line: Int) {
        guard isEnabled(level: level, category: category) else { return }
        let effectiveTraceId = traceId ?? Self.traceId
        incrementCount(level: level)
        let safeFields = redactedFields(fields)
        let messageValue = message()
        // 只有确有接收方（回调 / 自定义去向 / 内存检索）时才组装 LogEntry，避免每次都多一次字符串化
        let hasSinks = sinkCount > 0
        let keepsRecent = maxRecentEntries > 0
        if onLog != nil || hasSinks || keepsRecent {
            let entry = LogEntry(timestamp: timestamp(),
                                 level: level,
                                 category: category,
                                 message: String(describing: messageValue),
                                 file: showLocation ? fileName(file) : nil,
                                 line: showLocation ? line : nil,
                                 fields: safeFields,
                                 traceId: effectiveTraceId)
            if keepsRecent { appendRecent(entry) }
            onLog?(entry)
            if hasSinks { dispatchToSinks(entry) }
        }
        let text = formatLine(level: level, message: messageValue, traceId: effectiveTraceId,
                              category: category, file: file, line: line, fields: safeFields)
        if consoleOutput {
            let shouldColor = coloredConsoleOutput && customFormatter == nil && outputFormat == .text
            print(shouldColor ? colored(text, level: level) : text)
        }
        if fileOutput { enqueueWrite(level: level, text) }
    }

    private static func formatLine(level: LogLevel, message: Any, traceId: String?,
                                   category: String, file: String, line: Int,
                                   fields: [String: Any]) -> String {
        if let custom = customFormatter {
            return custom(LogEntry(timestamp: timestamp(),
                                   level: level,
                                   category: category,
                                   message: String(describing: message),
                                   file: showLocation ? fileName(file) : nil,
                                   line: showLocation ? line : nil,
                                   fields: fields,
                                   traceId: traceId))
        }
        switch outputFormat {
        case .text:
            return formatText(level: level, message: message, traceId: traceId, category: category, file: file, line: line, fields: fields)
        case .json:
            return formatJSON(level: level, message: message, traceId: traceId, category: category, file: file, line: line, fields: fields)
        }
    }

    private static func formatText(level: LogLevel, message: Any, traceId: String?,
                                   category: String, file: String, line: Int,
                                   fields: [String: Any]) -> String {
        var base = "[\(timestamp())] [\(level.chineseName)] [\(category)] \(String(describing: message))"
        if showLocation {
            base += " @ \(fileName(file)):\(line)"
        }
        if let traceId = traceId {
            base += " [traceId: \(traceId)]"
        }
        if !fields.isEmpty {
            let pairs = fields.keys.sorted().map { "\($0)=\(String(describing: fields[$0]!))" }
            base += " [\(pairs.joined(separator: ", "))]"
        }
        return base
    }

    private static func formatJSON(level: LogLevel, message: Any, traceId: String?,
                                   category: String, file: String, line: Int,
                                   fields: [String: Any]) -> String {
        var dict: [String: Any] = [
            "time": timestamp(),
            "level": level.chineseName,
            "levelValue": level.rawValue,
            "category": category,
            "message": String(describing: message)
        ]
        if let traceId = traceId {
            dict["traceId"] = traceId
        }
        if showLocation {
            dict["file"] = fileName(file)
            dict["line"] = line
        }
        if !fields.isEmpty {
            dict["fields"] = fields.mapValues { jsonSafe($0) }
        }
        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: []),
              let json = String(data: data, encoding: .utf8) else {
            // JSON 序列化失败时回退为单行文本，保证日志不丢失
            return formatText(level: level, message: message, traceId: traceId, category: category, file: file, line: line, fields: fields)
        }
        return json
    }

    /// 把任意字段值规整为 JSON 可序列化的值（非基础类型 / 非集合则转字符串），保证 JSON 输出不失败
    private static func jsonSafe(_ value: Any) -> Any {
        switch value {
        case let s as String:
            return s
        case let b as Bool:
            return b
        case let n as NSNumber:
            return n
        case let a as [Any]:
            return a.map { jsonSafe($0) }
        case let d as [String: Any]:
            return d.mapValues { jsonSafe($0) }
        default:
            return String(describing: value)
        }
    }

    /// 把耗时格式化为人类可读的字符串（毫秒 / 秒）
    private static func formatDuration(_ interval: TimeInterval) -> String {
        if interval < 1 {
            return String(format: "%.1f ms", interval * 1000)
        }
        return String(format: "%.2f s", interval)
    }

    private static func fileName(_ path: String) -> String {
        (path as NSString).lastPathComponent
    }

    private static let lock = NSLock()
    private static let formatter = DateFormatter()

    private static func timestamp() -> String {
        lock.lock()
        defer { lock.unlock() }
        formatter.dateFormat = dateFormat
        formatter.timeZone = timeZone
        return formatter.string(from: Date())
    }

    private static func logFileName() -> String {
        "LogKit-\(dayStamp()).log"
    }

    private static func dayStamp() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = timeZone
        return f.string(from: Date())
    }

    private static let fileLock = NSLock()

    /// 文件写入专用串行队列：异步写入时在此队列落盘，保证顺序且不阻塞调用线程
    private static let writeQueue = DispatchQueue(label: "com.LogKit.write")

    /// 将日志入队写文件；严重日志始终同步落盘，避免进程崩溃时丢失
    private static func enqueueWrite(level: LogLevel, _ text: String) {
        if level == .critical || !asyncWrite {
            writeQueue.sync { writeToFile(text) }
        } else {
            writeQueue.async { writeToFile(text) }
        }
    }

    private static func writeToFile(_ text: String) {
        fileLock.lock()
        defer { fileLock.unlock() }
        let fm = FileManager.default
        do {
            try fm.createDirectory(at: logDirectory, withIntermediateDirectories: true)
            if dailyRotation { archivePreviousDayFiles() }
            let url = logFileURL
            // 大小轮转：当前文件达到上限时先归档
            if maxFileSize > 0, fm.fileExists(atPath: url.path),
               let attrs = try? fm.attributesOfItem(atPath: url.path),
               let size = (attrs[.size] as? NSNumber)?.intValue,
               size >= maxFileSize {
                archiveCurrentFile(url)
            }
            if !fm.fileExists(atPath: url.path) {
                try "".write(to: url, atomically: true, encoding: .utf8)
            }
            let handle = try FileHandle(forWritingTo: url)
            defer { try? handle.close() }
            try handle.seekToEnd()
            if let data = (text + "\n").data(using: .utf8) {
                try handle.write(contentsOf: data)
            }
            cleanupOldFiles()
        } catch {
            // 文件写入失败时回退到控制台提示，避免日志库自身崩溃
            print("[LogKit] 日志文件写入失败: \(error)")
        }
    }

    /// 把当前日志文件归档为带时间戳的文件
    private static func archiveCurrentFile(_ url: URL) {
        let base = url.deletingPathExtension().lastPathComponent
        let ext = url.pathExtension
        let archived = logDirectory.appendingPathComponent("\(base)-\(archiveStamp()).\(ext)")
        try? FileManager.default.moveItem(at: url, to: archived)
    }

    /// 按天轮转：把日志目录里「不是今天」的按天日志文件归档掉
    ///
    /// 文件名形如 `LogKit-2026-09-09.log`（`LogKit-` 与 `.log` 之间恰好是 10 个字符的日期、
    /// 含两个短横线），归档后形如 `LogKit-2026-09-09-093000123.log`，不会再被本方法识别，
    /// 因此不会重复归档。崩溃日志（`LogKit-crash.log`）与已归档文件都不匹配该形状，会被跳过。
    private static func archivePreviousDayFiles() {
        let today = dayStamp()
        let fm = FileManager.default
        guard let files = try? fm.contentsOfDirectory(at: logDirectory,
                                                      includingPropertiesForKeys: nil,
                                                      options: []) else { return }
        for url in files where url.pathExtension == "log" {
            let name = url.lastPathComponent
            guard name.hasPrefix("LogKit-") else { continue }
            let body = String(name.dropFirst("LogKit-".count).dropLast(".log".count))
            guard body.count == 10, body.filter({ $0 == "-" }).count == 2 else { continue }
            guard body != today else { continue }
            archiveCurrentFile(url)
        }
    }

    /// 归档文件名的时间戳（毫秒级，避免同秒冲突）
    private static func archiveStamp() -> String {
        archiveFormatter.string(from: Date())
    }

    private static let archiveFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HHmmssSSS"
        return f
    }()

    /// 清理过期 / 超量的日志文件
    ///
    /// 先按 `maxLogAgeDays` 删掉修改时间过旧的文件（当前正在写的文件除外），
    /// 再按 `maxLogFiles` 只保留最新的若干个。两个开关都为 `0`（默认）时不做任何事。
    private static func cleanupOldFiles() {
        guard maxLogFiles > 0 || maxLogAgeDays > 0 else { return }
        let fm = FileManager.default
        guard let files = try? fm.contentsOfDirectory(at: logDirectory,
                                                      includingPropertiesForKeys: [.contentModificationDateKey],
                                                      options: []) else { return }
        let current = logFileURL.lastPathComponent
        let logs: [(url: URL, date: Date)] = files
            .filter { $0.pathExtension == "log" && $0.lastPathComponent.hasPrefix("LogKit-") }
            .map { url in
                let date = (try? url.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate
                    ?? .distantPast
                return (url, date)
            }

        // 1) 按天数清理
        var remaining = logs
        if maxLogAgeDays > 0 {
            let cutoff = Date().addingTimeInterval(-Double(maxLogAgeDays) * 86_400)
            for item in logs where item.url.lastPathComponent != current && item.date < cutoff {
                try? fm.removeItem(at: item.url)
            }
            remaining = logs.filter { $0.url.lastPathComponent == current || $0.date >= cutoff }
        }

        // 2) 按数量清理
        guard maxLogFiles > 0, remaining.count > maxLogFiles else { return }
        let sorted = remaining.sorted { $0.date < $1.date }
        for item in sorted.prefix(remaining.count - maxLogFiles) {
            try? fm.removeItem(at: item.url)
        }
    }
}

/// LogKit 抛出的错误
public enum LogKitError: Error, LocalizedError, Equatable {
    /// 当前日志文件不存在（无法导出）
    case logFileNotFound

    public var errorDescription: String? {
        switch self {
        case .logFileNotFound:
            return "导出日志失败：当前日志文件不存在"
        }
    }
}

// MARK: - 崩溃兜底处理器（文件级，供 C 调用约定的处理器使用）

/// 崩溃日志路径（C 字符串缓冲，供信号处理器用 Darwin `open`/`write` 落盘）
private var logKitCrashPathBuffer: [CChar] = []

/// 崩溃日志路径（字符串形式，供 NSException 处理器在正常上下文用 Foundation 追加）
private var logKitCrashFilePath: String = ""

/// 当前时间戳（自由函数，供 `@convention(c)` 处理器调用，避免捕获类型静态成员）
private func logKitTimestampNow() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = LogKit.dateFormat
    formatter.timeZone = LogKit.timeZone
    return formatter.string(from: Date())
}

/// 向崩溃日志文件追加一行（自由函数，供 NSException 处理器在正常上下文调用）
private func logKitAppendCrashText(_ text: String) {
    guard !logKitCrashFilePath.isEmpty else { return }
    let url = URL(fileURLWithPath: logKitCrashFilePath)
    guard let data = text.data(using: .utf8) else { return }
    if FileManager.default.fileExists(atPath: url.path) {
        if let handle = try? FileHandle(forWritingTo: url) {
            defer { try? handle.close() }
            _ = try? handle.seekToEnd()
            try? handle.write(contentsOf: data)
        }
    } else {
        try? data.write(to: url)
    }
}

/// 未捕获异常处理器：显式 `@convention(c)` 闭包常量，仅引用文件级自由函数与全局量
private let logKitExceptionHandler: @convention(c) (NSException) -> Void = { exception in
    let text = "[\(logKitTimestampNow())] 未捕获异常 \(exception.name.rawValue)：\(exception.reason ?? "无描述")\n"
    logKitAppendCrashText(text)
}

/// 致命信号处理器：显式 `@convention(c)` 闭包常量，仅引用全局量/C 函数
///
/// 注意：不能把 `private func` + 隐式转换传给 `signal`，也不能用普通闭包传
/// `NSSetUncaughtExceptionHandler`——Swift 无法从「捕获上下文的闭包」构造 C 函数指针，
/// 会报 *A C function pointer cannot be formed from a closure that captures context*。
/// 必须用显式的 `@convention(c)` 闭包常量（仅引用全局量、自由函数与 C 函数，不捕获局部变量/类型成员）。
private let logKitCrashSignalHandler: @convention(c) (Int32) -> Void = { sig in
    let name: String
    switch sig {
    case SIGABRT: name = "SIGABRT"
    case SIGSEGV: name = "SIGSEGV"
    case SIGBUS: name = "SIGBUS"
    case SIGFPE: name = "SIGFPE"
    case SIGILL: name = "SIGILL"
    default: name = "SIG\(sig)"
    }
    let line = "CRASH \(sig) \(name)\n"
    let fd = logKitCrashPathBuffer.withUnsafeBufferPointer { buf -> Int32 in
        guard let base = buf.baseAddress else { return -1 }
        return open(base, O_WRONLY | O_CREAT | O_APPEND, 0o644)
    }
    if fd >= 0 {
        line.withCString { _ = write(fd, $0, strlen($0)) }
        close(fd)
    }
}
