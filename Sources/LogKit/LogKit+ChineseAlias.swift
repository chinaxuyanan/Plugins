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
    ///   - 文件: 调用处文件名（自动填充，一般不用传）
    ///   - 行: 调用处行号（自动填充，一般不用传）
    static func 调试(_ 消息: @autoclosure () -> Any,
                    分类: String = "通用",
                    文件: String = #file, 行: Int = #line) {
        debug(消息(), category: 分类, file: 文件, line: 行)
    }

    /// 信息日志（等同 `info`）
    static func 信息(_ 消息: @autoclosure () -> Any,
                    分类: String = "通用",
                    文件: String = #file, 行: Int = #line) {
        info(消息(), category: 分类, file: 文件, line: 行)
    }

    /// 警告日志（等同 `warning`）
    static func 警告(_ 消息: @autoclosure () -> Any,
                    分类: String = "通用",
                    文件: String = #file, 行: Int = #line) {
        warning(消息(), category: 分类, file: 文件, line: 行)
    }

    /// 错误日志（等同 `error`）
    static func 错误(_ 消息: @autoclosure () -> Any,
                    分类: String = "通用",
                    文件: String = #file, 行: Int = #line) {
        error(消息(), category: 分类, file: 文件, line: 行)
    }

    /// 严重日志（等同 `critical`）
    static func 严重(_ 消息: @autoclosure () -> Any,
                    分类: String = "通用",
                    文件: String = #file, 行: Int = #line) {
        critical(消息(), category: 分类, file: 文件, line: 行)
    }

    /// 清空日志文件（等同 `clearLog`）
    static func 清空日志() { clearLog() }

    /// 立即轮转日志文件（等同 `rotateLogFile`）
    static func 轮转日志() { rotateLogFile() }
}
