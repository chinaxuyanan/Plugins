import Foundation

// MARK: - 中文命名别名
//
// 为每个英文输出方法提供中文命名的别名，让开发者在输入 `LogKit.` 触发自动补全时，
// 直接在候选列表里看到中文方法名，见名即选。每个中文别名等价转发到对应英文方法。

public extension LogKit {

    /// 调试日志（等同 `debug`）
    /// - Parameters:
    ///   - 消息: 日志内容
    ///   - 分类: 分类名，默认「通用」
    ///   - 字段: 附加的扩展字段（键值对，配合 `.json` 输出）
    ///   - 文件: 调用处文件名（自动填充，一般不用传）
    ///   - 行: 调用处行号（自动填充，一般不用传）
    static func 调试(_ 消息: @autoclosure () -> Any,
                    分类: String = "通用",
                    字段: [String: Any] = [:],
                    文件: String = #file, 行: Int = #line) {
        log(.debug, 消息, category: 分类, fields: 字段, file: 文件, line: 行)
    }

    /// 信息日志（等同 `info`）
    /// - Parameters:
    ///   - 消息: 日志内容
    ///   - 分类: 分类名，默认「通用」
    ///   - 字段: 附加的扩展字段（键值对）
    static func 信息(_ 消息: @autoclosure () -> Any,
                    分类: String = "通用",
                    字段: [String: Any] = [:],
                    文件: String = #file, 行: Int = #line) {
        log(.info, 消息, category: 分类, fields: 字段, file: 文件, line: 行)
    }

    /// 警告日志（等同 `warning`）
    /// - Parameters:
    ///   - 消息: 日志内容
    ///   - 分类: 分类名，默认「通用」
    ///   - 字段: 附加的扩展字段（键值对）
    static func 警告(_ 消息: @autoclosure () -> Any,
                    分类: String = "通用",
                    字段: [String: Any] = [:],
                    文件: String = #file, 行: Int = #line) {
        log(.warning, 消息, category: 分类, fields: 字段, file: 文件, line: 行)
    }

    /// 错误日志（等同 `error`）
    /// - Parameters:
    ///   - 消息: 日志内容
    ///   - 分类: 分类名，默认「通用」
    ///   - 字段: 附加的扩展字段（键值对）
    static func 错误(_ 消息: @autoclosure () -> Any,
                    分类: String = "通用",
                    字段: [String: Any] = [:],
                    文件: String = #file, 行: Int = #line) {
        log(.error, 消息, category: 分类, fields: 字段, file: 文件, line: 行)
    }

    /// 严重日志（等同 `critical`）
    /// - Parameters:
    ///   - 消息: 日志内容
    ///   - 分类: 分类名，默认「通用」
    ///   - 字段: 附加的扩展字段（键值对）
    static func 严重(_ 消息: @autoclosure () -> Any,
                    分类: String = "通用",
                    字段: [String: Any] = [:],
                    文件: String = #file, 行: Int = #line) {
        log(.critical, 消息, category: 分类, fields: 字段, file: 文件, line: 行)
    }

    /// 计时测量（等同 `measure`）
    ///
    /// 执行一段同步代码并输出耗时日志，返回代码块结果。代码块抛错时仍记录耗时，并原样抛出错误。
    ///
    /// - Parameters:
    ///   - 标签: 计时标签（拼进日志，如「解析数据」）
    ///   - 级别: 日志级别，默认 `.debug`
    ///   - 分类: 分类名，默认「通用」
    ///   - 字段: 附加的扩展字段（键值对）
    ///   - 文件: 调用处文件名（自动填充）
    ///   - 行: 调用处行号（自动填充）
    ///   - 代码块: 要计时的代码块
    ///
    /// - Example:
    ///   ```swift
    ///   let 结果 = LogKit.计时("解析数据") { try parser.parse(data) }
    ///   ```
    @discardableResult
    static func 计时<T>(_ 标签: String,
                       级别: LogLevel = .debug,
                       分类: String = "通用",
                       字段: [String: Any] = [:],
                       文件: String = #file, 行: Int = #line,
                       _ 代码块: () throws -> T) rethrows -> T {
        try measure(标签, level: 级别, category: 分类, fields: 字段, file: 文件, line: 行, 代码块)
    }

    /// 异步计时测量（等同 `measureAsync`）
    ///
    /// 与「计时」相同，只是代码块为 `async throws`，适合网络请求、异步解析等场景。
    ///
    /// - Example:
    ///   ```swift
    ///   let 数据 = try await LogKit.异步计时("拉取用户信息") { try await api.fetchUser(id) }
    ///   ```
    @discardableResult
    static func 异步计时<T>(_ 标签: String,
                           级别: LogLevel = .debug,
                           分类: String = "通用",
                           字段: [String: Any] = [:],
                           文件: String = #file, 行: Int = #line,
                           _ 代码块: () async throws -> T) async rethrows -> T {
        try await measureAsync(标签, level: 级别, category: 分类, fields: 字段, file: 文件, line: 行, 代码块)
    }

    /// 清空日志文件（等同 `clearLog`）
    static func 清空日志() { clearLog() }

