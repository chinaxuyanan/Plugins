import SwiftUI

// MARK: - 热力图日历

/// 热力图日历
///
/// GitHub 贡献图那种样子：一周一列、每列 7 个方格，颜色深浅表示当天的强度。
/// 适合做打卡记录、活跃度统计、习惯追踪。
///
/// 用法是把「日期 → 数值」交给它，数值按区间内的最大值分成若干级（`colors` 有几个色阶就分几级），
/// 数值为 0 或没有数据的日期用 `emptyColor` 画空格。
///
/// - Example:
///   ```swift
///   // 只传 Double；有 Int 数据时用 .mapValues(Double.init) 转一下
///   HeatmapCalendar(values: [日期: 3.0],
///                   startDate: 起点,
///                   endDate: 终点)
///
///   HeatmapCalendar(values: 打卡次数.mapValues(Double.init),
///                   startDate: 半年前,
///                   endDate: Date(),
///                   cellSize: 12,
///                   onSelect: { print("点了", $0) })
///   ```
public struct HeatmapCalendar: View {

    /// 日期 → 强度值（键会被归一到当天零点）
    private let values: [Date: Double]
    /// 区间起点
    private let startDate: Date
    /// 区间终点
    private let endDate: Date
    /// 单个方格的边长
    private let cellSize: CGFloat
    /// 方格间距
    private let spacing: CGFloat
    /// 方格圆角
    private let cornerRadius: CGFloat
    /// 色阶（由浅到深），有几档就分几级
    private let colors: [Color]
    /// 无数据方格的颜色
    private let emptyColor: Color
    /// 计算周次 / 日期用的日历
    private let calendar: Calendar
    /// 是否在顶部显示月份标签
    private let showsMonthLabels: Bool
    /// 点击某个方格的回调
    private let onSelect: ((Date) -> Void)?

