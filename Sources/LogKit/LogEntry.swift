import Foundation

/// 一条日志的结构化信息
///
/// 由 LogKit 在格式化每条日志时组装，传给自定义格式闭包 `LogKit.customFormatter`，
/// 让开发者能完全接管日志行的拼装（按自己的顺序、分隔符、字段取舍输出）。
public struct LogEntry {

    /// 时间戳字符串（已按 `LogKit.dateFormat` 格式化）
    public let timestamp: String

    /// 日志级别
    public let level: LogLevel

    /// 分类名
    public let category: String

    /// 消息内容（已转成字符串）
    public let message: String

    /// 调用处文件名（当 `LogKit.showLocation` 关闭时为 `nil`）
    public let file: String?

    /// 调用处行号（当 `LogKit.showLocation` 关闭时为 `nil`）
    public let line: Int?

    /// 本次日志附加的扩展字段（键值对）
    public let fields: [String: Any]

    /// 追踪 ID（当设置了 `LogKit.traceId` 或日志器 `traceId` 时非空）
    public let traceId: String?
}
