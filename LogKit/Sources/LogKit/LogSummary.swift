import Foundation

/// 日志统计摘要
///
/// 对一批 `LogEntry` 做汇总：总条数、各级别条数、错误率、时间跨度、出现最多的分类。
/// 适合做「当前会话日志概况」面板，或把摘要上报到服务端 / 写进崩溃报告。
///
/// - Example:
///   ```swift
///   LogKit.maxRecentEntries = 500
///   // …运行一段时间…
///
///   let summary = LogSummary(entries: LogKit.recentEntries)
///   print(summary.text)      // 一段可直接展示的中文摘要
///   print(summary.errorRate) // 错误 / 严重日志占比
///   ```
public struct LogSummary {

    /// 统计的日志总条数
    public let total: Int
    /// 各级别条数（未出现的级别不在字典里，用 `count(of:)` 取值为 `0`）
    public let counts: [LogLevel: Int]
    /// 最早一条日志的时刻（空数组为 `nil`）
    public let earliest: Date?
    /// 最新一条日志的时刻（空数组为 `nil`）
    public let latest: Date?
    /// 出现次数最多的分类（按次数从多到少，最多 `topCategoriesLimit` 条）
    public let topCategories: [(category: String, count: Int)]

    /// 汇总一批日志条目
    ///
    /// - Parameters:
    ///   - entries: 日志条目数组（顺序不限）
    ///   - topCategories: 分类排行最多保留几项，默认 `5`
    public init(entries: [LogEntry], topCategories: Int = 5) {
        self.total = entries.count

        var counts: [LogLevel: Int] = [:]
        var categoryCounts: [String: Int] = [:]
        var earliest: Date?
        var latest: Date?

        for entry in entries {
            counts[entry.level, default: 0] += 1
            categoryCounts[entry.category, default: 0] += 1
            if earliest == nil || entry.date < earliest! { earliest = entry.date }
            if latest == nil || entry.date > latest! { latest = entry.date }
        }

        self.counts = counts
        self.earliest = earliest
        self.latest = latest
        // 次数从多到少；次数相同时按分类名字典序，保证结果稳定可复现
        self.topCategories = categoryCounts
            .sorted { $0.value == $1.value ? $0.key < $1.key : $0.value > $1.value }
            .prefix(max(0, topCategories))
            .map { (category: $0.key, count: $0.value) }
    }

    /// 某个级别的条数（未出现返回 `0`）
    ///
    /// - Parameter level: 日志级别
    public func count(of level: LogLevel) -> Int {
        counts[level] ?? 0
    }

    /// 错误 + 严重日志的条数
    public var errorCount: Int {
        count(of: .error) + count(of: .critical)
    }

    /// 错误日志占比（`0.0` ~ `1.0`；没有日志时为 `0`）
    public var errorRate: Double {
        total == 0 ? 0 : Double(errorCount) / Double(total)
    }

    /// 时间跨度（秒）；条数不足两条、无法计算时为 `nil`
    public var duration: TimeInterval? {
        guard let earliest = earliest, let latest = latest else { return nil }
        return latest.timeIntervalSince(earliest)
    }

    /// 中文摘要文本（多行，可直接展示或写进上报内容）
    ///
    /// - Parameter topCategories: 分类排行最多列出几项，默认 `3`；传 `0` 表示不列出
    public func text(topCategories: Int = 3) -> String {
        var lines: [String] = []
        lines.append("日志共 \(total) 条")
        let levelParts = LogLevel.allCases.map { "\($0.chineseName) \(count(of: $0))" }
        lines.append("各级别：" + levelParts.joined(separator: "，"))
        lines.append(String(format: "错误率：%.1f%%", errorRate * 100))
        if let duration = duration {
            lines.append(String(format: "时间跨度：%.2f 秒", duration))
        }
        if topCategories > 0, !self.topCategories.isEmpty {
            let parts = self.topCategories.prefix(topCategories).map { "\($0.category)(\($0.count))" }
            lines.append("分类排行：" + parts.joined(separator: "，"))
        }
        return lines.joined(separator: "\n")
    }
}

// MARK: 中文命名别名

/// 中文名：日志统计摘要（等同 `LogSummary`）
public typealias 日志摘要 = LogSummary

public extension LogSummary {

    /// 汇总一批日志条目（中文参数）
    /// - Parameters:
    ///   - 条目: 日志条目数组（顺序不限）
    ///   - 分类排行数量: 分类排行最多保留几项，默认 `5`
    init(条目: [LogEntry], 分类排行数量: Int = 5) {
        self.init(entries: 条目, topCategories: 分类排行数量)
    }

    /// 统计的日志总条数（等同 `total`）
    var 总计: Int { total }

    /// 各级别条数（等同 `counts`）
    var 各级别条数: [LogLevel: Int] { counts }

    /// 最早一条日志的时刻（等同 `earliest`）
    var 最早时间: Date? { earliest }

    /// 最新一条日志的时刻（等同 `latest`）
    var 最晚时间: Date? { latest }

    /// 某个级别的条数（等同 `count(of:)`）
    func 级别条数(_ 级别: LogLevel) -> Int { count(of: 级别) }

    /// 错误 + 严重日志条数（等同 `errorCount`）
    var 错误条数: Int { errorCount }

    /// 错误日志占比（等同 `errorRate`）
    var 错误率: Double { errorRate }

    /// 时间跨度（秒，等同 `duration`）
    var 时间跨度: TimeInterval? { duration }

    /// 分类排行（等同 `topCategories`）
    var 分类排行: [(category: String, count: Int)] { topCategories }

    /// 中文摘要文本（等同 `text(topCategories:)`）
    func 摘要文本(分类排行数量: Int = 3) -> String { text(topCategories: 分类排行数量) }
}
