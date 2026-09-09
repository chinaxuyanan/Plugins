import Foundation
import Dispatch

/// LogKit —— 中文友好的日志打印工具库
///
/// 解决「日志级别混乱、输出格式不统一」的痛点：
/// - 内置调试 / 信息 / 警告 / 错误 / 严重五级日志，见名知意；
/// - 统一输出格式（时间 / 级别 / 分类 / 消息 / 位置），可选控制台或文件输出；
/// - 支持单行文本 / JSON 两种输出格式，文件写入可异步，避免阻塞主线程；
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
    public static let version = "0.3.0"

    // MARK: - 配置

    /// 最低输出级别：低于该级别的日志会被过滤（默认 `.debug`，全部输出）
    public static var minimumLevel: LogLevel = .debug

    /// 是否输出到控制台（默认 `true`）
    public static var consoleOutput: Bool = true

    /// 是否同时写入日志文件（默认 `false`）
    public static var fileOutput: Bool = false

    /// 是否在输出中附带「文件:行」位置（默认 `true`）
    public static var showLocation: Bool = true

    /// 输出格式（默认 `.text` 单行文本）
    ///
    /// - `.text`：人类可读的单行文本，形如 `[时间] [级别] [分类] 消息 @ 文件:行`
    /// - `.json`：结构化 JSON 对象，便于日志采集 / 机器解析
    public static var outputFormat: LogOutputFormat = .text

    /// 是否异步写文件（默认 `true`）
    ///
    /// 开启后，文件写入在后台串行队列执行，不阻塞当前线程（尤其是主线程）。
    /// 关闭则同步写入，调用返回时日志已落盘。
    ///
    /// - Note: `.critical` 严重日志无论此开关如何，始终同步落盘，避免进程崩溃时丢失。
    public static var asyncWrite: Bool = true

    /// 日志文件所在目录（默认 Application Support/LogKit）
    public static var logDirectory: URL = {
        let base = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        return base.appendingPathComponent("LogKit", isDirectory: true)
    }()

    /// 时间戳格式（默认 `yyyy-MM-dd HH:mm:ss.SSS`）
    public static var dateFormat: String = "yyyy-MM-dd HH:mm:ss.SSS"

    /// 单个日志文件大小上限（字节）
    ///
    /// 当前日志文件达到该大小时，会自动归档（重命名为带时间戳的文件）并开启新文件。
    /// 设为 `0` 表示不按大小轮转（默认 `0`）。
    public static var maxFileSize: Int = 0

    /// 最多保留的日志文件数量
    ///
    /// 日志目录里 `LogKit-*.log` 文件超过该数量时，自动删除最旧的。
    /// 设为 `0` 表示不清理（默认 `0`）。
    public static var maxLogFiles: Int = 0

    /// 分类白名单：只输出这些分类的日志
    ///
    /// `nil` 表示全部输出（默认 `nil`）。设置后，不在名单里的分类会被直接跳过。
    ///
    /// - Example:
    ///   ```swift
    ///   LogKit.enabledCategories = ["网络", "存储"]
    ///   ```
    public static var enabledCategories: Set<String>? = nil

    /// 分类黑名单：跳过这些分类的日志
    ///
    /// 默认空集合。
    ///
    /// - Example:
    ///   ```swift
    ///   LogKit.ignoredCategories = ["轮询"]
    ///   ```
    public static var ignoredCategories: Set<String> = []

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
        writeQueue.sync {
            try? FileManager.default.removeItem(at: logFileURL)
        }
    }

    /// 立即轮转当前日志文件
    ///
    /// 把当前日志文件归档（重命名为带时间戳的文件），下一个日志会写入全新的文件。
    /// 一般用于主动切分日志，比如 App 启动时调用一次。
    public static func rotateLogFile() {
        writeQueue.sync {
            fileLock.lock()
            defer { fileLock.unlock() }
            if FileManager.default.fileExists(atPath: logFileURL.path) {
                archiveCurrentFile(logFileURL)
            }
            cleanupOldFiles()
        }
    }

    /// 等待所有待写入的日志落盘
    ///
    /// 异步写入开启时，日志会先进入后台队列；调用本方法会阻塞直到队列排空，
    /// 一般用于 App 即将进入后台 / 退出前，确保日志不丢失。
    public static func flush() {
        writeQueue.sync {}
    }

    // MARK: - 内部实现

    private static func log(_ level: LogLevel, _ message: Any,
                            category: String, file: String, line: Int) {
        guard level >= minimumLevel else { return }
        if let enabled = enabledCategories, !enabled.contains(category) { return }
        if ignoredCategories.contains(category) { return }
        let text = formatLine(level: level, message: message, category: category, file: file, line: line)
        if consoleOutput { print(text) }
        if fileOutput { enqueueWrite(level: level, text) }
    }

    private static func formatLine(level: LogLevel, message: Any,
                                   category: String, file: String, line: Int) -> String {
        switch outputFormat {
        case .text:
            return formatText(level: level, message: message, category: category, file: file, line: line)
        case .json:
            return formatJSON(level: level, message: message, category: category, file: file, line: line)
        }
    }

    private static func formatText(level: LogLevel, message: Any,
                                   category: String, file: String, line: Int) -> String {
        let base = "[\(timestamp())] [\(level.chineseName)] [\(category)] \(String(describing: message))"
        if showLocation {
            return base + " @ \(fileName(file)):\(line)"
        }
        return base
    }

    private static func formatJSON(level: LogLevel, message: Any,
                                   category: String, file: String, line: Int) -> String {
        var dict: [String: Any] = [
            "time": timestamp(),
            "level": level.chineseName,
            "levelValue": level.rawValue,
            "category": category,
            "message": String(describing: message)
        ]
        if showLocation {
            dict["file"] = fileName(file)
            dict["line"] = line
        }
        guard let data = try? JSONSerialization.data(withJSONObject: dict, options: []),
              let json = String(data: data, encoding: .utf8) else {
            // JSON 序列化失败时回退为单行文本，保证日志不丢失
            return formatText(level: level, message: message, category: category, file: file, line: line)
        }
        return json
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

    private static let fileLock = NSLock()

    /// 文件写入专用串行队列：异步写入时在此队列落盘，保证顺序且不阻塞调用线程
    private static let writeQueue = DispatchQueue(label: "com.LogKit.write")

    /// 将日志入队写文件；严重日志始终同步落盘，避免进程崩溃时丢失
    private static func enqueueWrite(level: LogLevel, _ text: String) {
        if level == .critical || !asyncWrite {
            writeQueue.sync { writeToFile(text) }
        } else {
            writeQueue.async { writeToFile(text) }
        }
    }

    private static func writeToFile(_ text: String) {
        fileLock.lock()
        defer { fileLock.unlock() }
        let fm = FileManager.default
        do {
            try fm.createDirectory(at: logDirectory, withIntermediateDirectories: true)
            let url = logFileURL
            // 大小轮转：当前文件达到上限时先归档
            if maxFileSize > 0, fm.fileExists(atPath: url.path),
               let attrs = try? fm.attributesOfItem(atPath: url.path),
               let size = (attrs[.size] as? NSNumber)?.intValue,
               size >= maxFileSize {
                archiveCurrentFile(url)
            }
            if !fm.fileExists(atPath: url.path) {
                try "".write(to: url, atomically: true, encoding: .utf8)
            }
            let handle = try FileHandle(forWritingTo: url)
            defer { try? handle.close() }
            try handle.seekToEnd()
            if let data = (text + "\n").data(using: .utf8) {
                try handle.write(contentsOf: data)
            }
            cleanupOldFiles()
        } catch {
            // 文件写入失败时回退到控制台提示，避免日志库自身崩溃
            print("[LogKit] 日志文件写入失败: \(error)")
        }
    }

    /// 把当前日志文件归档为带时间戳的文件
    private static func archiveCurrentFile(_ url: URL) {
        let base = url.deletingPathExtension().lastPathComponent
        let ext = url.pathExtension
        let archived = logDirectory.appendingPathComponent("\(base)-\(archiveStamp()).\(ext)")
        try? FileManager.default.moveItem(at: url, to: archived)
    }

    /// 归档文件名的时间戳（毫秒级，避免同秒冲突）
    private static func archiveStamp() -> String {
        archiveFormatter.string(from: Date())
    }

    private static let archiveFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HHmmssSSS"
        return f
    }()

    /// 清理超出 `maxLogFiles` 的最旧日志文件
    private static func cleanupOldFiles() {
        guard maxLogFiles > 0 else { return }
        let fm = FileManager.default
        guard let files = try? fm.contentsOfDirectory(at: logDirectory,
                                                      includingPropertiesForKeys: [.contentModificationDateKey],
                                                      options: []) else { return }
        let logs = files.filter { $0.pathExtension == "log" && $0.lastPathComponent.hasPrefix("LogKit-") }
        guard logs.count > maxLogFiles else { return }
        let sorted = logs.sorted { (a: URL, b: URL) -> Bool in
            let ta = (try? a.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? .distantPast
            let tb = (try? b.resourceValues(forKeys: [.contentModificationDateKey]))?.contentModificationDate ?? .distantPast
            return ta < tb
        }
        for url in sorted.prefix(logs.count - maxLogFiles) {
            try? fm.removeItem(at: url)
        }
    }
}
