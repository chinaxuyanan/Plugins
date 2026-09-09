import Foundation

/// 日志级别
///
/// 级别由低到高：调试 < 信息 < 警告 < 错误 < 严重。
/// 设置 `LogKit.minimumLevel` 后，低于该级别的日志会被自动过滤，不再输出。
public enum LogLevel: Int, CaseIterable, Comparable, CustomStringConvertible {

    /// 调试：开发期排查用，最细粒度
    case debug = 0
    /// 信息：常规运行信息
    case info = 1
    /// 警告：不影响运行，但需留意
    case warning = 2
    /// 错误：功能出错，需处理
    case error = 3
    /// 严重：致命错误，程序可能无法继续
    case critical = 4

    /// 级别对应的中文名
    public var chineseName: String {
        switch self {
        case .debug: return "调试"
        case .info: return "信息"
        case .warning: return "警告"
        case .error: return "错误"
        case .critical: return "严重"
        }
    }

    /// 中文名（等同 `chineseName`）
    public var description: String { chineseName }

    public static func < (lhs: LogLevel, rhs: LogLevel) -> Bool {
        lhs.rawValue < rhs.rawValue
    }
}