    /// 月份标签的格式化器
    private static let monthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "M月"
        return f
    }()

    /// - Parameters:
    ///   - values: 日期 → 强度值；键不必是零点，内部会归一
    ///   - startDate: 区间起点（含当天）
    ///   - endDate: 区间终点（含当天）
    ///   - cellSize: 方格边长，默认 `12`
    ///   - spacing: 方格间距，默认 `3`
    ///   - cornerRadius: 方格圆角，默认 `2`
    ///   - colors: 色阶数组（由浅到深），默认由 `.accentColor` 派生的四档
    ///   - emptyColor: 无数据方格颜色，默认浅灰
    ///   - calendar: 使用的日历，默认 `.current`
    ///   - showsMonthLabels: 是否显示月份标签，默认 `true`
    ///   - onSelect: 点击方格回调，参数为该天零点，默认 `nil`
    public init(values: [Date: Double],
                startDate: Date,
                endDate: Date,
                cellSize: CGFloat = 12,
                spacing: CGFloat = 3,
                cornerRadius: CGFloat = 2,
                colors: [Color] = HeatmapCalendar.defaultColors,
                emptyColor: Color = Color.secondary.opacity(0.15),
                calendar: Calendar = .current,
                showsMonthLabels: Bool = true,
                onSelect: ((Date) -> Void)? = nil) {
        self.values = values
        self.startDate = startDate
        self.endDate = endDate
        self.cellSize = cellSize
        self.spacing = spacing
        self.cornerRadius = cornerRadius
        self.colors = colors.isEmpty ? HeatmapCalendar.defaultColors : colors
        self.emptyColor = emptyColor
        self.calendar = calendar
        self.showsMonthLabels = showsMonthLabels
        self.onSelect = onSelect
    }

    /// 默认色阶：由主题色派生四档深浅
    public static var defaultColors: [Color] {
        [
            Color.accentColor.opacity(0.25),
            Color.accentColor.opacity(0.5),
            Color.accentColor.opacity(0.75),
            Color.accentColor
        ]
    }

    /// 把「日期 → 数值」映射成「当天零点 → 级别」
    ///
    /// 级别从 `1` 到 `levelCount`，`0`（缺省，不在返回的字典里）表示无数据或数值 ≤ 0。
    /// 分级按区间内最大正值等分：`级别 = ceil(数值 / 最大值 × 级别数)`，不足一级的按一级算，
    /// 所以只要有正值就至少是第一档，不会因为数值太小而被当成空格。
    ///
    /// - Parameters:
    ///   - values: 日期 → 数值
    ///   - levelCount: 分几级，默认 `4`
    ///   - calendar: 归一日期用的日历，默认 `.current`
    /// - Returns: 当天零点 → 级别（只含级别 ≥ 1 的日期）
    public static func levels(values: [Date: Double],
                              levelCount: Int = 4,
                              calendar: Calendar = .current) -> [Date: Int] {
        guard levelCount > 0 else { return [:] }
        guard let maxValue = values.values.filter({ $0 > 0 }).max(), maxValue > 0 else { return [:] }
        var result: [Date: Int] = [:]
        for (date, value) in values where value > 0 {
            let ratio = min(1, value / maxValue)
            let level = max(1, min(levelCount, Int(ceil(ratio * Double(levelCount)))))
            result[calendar.startOfDay(for: date)] = level
        }
        return result
    }

    /// 把日期区间切成「一周一列、每列 7 天（周日在最上）」的矩阵
    ///
    /// 首列前面与末列后面不足一周的位置用 `nil` 占位，保证每列恰好 7 个元素，
    /// 这样各列的第 n 行始终是同一个星期几。
    ///
    /// - Parameters:
    ///   - start: 区间起点（含）
    ///   - end: 区间终点（含）
    ///   - calendar: 使用的日历，默认 `.current`
    /// - Returns: 二维数组，外层是列（周），内层是 7 天
    public static func weekColumns(from start: Date,
                                   to end: Date,
                                   calendar: Calendar = .current) -> [[Date?]] {
        let first = calendar.startOfDay(for: min(start, end))
        let last = calendar.startOfDay(for: max(start, end))

        // `.weekday` 在公历里固定是 1=周日 … 7=周六，与 calendar.firstWeekday 无关，
        // 所以这里直接用它算前面的空格数，矩阵恒定「周日在最上」。
        let leadingBlanks = max(0, calendar.component(.weekday, from: first) - 1)
        var days: [Date?] = Array(repeating: nil, count: leadingBlanks)

        var cursor = first
        while cursor <= last {
            days.append(cursor)
            guard let next = calendar.date(byAdding: .day, value: 1, to: cursor) else { break }
            cursor = next
        }
        while days.count % 7 != 0 {
            days.append(nil)
        }

        return stride(from: 0, to: days.count, by: 7).map { offset in
            Array(days[offset..<min(offset + 7, days.count)])
        }
    }

    /// 每列顶部要显示的月份标签（`nil` 表示这一列不显示）
    ///
    /// 规则：取该列第一个有日期的格子，若它的月份与上一个显示过的标签不同就显示，
    /// 否则留空——这样一列月里只会出现一次月份文字，不会每列都重复。
    private func monthLabels(columns: [[Date?]]) -> [String?] {
        var labels: [String?] = []
        var lastMonth: Int?
        for column in columns {
            guard let day = column.compactMap({ $0 }).first else {
                labels.append(nil)
                continue
            }
            let month = calendar.component(.month, from: day)
            if month == lastMonth {
                labels.append(nil)
            } else {
                lastMonth = month
                labels.append(Self.monthFormatter.string(from: day))
            }
        }
        return labels
    }

    public var body: some View {
        let levelMap = Self.levels(values: values, levelCount: colors.count, calendar: calendar)
        let columns = Self.weekColumns(from: startDate, to: endDate, calendar: calendar)
        let labels = monthLabels(columns: columns)

        return VStack(alignment: .leading, spacing: 4) {
            if showsMonthLabels {
                monthLabelRow(labels)
            }
            HStack(alignment: .top, spacing: spacing) {
                ForEach(columns.indices, id: \.self) { columnIndex in
                    VStack(spacing: spacing) {
                        ForEach(0..<7, id: \.self) { rowIndex in
                            cell(day: columns[columnIndex][rowIndex], levelMap: levelMap)
                        }
                    }
                }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("热力图，\(levelMap.count) 天有记录")
    }

    /// 月份标签行：用 ZStack + 水平偏移摆放，避免每个标签把所在列撑宽、破坏方格对齐
    private func monthLabelRow(_ labels: [String?]) -> some View {
        ZStack(alignment: .topLeading) {
            Color.clear.frame(width: 1, height: 1)
            ForEach(labels.indices, id: \.self) { index in
                if let label = labels[index] {
                    Text(label)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .fixedSize()
                        .offset(x: CGFloat(index) * (cellSize + spacing))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    /// 单个方格：有日期就按级别上色，没有日期就用透明占位维持对齐
    @ViewBuilder
    private func cell(day: Date?, levelMap: [Date: Int]) -> some View {
        if let day = day {
            let level = levelMap[day] ?? 0
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(color(for: level))
                .frame(width: cellSize, height: cellSize)
                .onTapGesture { onSelect?(day) }
        } else {
            Color.clear.frame(width: cellSize, height: cellSize)
        }
    }

    /// 级别 → 颜色（级别 0 用空色，其余按色阶取，越界时取最后一档）
    private func color(for level: Int) -> Color {
        guard level > 0, !colors.isEmpty else { return emptyColor }
        return colors[min(level - 1, colors.count - 1)]
    }
}

// MARK: 中文命名别名

/// 中文名：热力图日历（等同 `HeatmapCalendar`）
public typealias 热力图日历 = HeatmapCalendar

public extension HeatmapCalendar {

    /// 热力图日历（中文参数）
    /// - Parameters:
    ///   - 数值: 日期 → 强度值
    ///   - 起始: 区间起点（含当天）
    ///   - 结束: 区间终点（含当天）
    ///   - 方格尺寸: 方格边长，默认 `12`
    ///   - 间距: 方格间距，默认 `3`
    ///   - 圆角: 方格圆角，默认 `2`
    ///   - 色阶: 色阶数组（由浅到深），默认四档
    ///   - 空格颜色: 无数据方格颜色，默认浅灰
    ///   - 日历: 使用的日历，默认 `.current`
    ///   - 显示月份: 是否显示月份标签，默认 `true`
    ///   - 点击: 点击方格回调，参数为该天零点
    init(数值: [Date: Double],
         起始: Date,
         结束: Date,
         方格尺寸: CGFloat = 12,
         间距: CGFloat = 3,
         圆角: CGFloat = 2,
         色阶: [Color] = HeatmapCalendar.defaultColors,
         空格颜色: Color = Color.secondary.opacity(0.15),
         日历: Calendar = .current,
         显示月份: Bool = true,
         点击: ((Date) -> Void)? = nil) {
        self.init(values: 数值,
                  startDate: 起始,
                  endDate: 结束,
                  cellSize: 方格尺寸,
                  spacing: 间距,
                  cornerRadius: 圆角,
                  colors: 色阶,
                  emptyColor: 空格颜色,
                  calendar: 日历,
                  showsMonthLabels: 显示月份,
                  onSelect: 点击)
    }

    /// 级别映射（等同 `levels(values:levelCount:calendar:)`）
    static func 级别(数值: [Date: Double],
                    级别数: Int = 4,
                    日历: Calendar = .current) -> [Date: Int] {
        levels(values: 数值, levelCount: 级别数, calendar: 日历)
    }

    /// 按周切列（等同 `weekColumns(from:to:calendar:)`）
    static func 周列(起始: Date, 结束: Date, 日历: Calendar = .current) -> [[Date?]] {
        weekColumns(from: 起始, to: 结束, calendar: 日历)
    }
}
