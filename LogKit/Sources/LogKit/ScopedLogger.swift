import Foundation

/// 作用域日志器：绑定默认分类的日志实例
///
/// 大工程里每个模块 / 组件各持一个 `ScopedLogger`，日志自动带上该模块的默认分类，
/// 实例方法 `debug / info / warning / error / critical` 无需每次手动传 `category`，
/// 还能用 `measure` 计时、用 `child` 派生更细的子分类。
///
/// - Example:
///   ```swift
///   let 网络 = ScopedLogger(module: "网络", category: "请求")
///   网络.debug("开始拉取用户信息")
///   网络.warning("请求超时")
///   let 重试 = 网络.child("重试")   // 分类 → 网络.请求.重试
///   ```
///
/// 底层仍走 `LogKit` 的全局配置（`minimumLevel` / 输出格式 / 文件输出 / 自定义格式等），
/// 只是替你补全了分类名。
public final class ScopedLogger {

    /// 所属模块 / 子系统名（可选，如「网络」「存储」）
    public let module: String?

    /// 默认分类名（未指定模块时直接用，指定模块时拼成「模块.分类」）
    public let category: String

    /// 本日志器的追踪 ID（可选）；为空时回退到全局 `LogKit.traceId`
    ///
    /// 与全局 `LogKit.traceId` 是两个层级：本值非空时优先于全局值。
    /// 用于把该模块 / 组件产生的日志串联起来。
    public var traceId: String?

    /// - Parameters:
    ///   - module: 所属模块名（可选），有值时日志分类会变成「模块.分类」
    ///   - category: 分类名，默认「通用」
    ///   - traceId: 本日志器的追踪 ID（可选）
    public init(module: String? = nil, category: String = "通用", traceId: String? = nil) {
        self.module = module
        self.category = category
        self.traceId = traceId
    }

    /// 实际用于输出的分类名
    ///
    /// - 有模块且分类为「通用」时 → 直接用模块名（如「网络」）
    /// - 有模块且分类非通用 → 「模块.分类」（如「网络.请求」）
    /// - 无模块 → 分类名原样
    public var effectiveCategory: String {
        if let module = module, !module.isEmpty {
            return category == "通用" ? module : "\(module).\(category)"
        }
        return category
    }

    // MARK: 日志输出

    /// 调试日志（自动使用本日志器的默认分类）
    /// - Parameters:
    ///   - message: 日志内容（惰性求值）
    ///   - fields: 附加的扩展字段（键值对）
    public func debug(_ message: @autoclosure () -> Any,
                      fields: [String: Any] = [:],
                      file: String = #file, line: Int = #line) {
        LogKit.log(.debug, message, traceId: traceId,
                   category: effectiveCategory, fields: fields, file: file, line: line)
    }

    /// 信息日志（自动使用本日志器的默认分类）
    public func info(_ message: @autoclosure () -> Any,
                     fields: [String: Any] = [:],
                     file: String = #file, line: Int = #line) {
        LogKit.log(.info, message, traceId: traceId,
                   category: effectiveCategory, fields: fields, file: file, line: line)
    }

    /// 警告日志（自动使用本日志器的默认分类）
    public func warning(_ message: @autoclosure () -> Any,
                        fields: [String: Any] = [:],
                        file: String = #file, line: Int = #line) {
        LogKit.log(.warning, message, traceId: traceId,
                   category: effectiveCategory, fields: fields, file: file, line: line)
    }

    /// 错误日志（自动使用本日志器的默认分类）
    public func error(_ message: @autoclosure () -> Any,
                      fields: [String: Any] = [:],
                      file: String = #file, line: Int = #line) {
        LogKit.log(.error, message, traceId: traceId,
                   category: effectiveCategory, fields: fields, file: file, line: line)
    }

    /// 严重日志（自动使用本日志器的默认分类）
    public func critical(_ message: @autoclosure () -> Any,
                         fields: [String: Any] = [:],
                         file: String = #file, line: Int = #line) {
        LogKit.log(.critical, message, traceId: traceId,
                   category: effectiveCategory, fields: fields, file: file, line: line)
    }

    // MARK: 计时测量

    /// 测量一段同步代码的耗时，输出耗时日志（分类自动填为本日志器的默认分类）
    ///
    /// - Parameters:
    ///   - message: 计时标签
    ///   - level: 日志级别，默认 `.debug`
    ///   - fields: 附加的扩展字段
    ///   - block: 要计时的代码块
    @discardableResult
    public func measure<T>(_ message: String,
                           level: LogLevel = .debug,
                           fields: [String: Any] = [:],
                           file: String = #file, line: Int = #line,
                           _ block: () throws -> T) rethrows -> T {
        try LogKit.measure(message, level: level, traceId: traceId, category: effectiveCategory,
                           fields: fields, file: file, line: line, block)
    }

