import Foundation

/// 日志过滤条件
///
/// 对「一批日志条目」做多条件筛选：级别 / 分类 / 关键字 / 时间段 / 追踪 ID，
/// 未设置的项表示不限。关键词不区分大小写，命中消息、分类、文件名、追踪 ID
/// 或任一扩展字段的键 / 值即算命中。
///
/// 条目来源一般有两处：`LogKit.onLog` / `LogKit.addSink` 收集到的 `LogEntry`，
/// 或 `LogKit.recentEntries`（需先把 `LogKit.maxRecentEntries` 设为正数，日志会在内存里保留最近若干条）。
///
/// - Example:
///   ```swift
///   LogKit.maxRecentEntries = 500
///   // …运行一段时间…
///
///   // 只看「网络」分类的错误与严重日志
///   let filter = LogFilter(levels: [.error, .critical], categories: ["网络"])
///   for entry in LogKit.filteredRecentEntries(matching: filter) {
///       print(entry.message)
///   }
///   ```
public struct LogFilter {

    /// 只保留这些级别；`nil` 表示不限
    public var levels: Set<LogLevel>?
    /// 只保留这些分类；`nil` 表示不限
    public var categories: Set<String>?
    /// 关键字（不区分大小写）；`nil` 或空串表示不限
    public var keyword: String?
    /// 起始时刻（含）；`nil` 表示不限
    public var from: Date?
    /// 结束时刻（含）；`nil` 表示不限
    public var to: Date?
    /// 追踪 ID（精确匹配）；`nil` 表示不限
    public var traceId: String?

    /// - Parameters:
    ///   - levels: 只保留这些级别；`nil` 表示不限
    ///   - categories: 只保留这些分类；`nil` 表示不限
    ///   - keyword: 关键字（不区分大小写）；`nil` 或空串表示不限
    ///   - from: 起始时刻（含）；`nil` 表示不限
    ///   - to: 结束时刻（含）；`nil` 表示不限
    ///   - traceId: 追踪 ID（精确匹配）；`nil` 表示不限
    public init(levels: Set<LogLevel>? = nil,
                categories: Set<String>? = nil,
                keyword: String? = nil,
                from: Date? = nil,
                to: Date? = nil,
                traceId: String? = nil) {
        self.levels = levels
        self.categories = categories
        self.keyword = keyword
        self.from = from
        self.to = to
        self.traceId = traceId
    }

    /// 只按级别过滤
    ///
    /// - Parameter level: 要保留的级别
    public init(level: LogLevel) {
        self.init(levels: [level])
    }

    /// 只按关键字过滤
    ///
    /// - Parameter keyword: 关键字（不区分大小写）
    public static func byKeyword(_ keyword: String) -> LogFilter {
        LogFilter(keyword: keyword)
    }

    /// 只按级别过滤
    ///
    /// - Parameter level: 要保留的级别
    public static func byLevel(_ level: LogLevel) -> LogFilter {
        LogFilter(levels: [level])
    }

    /// 只按追踪 ID 过滤
    ///
    /// - Parameter traceId: 追踪 ID（精确匹配）
    public static func byTraceId(_ traceId: String) -> LogFilter {
        LogFilter(traceId: traceId)
    }

    /// 只按时间段过滤
    ///
    /// - Parameters:
    ///   - from: 起始时刻（含）；`nil` 表示不限
    ///   - to: 结束时刻（含）；`nil` 表示不限
    public static func inRange(from: Date? = nil, to: Date? = nil) -> LogFilter {
        LogFilter(from: from, to: to)
    }

    /// 是否没有设置任何条件（此时任何条目都会通过）
    public var isEmpty: Bool {
        levels == nil && categories == nil && (keyword?.isEmpty ?? true)
            && from == nil && to == nil && traceId == nil
    }

