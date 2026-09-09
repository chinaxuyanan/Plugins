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
}
