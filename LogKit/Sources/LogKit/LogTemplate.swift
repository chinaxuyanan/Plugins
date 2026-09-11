import Foundation

/// 日志格式模板
///
/// 用一段带占位符的字符串接管日志行的拼装，省得为「只想换个顺序 / 分隔符」去写 `LogKit.customFormatter` 闭包。
/// 占位符用花括号包起来，英文与中文两种写法等价：
///
/// | 占位符 | 取值 |
/// | --- | --- |
/// | `{time}` / `{时间}` | 时间戳（已按 `LogKit.dateFormat` 格式化）|
/// | `{level}` / `{级别}` | 级别中文名（调试 / 信息 / 警告 / 错误 / 严重）|
/// | `{category}` / `{分类}` | 分类名 |
/// | `{message}` / `{消息}` | 消息正文 |
/// | `{file}` / `{文件}` | 调用处文件名（`showLocation` 关闭时为空）|
/// | `{line}` / `{行}` | 调用处行号（`showLocation` 关闭时为空）|
/// | `{traceId}` / `{追踪ID}` | 追踪 ID（未设置时为空）|
/// | `{fields}` / `{字段}` | 扩展字段，形如 `键=值, 键=值`（按键名排序）|
///
/// **写错的占位符会原样保留**（不静默吞掉），配合 `unknownPlaceholders(in:)` 可以在启动时自查。
///
/// - Example:
///   ```swift
///   let 模板 = LogTemplate("{级别} | {分类} | {消息} @ {文件}:{行}")
///   LogKit.customFormatter = 模板.formatter
///   LogKit.info("下单成功", category: "订单")
///   // 信息 | 订单 | 下单成功 @ OrderService.swift:42
///
///   LogTemplate.unknownPlaceholders(in: "{级别} {不存在的}")   // ["不存在的"]
///   ```
public struct LogTemplate {

    /// 模板原文
    public let template: String

    /// 用模板原文创建模板
    /// - Parameter template: 带 `{占位符}` 的模板字符串
    public init(_ template: String) {
        self.template = template
    }

    /// 全部受支持的占位符（英文 / 中文都列出）
    public static let supportedPlaceholders: [String] = [
        "time", "时间",
        "level", "级别",
        "category", "分类",
        "message", "消息",
        "file", "文件",
        "line", "行",
        "traceId", "追踪ID",
        "fields", "字段"
    ]

    private static let supportedSet: Set<String> = Set(supportedPlaceholders)

    // MARK: - 纯逻辑（可单测）

    /// 渲染一条日志
    ///
    /// - 认识的占位符替换成对应值；
    /// - **不认识的占位符原样保留**（含花括号），不会变成空串；
    /// - 只有 `{` 没有配对的 `}` 时，从该 `{` 起原样保留剩余内容。
    ///
    /// - Parameters:
    ///   - template: 模板字符串
    ///   - entry: 要渲染的日志条目
    /// - Returns: 渲染结果
    public static func format(_ template: String, with entry: LogEntry) -> String {
        var result = ""
        var rest = Substring(template)
        while let open = rest.firstIndex(of: "{") {
            result += rest[rest.startIndex..<open]
            let afterOpen = rest.index(after: open)
            guard let close = rest[afterOpen...].firstIndex(of: "}") else {
                result += rest[open...]
                return result
            }
            let name = String(rest[afterOpen..<close]).trimmingCharacters(in: .whitespaces)
            if let value = value(for: name, entry: entry) {
                result += value
            } else {
                result += String(rest[open...close])
            }
            rest = rest[rest.index(after: close)...]
        }
        result += rest
        return result
    }

    /// 模板里出现的全部占位符名（按出现顺序，重复的会出现多次）
    ///
    /// - Parameter template: 模板字符串
    /// - Returns: 占位符名数组（已去掉首尾空白）
    public static func placeholderTokens(in template: String) -> [String] {
        var tokens: [String] = []
        var rest = Substring(template)
        while let open = rest.firstIndex(of: "{") {
            let afterOpen = rest.index(after: open)
            guard let close = rest[afterOpen...].firstIndex(of: "}") else { break }
            tokens.append(String(rest[afterOpen..<close]).trimmingCharacters(in: .whitespaces))
            rest = rest[rest.index(after: close)...]
        }
        return tokens
    }

    /// 模板里不认识的占位符（去重、保持首次出现的顺序）
    ///
    /// 适合在 App 启动时自查一遍模板，把拼错的占位符尽早暴露出来。
    ///
    /// - Parameter template: 模板字符串
    /// - Returns: 不认识的占位符名；全部合法时为空数组
    public static func unknownPlaceholders(in template: String) -> [String] {
        var unknown: [String] = []
        for token in placeholderTokens(in: template) where !supportedSet.contains(token) {
            if !unknown.contains(token) { unknown.append(token) }
        }
        return unknown
    }

    /// 某个占位符名是否受支持
    public static func isSupported(_ name: String) -> Bool {
        supportedSet.contains(name.trimmingCharacters(in: .whitespaces))
    }

    // MARK: - 实例用法

    /// 渲染一条日志（等同 `LogTemplate.format(_:with:)`）
    public func render(_ entry: LogEntry) -> String {
        LogTemplate.format(template, with: entry)
    }

    /// 可直接赋给 `LogKit.customFormatter` 的闭包
    ///
    /// - Example:
    ///   ```swift
    ///   LogKit.customFormatter = LogTemplate("{级别} | {消息}").formatter
    ///   ```
    public var formatter: (LogEntry) -> String {
        let template = self.template
        return { entry in LogTemplate.format(template, with: entry) }
    }

    // MARK: - 内部

    /// 取某个占位符对应的值；不认识的占位符返回 `nil`
    static func value(for name: String, entry: LogEntry) -> String? {
        switch name {
        case "time", "时间":
            return entry.timestamp
        case "level", "级别":
            return entry.level.chineseName
        case "category", "分类":
            return entry.category
        case "message", "消息":
            return entry.message
        case "file", "文件":
            return entry.file ?? ""
        case "line", "行":
            return entry.line.map { String($0) } ?? ""
        case "traceId", "追踪ID":
            return entry.traceId ?? ""
        case "fields", "字段":
            guard !entry.fields.isEmpty else { return "" }
            return entry.fields.keys.sorted()
                .map { "\($0)=\(String(describing: entry.fields[$0]!))" }
                .joined(separator: ", ")
        default:
            return nil
        }
    }
}

// MARK: 中文命名别名

/// 中文名：日志模板（等同 `LogTemplate`）
public typealias 日志模板 = LogTemplate

public extension LogTemplate {

    /// 日志模板（中文参数）
    ///
    /// 首参 `模板` 带标签，与英文无标签的 `LogTemplate("…")` 区分开，两者不会歧义。
    ///
    /// - Parameter 模板: 带 `{占位符}` 的模板字符串
    init(模板: String) {
        self.init(模板)
    }

    /// 渲染一条日志（等同 `format(_:with:)`）
    static func 渲染(_ 模板: String, 条目: LogEntry) -> String {
        format(模板, with: 条目)
    }

    /// 模板里的占位符（等同 `placeholderTokens(in:)`）
    static func 占位符(_ 模板: String) -> [String] {
        placeholderTokens(in: 模板)
    }

    /// 不认识的占位符（等同 `unknownPlaceholders(in:)`）
    static func 未知占位符(_ 模板: String) -> [String] {
        unknownPlaceholders(in: 模板)
    }
}