    /// 立即轮转日志文件（等同 `rotateLogFile`）
    static func 轮转日志() { rotateLogFile() }

    /// 刷新日志缓冲，等待待写入日志落盘（等同 `flush`）
    static func 刷新缓冲() { flush() }

    /// 输出格式（等同 `outputFormat`）
    static var 输出格式: LogOutputFormat {
        get { outputFormat }
        set { outputFormat = newValue }
    }

    /// 是否异步写文件（等同 `asyncWrite`）
    static var 异步写入: Bool {
        get { asyncWrite }
        set { asyncWrite = newValue }
    }

    /// 自定义格式闭包（等同 `customFormatter`）
    static var 自定义格式: ((LogEntry) -> String)? {
        get { customFormatter }
        set { customFormatter = newValue }
    }

    /// 全局追踪 ID（等同 `traceId`）
    static var 追踪ID: String? {
        get { traceId }
        set { traceId = newValue }
    }

    /// 环境自适应的默认最低级别（等同 `adaptiveMinimumLevel`）
    static var 自适应最低级别: LogLevel { adaptiveMinimumLevel }

    /// 查询某级别累计输出条数（等同 `totalCount(by:)`）
    /// - Parameter 级别: 日志级别
    static func 级别计数(_ 级别: LogLevel) -> Int {
        totalCount(by: 级别)
    }

    /// 所有级别累计输出总数（等同 `totalCount()`）
    static func 日志总数() -> Int {
        totalCount()
    }

    /// 清零各级别计数（等同 `resetCounts`）
    static func 重置计数() {
        resetCounts()
    }

    /// 限流日志（等同 `throttled`）
    /// - Parameters:
    ///   - 消息: 日志内容（被限流时不会执行）
    ///   - 级别: 日志级别，默认 `.debug`
    ///   - 间隔: 限流窗口（秒），默认 `1`
    ///   - 键: 自定义去重键（可选）；不传则用「文件:行:级别」
    ///   - 分类: 分类名，默认「通用」
    ///   - 字段: 附加的扩展字段（键值对）
    static func 限流日志(_ 消息: @autoclosure () -> Any,
                        级别: LogLevel = .debug,
                        间隔: TimeInterval = 1,
                        键: String? = nil,
                        分类: String = "通用",
                        字段: [String: Any] = [:],
                        文件: String = #file, 行: Int = #line) {
        // 注意：`throttled` 的参数也是 @autoclosure，转发时须先求值 `消息()`，
        // 否则会把 `() -> Any` 闭包当作值再次自动包裹，导致类型不匹配。
        throttled(消息(), level: 级别, interval: 间隔, key: 键,
                  category: 分类, fields: 字段, file: 文件, line: 行)
    }

    /// 清除限流记录（等同 `resetThrottle`）
    static func 重置限流() {
        resetThrottle()
    }

    /// 字段脱敏（等同 `redact`）
    /// - Parameter 字段: 原始字段
    static func 脱敏(_ 字段: [String: Any]) -> [String: Any] {
        redact(字段)
    }

    /// 是否对敏感字段脱敏（等同 `redactSensitiveData`）
    static var 脱敏敏感字段: Bool {
        get { redactSensitiveData }
        set { redactSensitiveData = newValue }
    }

    /// 敏感字段关键词（等同 `sensitiveFieldKeywords`）
    static var 敏感字段关键词: Set<String> {
        get { sensitiveFieldKeywords }
        set { sensitiveFieldKeywords = newValue }
    }

    /// 是否控制台彩色输出（等同 `coloredConsoleOutput`）
    static var 彩色控制台: Bool {
        get { coloredConsoleOutput }
        set { coloredConsoleOutput = newValue }
    }

    /// 检索日志（等同 `search`）
    /// - Parameters:
    ///   - 关键字: 关键字；传空字符串返回全部行
    ///   - 文件: 日志文件路径；默认当前日志文件
    ///   - 上限: 最多返回的行数，`0` 表示不限
    static func 检索日志(_ 关键字: String, 文件: URL? = nil, 上限: Int = 0) -> [String] {
        search(containing: 关键字, in: 文件, limit: 上限)
    }

    /// 检索全部日志文件（等同 `searchAllFiles`）
    /// - Parameters:
    ///   - 关键字: 关键字；传空字符串返回全部行
    ///   - 上限: 最多返回的行数，`0` 表示不限
    static func 检索全部日志(_ 关键字: String, 上限: Int = 0) -> [String] {
        searchAllFiles(containing: 关键字, limit: 上限)
    }

    /// 采样日志（等同 `sampled`）
    /// - Parameters:
    ///   - 消息: 日志内容（惰性求值，被丢弃时不会执行）
    ///   - 采样率: 输出概率（`0.0` ~ `1.0`）；`nil` 时用全局 `samplingRate`
    ///   - 级别: 日志级别，默认 `.debug`
    ///   - 分类: 分类名，默认「通用」
    ///   - 字段: 附加的扩展字段（键值对）
    static func 采样日志(_ 消息: @autoclosure () -> Any,
                         采样率: Double? = nil,
                         级别: LogLevel = .debug,
                         分类: String = "通用",
                         字段: [String: Any] = [:],
                         文件: String = #file, 行: Int = #line) {
        sampled(消息(), rate: 采样率, level: 级别, category: 分类, fields: 字段, file: 文件, line: 行)
    }

