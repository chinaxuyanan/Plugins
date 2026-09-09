import Foundation

/// 日志输出格式
///
/// - `.text`：单行文本，人类可读（默认），形如 `[时间] [级别] [分类] 消息 @ 文件:行`
/// - `.json`：结构化 JSON 对象，便于日志采集 / 机器解析
public enum LogOutputFormat {
    /// 单行文本格式（默认）
    case text
    /// 结构化 JSON 格式
    case json
}

public extension LogOutputFormat {
    /// 单行文本格式（等同 `.text`）
    static var 纯文本: LogOutputFormat { .text }
    /// 结构化 JSON 格式（等同 `.json`）
    static var JSON: LogOutputFormat { .json }
}
