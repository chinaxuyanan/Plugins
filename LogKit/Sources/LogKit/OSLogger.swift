import Foundation
import os

/// 系统日志桥接：封装 Apple 统一日志 `os.Logger`
///
/// 与 `LogKit`（`print` / 文件输出）不同，`os.Logger` 直接写入**系统统一日志**，
/// 可在 Console.app 里按子系统（subsystem）与分类（category）过滤查看，
/// 并享受系统级的隐私标记、日志分级与归档机制，适合正式上线的 App 埋点。
///
/// - Important: `os.Logger` 需 iOS 14+ / macOS 11+（本库基线之上，无需额外标注）。
///
/// - Example:
///   ```swift
///   let 系统日志 = OSLogger(subsystem: "com.example.app", category: "网络")
///   系统日志.info("用户登录成功")
///   系统日志.error("请求失败")
///   ```
///
/// - Note: 这是一个轻量桥接，只做等级转发；消息一律以 `.public` 隐私级输出（否则
///   系统会按 `.private` 在 Console 里打码）。需要 `fields` / JSON / 文件输出时请用 `LogKit`。
public struct OSLogger {

    private let logger: Logger

    /// - Parameters:
    ///   - subsystem: 子系统标识（建议反域名，如 `com.example.app`），默认取主 Bundle 标识
    ///   - category: 分类名，默认「通用」
    public init(subsystem: String = Bundle.main.bundleIdentifier ?? "com.example.app",
                category: String = "通用") {
        self.logger = Logger(subsystem: subsystem, category: category)
    }

    /// 调试级日志（最细粒度，排查用）
    public func debug(_ message: String) {
        logger.debug("\(message, privacy: .public)")
    }

    /// 信息级日志（常规运行信息）
    public func info(_ message: String) {
        logger.info("\(message, privacy: .public)")
    }

    /// 通知级日志（`os.Logger` 默认级别，比 info 稍正式）
    public func notice(_ message: String) {
        logger.notice("\(message, privacy: .public)")
    }

    /// 错误级日志（功能出错）
    public func error(_ message: String) {
        logger.error("\(message, privacy: .public)")
    }

    /// 严重级日志（致命错误）
    public func critical(_ message: String) {
        logger.critical("\(message, privacy: .public)")
    }

    /// 故障级日志（系统级故障，最高等级）
    public func fault(_ message: String) {
        logger.fault("\(message, privacy: .public)")
    }
}

// MARK: 中文命名别名

/// 中文名：系统日志器（等同 `OSLogger`）
public typealias 系统日志器 = OSLogger

public extension OSLogger {
    /// 系统日志器（中文参数）
    /// - Parameters:
    ///   - 子系统: 子系统标识（反域名，如 `com.example.app`）
    ///   - 分类: 分类名，默认「通用」
    init(子系统: String, 分类: String = "通用") {
        self.init(subsystem: 子系统, category: 分类)
    }

    /// 调试级日志（等同 `debug`）
    func 调试(_ 消息: String) { debug(消息) }

    /// 信息级日志（等同 `info`）
    func 信息(_ 消息: String) { info(消息) }

    /// 通知级日志（等同 `notice`）
    func 通知(_ 消息: String) { notice(消息) }

    /// 错误级日志（等同 `error`）
    func 错误(_ 消息: String) { error(消息) }

    /// 严重级日志（等同 `critical`）
    func 严重(_ 消息: String) { critical(消息) }

    /// 故障级日志（等同 `fault`）
    func 故障(_ 消息: String) { fault(消息) }
}
