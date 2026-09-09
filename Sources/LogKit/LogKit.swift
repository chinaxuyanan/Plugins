import Foundation

/// LogKit —— 中文友好的日志打印工具库
///
/// 解决「日志级别混乱、输出格式不统一」的痛点：
/// - 内置调试 / 信息 / 警告 / 错误 / 严重五级日志，见名知意；
/// - 统一输出格式（时间 / 级别 / 分类 / 消息 / 位置），可选控制台或文件输出；
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
/// ```
public enum LogKit {

    /// 库版本号
    public static let version = "0.1.0"

    // MARK: - 配置

    /// 最低输出级别：低于该级别的日志会被过滤（默认 `.debug`，全部输出）
    public static var minimumLevel: LogLevel = .debug

    /// 是否输出到控制台（默认 `true`）
    public static var consoleOutput: Bool = true

    /// 是否同时写入日志文件（默认 `false`）
    public static var fileOutput: Bool = false

    /// 是否在输出中附带「文件:行」位置（默认 `true`）
    public static var showLocation: Bool = true

    /// 日志文件所在目录（默认 Application Support/LogKit）
    public static var logDirectory: URL = {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return base.appendingPathComponent("LogKit", isDirectory: true)
    }()

    /// 时间戳格式（默认 `yyyy-MM-dd HH:mm:ss.SSS`）
    public static var dateFormat: String = "yyyy-MM-dd HH:mm:ss.SSS"

    // MARK: - 输出方法

    /// 调试日志
    ///
    /// - Parameters:
    ///   - message: 日志内容（惰性求值，被过滤时不会执行）
    ///   - category: 分类名，默认「通用」
    ///   - file: 调用处文件名（默认自动填充）
    ///   - line: 调用处行号（默认自动填充）
    public static func debug(_ message: @autoclosure () -> Any,
                             category: String = "通用",
                             file: String = #file, line: Int = #line) {
        log(.debug, message(), category: category, file: file, line: line)
    }

    /// 信息日志
    public static func info(_ message: @autoclosure () -> Any,
                            category: String = "通用",
                            file: String = #file, line: Int = #line) {
        log(.info, message(), category: category, file: file, line: line)
    }

    /// 警告日志
    public static func warning(_ message: @autoclosure () -> Any,
                               category: String = "通用",
                               file: String = #file, line: Int = #line) {
        log(.warning, message(), category: category, file: file, line: line)
    }

    /// 错误日志
    public static func error(_ message: @autoclosure () -> Any,
                             category: String = "通用",
                             file: String = #file, line: Int = #line) {
        log(.error, message(), category: category, file: file, line: line)
    }

    /// 严重日志
    public static func critical(_ message: @autoclosure () -> Any,
                                category: String = "通用",
                                file: String = #file, line: Int = #line) {
        log(.critical, message(), category: category, file: file, line: line)
    }

    // MARK: - 文件管理

    /// 当前日志文件完整路径
    public static var logFileURL: URL {
        logDirectory.appendingPathComponent(logFileName())
    }

    /// 清空当前日志文件
    public static func clearLog() {
        try? FileManager.default.removeItem(at: logFileURL)
    }

    // MARK: - 内部实现

    private static func log(_ level: LogLevel, _ message: Any,
                            category: String, file: String, line: Int) {
        guard level >= minimumLevel else { return }
        let text = formatLine(level: level, message: message, category: category, file: file, line: line)
        if consoleOutput { print(text) }
        if fileOutput { writeToFile(text) }
    }

    private static func formatLine(level: LogLevel, message: Any,
                                   category: String, file: String, line: Int) -> String {
        let base = "[\(timestamp())] [\(level.chineseName)] [\(category)] \(String(describing: message))"
        if showLocation {
            return base + " @ \(fileName(file)):\(line)"
        }
        return base
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
        return formatter.string(from: Date())
    }

    private static func logFileName() -> String {
        "LogKit-\(dayStamp()).log"
    }

    private static func dayStamp() -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: Date())
    }

    private static func writeToFile(_ text: String) {
        let fm = FileManager.default
        do {
            try fm.createDirectory(at: logDirectory, withIntermediateDirectories: true)
            let url = logFileURL
            if !fm.fileExists(atPath: url.path) {
                try "".write(to: url, atomically: true, encoding: .utf8)
            }
            let handle = try FileHandle(forWritingTo: url)
            defer { try? handle.close() }
            try handle.seekToEnd()
            if let data = (text + "\n").data(using: .utf8) {
                try handle.write(contentsOf: data)
            }
        } catch {
            // 文件写入失败时回退到控制台提示，避免日志库自身崩溃
            print("[LogKit] 日志文件写入失败: \(error)")
        }
    }
}