    /// 测量一段异步代码的耗时（`async` 版本）
    @discardableResult
    public func measureAsync<T>(_ message: String,
                                level: LogLevel = .debug,
                                fields: [String: Any] = [:],
                                file: String = #file, line: Int = #line,
                                _ block: () async throws -> T) async rethrows -> T {
        try await LogKit.measureAsync(message, level: level, traceId: traceId, category: effectiveCategory,
                                      fields: fields, file: file, line: line, block)
    }

    // MARK: 派生

    /// 派生子日志器：在当前分类后追加一级子分类
    ///
    /// - Parameter subcategory: 子分类名（如「重试」→ 父分类后追加「.重试」）
    /// - Returns: 新的作用域日志器
    public func child(_ subcategory: String) -> ScopedLogger {
        ScopedLogger(category: "\(effectiveCategory).\(subcategory)", traceId: traceId)
    }
}

// MARK: 中文命名别名

/// 中文名：作用域日志器（等同 `ScopedLogger`）
public typealias 作用域日志器 = ScopedLogger

public extension ScopedLogger {
    /// 作用域日志器（中文参数）
    /// - Parameters:
    ///   - 模块: 所属模块名（可选），有值时日志分类会变成「模块.分类」
    ///   - 分类: 分类名，默认「通用」
    ///   - 追踪ID: 本日志器的追踪 ID（可选）
    convenience init(模块: String?, 分类: String = "通用", 追踪ID: String? = nil) {
        self.init(module: 模块, category: 分类, traceId: 追踪ID)
    }

    /// 实际用于输出的分类名（等同 `effectiveCategory`）
    var 实际分类: String { effectiveCategory }

    /// 本日志器的追踪 ID（等同 `traceId`）
    var 追踪ID: String? {
        get { traceId }
        set { traceId = newValue }
    }

    /// 调试日志（等同 `debug`）
    func 调试(_ 消息: @autoclosure () -> Any, 字段: [String: Any] = [:], 文件: String = #file, 行: Int = #line) {
        LogKit.log(.debug, 消息, traceId: traceId, category: effectiveCategory, fields: 字段, file: 文件, line: 行)
    }

    /// 信息日志（等同 `info`）
    func 信息(_ 消息: @autoclosure () -> Any, 字段: [String: Any] = [:], 文件: String = #file, 行: Int = #line) {
        LogKit.log(.info, 消息, traceId: traceId, category: effectiveCategory, fields: 字段, file: 文件, line: 行)
    }

    /// 警告日志（等同 `warning`）
    func 警告(_ 消息: @autoclosure () -> Any, 字段: [String: Any] = [:], 文件: String = #file, 行: Int = #line) {
        LogKit.log(.warning, 消息, traceId: traceId, category: effectiveCategory, fields: 字段, file: 文件, line: 行)
    }

    /// 错误日志（等同 `error`）
    func 错误(_ 消息: @autoclosure () -> Any, 字段: [String: Any] = [:], 文件: String = #file, 行: Int = #line) {
        LogKit.log(.error, 消息, traceId: traceId, category: effectiveCategory, fields: 字段, file: 文件, line: 行)
    }

    /// 严重日志（等同 `critical`）
    func 严重(_ 消息: @autoclosure () -> Any, 字段: [String: Any] = [:], 文件: String = #file, 行: Int = #line) {
        LogKit.log(.critical, 消息, traceId: traceId, category: effectiveCategory, fields: 字段, file: 文件, line: 行)
    }

    /// 计时测量（等同 `measure`）
    @discardableResult
    func 计时<T>(_ 标签: String,
                级别: LogLevel = .debug,
                字段: [String: Any] = [:],
                文件: String = #file, 行: Int = #line,
                _ 代码块: () throws -> T) rethrows -> T {
        try measure(标签, level: 级别, fields: 字段, file: 文件, line: 行, 代码块)
    }

    /// 异步计时测量（等同 `measureAsync`）
    @discardableResult
    func 异步计时<T>(_ 标签: String,
                    级别: LogLevel = .debug,
                    字段: [String: Any] = [:],
                    文件: String = #file, 行: Int = #line,
                    _ 代码块: () async throws -> T) async rethrows -> T {
        try await measureAsync(标签, level: 级别, fields: 字段, file: 文件, line: 行, 代码块)
    }

    /// 派生子日志器（等同 `child`）
    func 子日志器(_ 子分类: String) -> ScopedLogger {
        child(子分类)
    }
}
