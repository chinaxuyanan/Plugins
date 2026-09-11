import Foundation

/// 一组「消息相同」的日志
///
/// 对一批 `LogEntry` 按消息内容聚合后的结果：同一条消息出现多次时归成一组，
/// 组里保留全部原始条目，方便看「哪句话刷得最多」「这句话都在哪些分类、什么级别下出现」。
///
/// - Example:
///   ```swift
///   LogKit.maxRecentEntries = 500
///   // …运行一段时间…
///
///   for group in LogKit.groupByMessage(LogKit.recentEntries) {
///       print("\(group.count) 次：\(group.message)")
///   }
///   ```
public struct MessageGroup {

    /// 归一化后的消息（聚合键；忽略大小写聚合时是首次出现的原始大小写）
    public let message: String
    /// 组内日志（按时间从早到晚；时间相同保持传入顺序）
    public let entries: [LogEntry]
    /// 组内出现过的分类（去重、按字典序）
    public let categories: [String]
    /// 组内最高级别
    public let level: LogLevel

    /// 用一条消息和它的全部条目创建分组
    /// - Parameters:
    ///   - message: 归一化后的消息
    ///   - entries: 组内日志
    public init(message: String, entries: [LogEntry]) {
        self.message = message
        self.entries = messageGroupSortedByDate(entries)
        self.categories = Array(Set(entries.map(\.category))).sorted()
        self.level = entries.map(\.level).max() ?? .info
    }

    /// 组内条数
    public var count: Int { entries.count }

    /// 组内最早一条的时刻（空组为 `nil`）
    public var earliest: Date? { entries.map(\.date).min() }

    /// 组内最晚一条的时刻（空组为 `nil`）
    public var latest: Date? { entries.map(\.date).max() }

    /// 最高级别对应的中文名
    public var levelText: String { level.chineseName }

    /// 中文单行摘要（形如 `3 次 · 错误 · 网络请求失败`）
    public var text: String {
        "\(count) 次 · \(levelText) · \(message)"
    }

    /// 把一批日志按消息聚合成分组
    ///
    /// 分组键是消息本身（可选去掉首尾空白、可选忽略大小写）；返回结果按「条数从多到少」排序，
    /// 条数相同时按消息字典序，保证同样输入总是同样顺序。
    ///
    /// - Parameters:
    ///   - entries: 待聚合的日志条目
    ///   - trimWhitespace: 是否先去掉消息首尾空白再比，默认 `true`
    ///   - ignoringCase: 是否忽略大小写，默认 `false`
    ///   - top: 最多返回几组，`0` 表示不限，默认 `0`
    /// - Returns: 聚合后的分组
    public static func groups(from entries: [LogEntry],
                              trimWhitespace: Bool = true,
                              ignoringCase: Bool = false,
                              top: Int = 0) -> [MessageGroup] {
        var buckets: [String: [LogEntry]] = [:]
        var display: [String: String] = [:]
        for entry in entries {
            let raw = trimWhitespace
                ? entry.message.trimmingCharacters(in: .whitespacesAndNewlines)
                : entry.message
            let key = ignoringCase ? raw.lowercased() : raw
            if buckets[key] == nil { display[key] = raw }
            buckets[key, default: []].append(entry)
        }
        let sortedKeys = buckets.keys.sorted { lhs, rhs in
            let left = buckets[lhs]?.count ?? 0
            let right = buckets[rhs]?.count ?? 0
            return left == right ? lhs < rhs : left > right
        }
        var result = sortedKeys.map { key in
            MessageGroup(message: display[key] ?? key, entries: buckets[key] ?? [])
        }
        if top > 0 { result = Array(result.prefix(top)) }
        return result
    }
}

/// 文件内部：按时间升序稳定排序（时间相同保持原有先后，结果可复现）
private func messageGroupSortedByDate(_ entries: [LogEntry]) -> [LogEntry] {
    entries.enumerated()
        .sorted { lhs, rhs in
            lhs.element.date == rhs.element.date
                ? lhs.offset < rhs.offset
                : lhs.element.date < rhs.element.date
        }
        .map { $0.element }
}

// MARK: 中文命名别名

/// 中文名：消息聚合组（等同 `MessageGroup`）
public typealias 消息聚合组 = MessageGroup

public extension MessageGroup {

    /// 用一条消息和它的全部条目创建分组（中文参数）
    /// - Parameters:
    ///   - 消息: 归一化后的消息
    ///   - 日志: 组内日志
    init(消息: String, 日志: [LogEntry]) {
        self.init(message: 消息, entries: 日志)
    }

    /// 归一化后的消息（等同 `message`）
    var 消息: String { message }
    /// 组内日志（等同 `entries`）
    var 组内日志: [LogEntry] { entries }
    /// 组内出现过的分类（等同 `categories`）
    var 分类: [String] { categories }
    /// 组内最高级别（等同 `level`）
    var 级别: LogLevel { level }
    /// 组内条数（等同 `count`）
    var 次数: Int { count }
    /// 组内最早一条的时刻（等同 `earliest`）
    var 最早时间: Date? { earliest }
    /// 组内最晚一条的时刻（等同 `latest`）
    var 最晚时间: Date? { latest }
    /// 最高级别对应的中文名（等同 `levelText`）
    var 级别名: String { levelText }
    /// 中文单行摘要（等同 `text`）
    var 摘要文本: String { text }

    /// 把一批日志按消息聚合（等同 `groups(from:trimWhitespace:ignoringCase:top:)`）
    /// - Parameters:
    ///   - 条目: 待聚合的日志条目
    ///   - 去空白: 是否先去掉消息首尾空白再比，默认 `true`
    ///   - 忽略大小写: 是否忽略大小写，默认 `false`
    ///   - 最多组数: 最多返回几组，`0` 表示不限，默认 `0`
    static func 聚合成组(_ 条目: [LogEntry],
                       去空白: Bool = true,
                       忽略大小写: Bool = false,
                       最多组数: Int = 0) -> [MessageGroup] {
        groups(from: 条目, trimWhitespace: 去空白, ignoringCase: 忽略大小写, top: 最多组数)
    }
}
