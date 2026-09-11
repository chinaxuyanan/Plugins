import Foundation

/// 日志文件的体积统计
///
/// 把日志目录下的「当前日志 + 归档日志 + 崩溃日志」逐个量一遍大小，用来做
/// 「日志占了多大空间」的展示，或决定要不要清理。通过 `LogKit.logStorage` 获取。
///
/// - Example:
///   ```swift
///   let storage = LogKit.logStorage
///   print(storage.text)          // 一段可直接展示的中文清单
///   print(storage.totalSizeText) // 形如「1.5 MB」
///   ```
public struct LogStorage {

    /// 单个日志文件的信息
    public struct Item {

        /// 文件路径
        public let url: URL
        /// 文件大小（字节；读不到时为 `0`）
        public let bytes: Int
        /// 最后修改时间（读不到时为 `nil`）
        public let modified: Date?
        /// 是否当前正在写入的日志文件
        public let isCurrent: Bool

        /// 用文件信息创建一项
        /// - Parameters:
        ///   - url: 文件路径
        ///   - bytes: 文件大小（字节）
        ///   - modified: 最后修改时间
        ///   - isCurrent: 是否当前正在写入的日志文件
        public init(url: URL, bytes: Int, modified: Date?, isCurrent: Bool) {
            self.url = url
            self.bytes = bytes
            self.modified = modified
            self.isCurrent = isCurrent
        }

        /// 文件名
        public var name: String { url.lastPathComponent }

        /// 大小文本（形如 `12.3 KB`）
        public var sizeText: String { LogStorage.humanSize(bytes) }
    }

    /// 各日志文件（当前日志在最前，其余按修改时间从新到旧）
    public let items: [Item]

    /// 用文件列表创建统计
    /// - Parameter items: 各日志文件的信息
    public init(items: [Item]) {
        self.items = items
    }

    /// 文件个数
    public var fileCount: Int { items.count }

    /// 合计大小（字节）
    public var totalBytes: Int { items.reduce(0) { $0 + $1.bytes } }

    /// 合计大小文本（形如 `1.5 MB`）
    public var totalSizeText: String { Self.humanSize(totalBytes) }

    /// 中文清单文本（每个文件一行，当前日志标出「当前」）
    public var text: String {
        var lines: [String] = []
        lines.append("日志共 \(fileCount) 个文件，合计 \(totalSizeText)")
        for item in items {
            lines.append("  \(item.name)\(item.isCurrent ? "（当前）" : "") \(item.sizeText)")
        }
        return lines.joined(separator: "\n")
    }

    /// 把字节数格式化成人类可读的大小
    ///
    /// 不足 1 KB 时按整数显示 `B`，否则保留一位小数显示 `KB` / `MB` / `GB` / `TB`；
    /// 负数按 `0` 处理。
    ///
    /// - Parameter bytes: 字节数
    public static func humanSize(_ bytes: Int) -> String {
        let value = max(0, bytes)
        if value < 1024 { return "\(value) B" }
        let units = ["KB", "MB", "GB", "TB"]
        var size = Double(value) / 1024
        var index = 0
        while size >= 1024 && index < units.count - 1 {
            size /= 1024
            index += 1
        }
        return String(format: "%.1f %@", size, units[index])
    }
}

// MARK: 中文命名别名

/// 中文名：日志体积统计（等同 `LogStorage`）
public typealias 日志体积 = LogStorage

/// 中文名：单个日志文件信息（等同 `LogStorage.Item`）
public typealias 日志文件项 = LogStorage.Item

public extension LogStorage {

    /// 用文件列表创建统计（中文参数）
    /// - Parameter 文件: 各日志文件的信息
    init(文件: [Item]) {
        self.init(items: 文件)
    }

    /// 各日志文件（等同 `items`）
    var 文件: [Item] { items }
    /// 文件个数（等同 `fileCount`）
    var 文件数: Int { fileCount }
    /// 合计大小（字节，等同 `totalBytes`）
    var 总字节: Int { totalBytes }
    /// 合计大小文本（等同 `totalSizeText`）
    var 总大小文本: String { totalSizeText }
    /// 中文清单文本（等同 `text`）
    var 清单文本: String { text }

    /// 把字节数格式化成人类可读的大小（等同 `humanSize(_:)`）
    static func 人性化大小(_ 字节: Int) -> String {
        humanSize(字节)
    }
}

public extension LogStorage.Item {

    /// 用文件信息创建一项（中文参数）
    /// - Parameters:
    ///   - 路径: 文件路径
    ///   - 字节: 文件大小（字节）
    ///   - 修改时间: 最后修改时间
    ///   - 是否当前: 是否当前正在写入的日志文件
    init(路径: URL, 字节: Int, 修改时间: Date?, 是否当前: Bool) {
        self.init(url: 路径, bytes: 字节, modified: 修改时间, isCurrent: 是否当前)
    }

    /// 文件名（等同 `name`）
    var 文件名: String { name }
    /// 大小文本（等同 `sizeText`）
    var 大小文本: String { sizeText }
    /// 文件路径（等同 `url`）
    var 路径: URL { url }
}