    /// 全局默认采样率（等同 `samplingRate`）
    static var 采样率: Double {
        get { samplingRate }
        set { samplingRate = newValue }
    }

    /// 导出日志（等同 `exportLogs`）
    /// - Returns: 导出副本的文件 URL
    /// - Throws: `LogKitError.logFileNotFound`（当前日志文件不存在时）
    static func 导出日志() throws -> URL {
        try exportLogs()
    }

    /// 崩溃日志文件路径（等同 `crashLogFileURL`）
    static var 崩溃日志路径: URL {
        crashLogFileURL
    }

    /// 安装崩溃处理（等同 `installCrashHandler`）
    static func 安装崩溃处理() {
        installCrashHandler()
    }

    /// 尾部读取（等同 `tail`）
    /// - Parameter 行数: 返回的最大行数，默认 `50`
    static func 尾部读取(_ 行数: Int = 50) -> [String] {
        tail(行数)
    }

    /// 已归档日志文件列表（等同 `archivedLogFiles`）
    static var 归档日志列表: [URL] {
        archivedLogFiles
    }

    /// 日志回调钩子（等同 `onLog`）
    static var 日志回调: ((LogEntry) -> Void)? {
        get { onLog }
        set { onLog = newValue }
    }

    /// 预判某条日志是否会被输出（等同 `isEnabled(level:category:)`）
    /// - Parameters:
    ///   - 级别: 日志级别
    ///   - 分类: 分类名，默认「通用」
    static func 是否输出(级别: LogLevel, 分类: String = "通用") -> Bool {
        isEnabled(level: 级别, category: 分类)
    }

    /// 在指定追踪 ID 作用域内执行代码块，结束后恢复原 `traceId`（等同 `withTrace`）
    /// - Parameters:
    ///   - 追踪ID: 该作用域使用的追踪 ID
    ///   - 操作: 要执行的代码块
    @discardableResult
    static func 追踪执行<T>(_ 追踪ID: String, _ 操作: () throws -> T) rethrows -> T {
        try withTrace(追踪ID, 操作)
    }

    /// 异步版「作用域追踪 ID」（等同 `withTraceAsync`）
    /// - Parameters:
    ///   - 追踪ID: 该作用域使用的追踪 ID
    ///   - 操作: 要执行的异步代码块
    @discardableResult
    static func 异步追踪执行<T>(_ 追踪ID: String, _ 操作: () async throws -> T) async rethrows -> T {
        try await withTraceAsync(追踪ID, 操作)
    }

    /// 自定义输出去向（等同 `addSink`）
    /// - Parameter 输出: 收到 `LogEntry` 的回调（可多次添加，按添加顺序调用）
    /// - Returns: 该去向的标识，用于 `移除输出`
    @discardableResult
    static func 添加输出(_ 输出: @escaping (LogEntry) -> Void) -> UUID {
        addSink(输出)
    }

    /// 移除自定义输出去向（等同 `removeSink`）
    /// - Parameter 标识: `添加输出` 返回的标识
    /// - Returns: `true` 表示成功移除该去向
    @discardableResult
    static func 移除输出(_ 标识: UUID) -> Bool {
        removeSink(标识)
    }

    /// 移除全部自定义输出去向（等同 `removeAllSinks`）
    static func 清空输出() {
        removeAllSinks()
    }

    /// 当前自定义输出去向数量（等同 `sinkCount`）
    static var 输出数量: Int { sinkCount }

    /// 日志文件最长保留天数（等同 `maxLogAgeDays`）
    static var 日志保留天数: Int {
        get { maxLogAgeDays }
        set { maxLogAgeDays = newValue }
    }

    /// 时间戳使用的时区（等同 `timeZone`）
    static var 时区: TimeZone {
        get { timeZone }
        set { timeZone = newValue }
    }

    /// 日志条目转 CSV 文本（等同 `csvString(from:includeHeader:)`）
    /// - Parameters:
    ///   - 条目: 日志条目数组
    ///   - 含表头: 是否输出表头行，默认 `true`
    static func CSV字符串(条目: [LogEntry], 含表头: Bool = true) -> String {
        csvString(from: 条目, includeHeader: 含表头)
    }

    /// 导出 CSV 文件（等同 `exportCSV`）
    /// - Parameters:
    ///   - 条目: 日志条目数组
    ///   - 文件名: 目标文件名（不含扩展名）
    static func 导出CSV(_ 条目: [LogEntry], 文件名: String? = nil) throws -> URL {
        try exportCSV(条目, fileName: 文件名)
    }
}

// MARK: - LogEntry 中文命名别名

public extension LogEntry {

    /// JSON 字典（等同 `jsonObject`）
    var JSON字典: [String: Any] { jsonObject }

    /// JSON 字符串（等同 `jsonString`）
    var JSON字符串: String { jsonString }
}