    /// 判断单条日志是否满足全部条件
    ///
    /// - Parameter entry: 日志条目
    /// - Returns: `true` 表示满足（未设置的条件自动通过）
    public func matches(_ entry: LogEntry) -> Bool {
        if let levels = levels, !levels.contains(entry.level) { return false }
        if let categories = categories, !categories.contains(entry.category) { return false }
        if let traceId = traceId, entry.traceId != traceId { return false }
        if let from = from, entry.date < from { return false }
        if let to = to, entry.date > to { return false }
        if let keyword = keyword, !keyword.isEmpty,
           !Self.matchesKeyword(keyword.lowercased(), entry) { return false }
        return true
    }

    /// 过滤一批日志条目，保持原顺序
    ///
    /// - Parameter entries: 待过滤的日志条目
    /// - Returns: 满足条件的条目
    public func filter(_ entries: [LogEntry]) -> [LogEntry] {
        entries.filter(matches)
    }

    /// 内部：关键字是否命中（消息 / 分类 / 文件名 / 追踪 ID / 扩展字段的键与值）
    private static func matchesKeyword(_ lowered: String, _ entry: LogEntry) -> Bool {
        if entry.message.lowercased().contains(lowered) { return true }
        if entry.category.lowercased().contains(lowered) { return true }
        if let traceId = entry.traceId, traceId.lowercased().contains(lowered) { return true }
        if let file = entry.file, file.lowercased().contains(lowered) { return true }
        for (key, value) in entry.fields {
            if key.lowercased().contains(lowered) { return true }
            if String(describing: value).lowercased().contains(lowered) { return true }
        }
        return false
    }
}

// MARK: 中文命名别名

/// 中文名：日志过滤条件（等同 `LogFilter`）
public typealias 日志过滤条件 = LogFilter

public extension LogFilter {

    /// 日志过滤条件（中文参数）
    ///
    /// 首参 `级别` 无默认值：这样 `LogFilter()` 才不会与英文
    /// `init(levels:categories:keyword:from:to:traceId:)`（参数全有默认值）产生「歧义调用」。
    /// 只想按分类 / 关键字筛选时，把不需要的项显式传 `nil` 即可，例如
    /// `LogFilter(级别: nil, 分类: ["网络"])`。
    ///
    /// - Parameters:
    ///   - 级别: 只保留这些级别；`nil` 表示不限
    ///   - 分类: 只保留这些分类；`nil` 表示不限
    ///   - 关键字: 关键字（不区分大小写）；`nil` 或空串表示不限
    ///   - 起始时间: 起始时刻（含）；`nil` 表示不限
    ///   - 结束时间: 结束时刻（含）；`nil` 表示不限
    ///   - 追踪ID: 追踪 ID（精确匹配）；`nil` 表示不限
    init(级别: Set<LogLevel>?,
         分类: Set<String>? = nil,
         关键字: String? = nil,
         起始时间: Date? = nil,
         结束时间: Date? = nil,
         追踪ID: String? = nil) {
        self.init(levels: 级别, categories: 分类, keyword: 关键字,
                  from: 起始时间, to: 结束时间, traceId: 追踪ID)
    }

    /// 只按关键字过滤（等同 `byKeyword`）
    static func 按关键字(_ 关键字: String) -> LogFilter { byKeyword(关键字) }

    /// 只按级别过滤（等同 `byLevel`）
    static func 按级别(_ 级别: LogLevel) -> LogFilter { byLevel(级别) }

    /// 只按追踪 ID 过滤（等同 `byTraceId`）
    static func 按追踪ID(_ 追踪ID: String) -> LogFilter { byTraceId(追踪ID) }

    /// 只按时间段过滤（等同 `inRange(from:to:)`）
    static func 时间段(从 起始时间: Date? = nil, 到 结束时间: Date? = nil) -> LogFilter {
        inRange(from: 起始时间, to: 结束时间)
    }

    /// 是否没有设置任何条件（等同 `isEmpty`）
    var 为空: Bool { isEmpty }

    /// 判断单条日志是否满足全部条件（等同 `matches(_:)`）
    func 匹配(_ 条目: LogEntry) -> Bool { matches(条目) }

    /// 过滤一批日志条目（等同 `filter(_:)`）
    func 过滤(_ 条目: [LogEntry]) -> [LogEntry] { filter(条目) }
}
