import SwiftUI

// MARK: - 日历选择器

/// 日历选择器：一个可点的月份网格，支持「选某一天」和「选一段区间」两种模式
///
/// 与 `HeatmapCalendar`（只看不点、按强度上色）不同，本组件是**可交互的日期选择器**：
/// 自带上月 / 下月切换、今天描边、可选范围限制（`minimumDate` / `maximumDate`）。
/// 系统自带的 `DatePicker(.graphical)` 只支持单选，选区间得靠本组件。
///
/// 两种用法（首参必须显式给，否则无法区分是选日期还是选区间）：
/// ```swift
/// @State private var date = Date()
/// @State private var range: ClosedRange<Date>?
///
/// CalendarPicker(selection: $date)              // 单选
/// CalendarPicker(range: $range)                 // 选区间（首次点选起点，再点选终点）
/// ```
/// 中文名 `日历选择器` 与 `CalendarPicker` 等价。
public struct CalendarPicker: View {

    /// 选择模式
    public enum Mode: Equatable {
        /// 选单独一天
        case single
        /// 选一段区间（首尾都含）
        case range
    }

    /// 选择模式
    private let mode: Mode
    /// 单选模式的日期绑定
    private let selection: Binding<Date>?
    /// 区间模式的区间绑定（未选完时为 `nil`）
    private let range: Binding<ClosedRange<Date>?>?
    /// 计算月份 / 星期用的日历
    private let calendar: Calendar
    /// 选中色
    private let tint: Color
    /// 最早可选日期（`nil` 表示不限）
    private let minimumDate: Date?
    /// 最晚可选日期（`nil` 表示不限）
    private let maximumDate: Date?

    /// 当前显示的月份（该月任意一天，内部会归一）
    @State private var visibleMonth: Date
    /// 区间模式下已经点了起点、等待点终点的那个起点
    @State private var rangeStart: Date? = nil

    /// 月份标题格式化器（固定中文，不受系统语言影响）
    private static let monthFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "zh_CN")
        f.dateFormat = "yyyy年M月"
        return f
    }()

    private static let chineseWeekdaySymbols = ["日", "一", "二", "三", "四", "五", "六"]

    /// 创建单选日历
    /// - Parameters:
    ///   - selection: 选中的日期（双向绑定）
    ///   - calendar: 使用的日历，默认 `.current`
    ///   - tint: 选中色，默认 `.accentColor`
    ///   - minimumDate: 最早可选日期，默认不限
    ///   - maximumDate: 最晚可选日期，默认不限
    public init(selection: Binding<Date>,
                calendar: Calendar = .current,
                tint: Color = .accentColor,
                minimumDate: Date? = nil,
                maximumDate: Date? = nil) {
        self.mode = .single
        self.selection = selection
        self.range = nil
        self.calendar = calendar
        self.tint = tint
        self.minimumDate = minimumDate
        self.maximumDate = maximumDate
        _visibleMonth = State(initialValue: Self.startOfMonth(for: selection.wrappedValue, calendar: calendar))
    }

    /// 创建区间日历
    ///
    /// 交互：第一次点某天记为起点（此时区间为 `nil`），第二次点另**一天**完成选择；
    /// 再点一次则重新开始。点到起点同一天会得到单日区间（首尾相同）。
    ///
    /// - Parameters:
    ///   - range: 选中的区间（双向绑定，未选完为 `nil`）
    ///   - calendar: 使用的日历，默认 `.current`
    ///   - tint: 选中色，默认 `.accentColor`
    ///   - minimumDate: 最早可选日期，默认不限
    ///   - maximumDate: 最晚可选日期，默认不限
    public init(range: Binding<ClosedRange<Date>?>,
                calendar: Calendar = .current,
                tint: Color = .accentColor,
                minimumDate: Date? = nil,
                maximumDate: Date? = nil) {
        self.mode = .range
        self.selection = nil
        self.range = range
        self.calendar = calendar
        self.tint = tint
        self.minimumDate = minimumDate
        self.maximumDate = maximumDate
        let anchor = range.wrappedValue?.lowerBound ?? Date()
        _visibleMonth = State(initialValue: Self.startOfMonth(for: anchor, calendar: calendar))
    }

    // MARK: - 纯逻辑（可单测）

    /// 某个月按周排布的日期矩阵（前后用 `nil` 补满整周，每周 7 个元素）
    ///
    /// 首行前面补几个 `nil` 由 `calendar.firstWeekday` 决定——所以周一是第一天（中国大陆常见）
    /// 还是周日是第一天，都跟着传入的日历走，不会写死。
    ///
    /// - Parameters:
    ///   - month: 目标月份里的任意一天
    ///   - calendar: 使用的日历，默认 `.current`
    /// - Returns: 平铺的日期数组，长度是 7 的整数倍；`nil` 表示空格
    public static func monthGrid(for month: Date, calendar: Calendar = .current) -> [Date?] {
        guard let interval = calendar.dateInterval(of: .month, for: month) else { return [] }
        let first = calendar.startOfDay(for: interval.start)
        let dayCount = calendar.range(of: .day, in: .month, for: first)?.count ?? 0
        // 1=周日…7=周六，换算成「相对本周第一天」的偏移
        let leading = (calendar.component(.weekday, from: first) - calendar.firstWeekday + 7) % 7

        var days: [Date?] = Array(repeating: nil, count: leading)
        for offset in 0..<dayCount {
            days.append(calendar.date(byAdding: .day, value: offset, to: first))
        }
        while days.count % 7 != 0 { days.append(nil) }
        return days
    }

    /// 两个日期是否是同一天（按传入日历判断，不看具体时刻）
    public static func isSameDay(_ lhs: Date, _ rhs: Date, calendar: Calendar = .current) -> Bool {
        calendar.isDate(lhs, inSameDayAs: rhs)
    }

    /// 星期表头符号（中文单字，按 `calendar.firstWeekday` 轮转）
    ///
    /// - Parameter calendar: 使用的日历，默认 `.current`
    /// - Returns: 7 个符号，顺序与 `monthGrid(for:calendar:)` 的列顺序一致
    public static func weekdaySymbols(calendar: Calendar = .current) -> [String] {
        let firstIndex = (calendar.firstWeekday - 1 + 7) % 7
        return (0..<7).map { chineseWeekdaySymbols[($0 + firstIndex) % 7] }
    }

    /// 月份标题（形如 `2026年9月`）
    public static func monthTitle(for month: Date) -> String {
        monthFormatter.string(from: month)
    }

    /// 在某个月上偏移若干个月，返回目标月的**第一天**
    public static func month(byAdding months: Int, to date: Date, calendar: Calendar = .current) -> Date {
        guard let shifted = calendar.date(byAdding: .month, value: months, to: date) else {
            return startOfMonth(for: date, calendar: calendar)
        }
        return startOfMonth(for: shifted, calendar: calendar)
    }

    /// 某个月第一天（零点）
    private static func startOfMonth(for date: Date, calendar: Calendar) -> Date {
        let start = calendar.dateInterval(of: .month, for: date)?.start ?? calendar.startOfDay(for: date)
        return calendar.startOfDay(for: start)
    }

    // MARK: - 视图

    public var body: some View {
        VStack(spacing: 10) {
            header
            weekdayRow
            daysGrid
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.secondary.opacity(0.06))
        )
    }

    /// 顶部：上月 / 月份标题 / 下月
    private var header: some View {
        HStack {
            navButton(systemName: "chevron.left", monthOffset: -1, label: "上个月")
            Spacer()
            Text(Self.monthTitle(for: visibleMonth))
                .font(.headline)
            Spacer()
            navButton(systemName: "chevron.right", monthOffset: 1, label: "下个月")
        }
    }

    private func navButton(systemName: String, monthOffset: Int, label: String) -> some View {
        Button {
            visibleMonth = Self.month(byAdding: monthOffset, to: visibleMonth, calendar: calendar)
        } label: {
            Image(systemName: systemName)
                .font(.callout.weight(.semibold))
                .frame(width: 28, height: 28)
        }
        .buttonStyle(.plain)
        .foregroundStyle(tint)
        .accessibilityLabel(label)
    }

    /// 星期表头（日 / 一 / 二 …）
    private var weekdayRow: some View {
        HStack(spacing: 4) {
            ForEach(Array(Self.weekdaySymbols(calendar: calendar).enumerated()), id: \.offset) { _, symbol in
                Text(symbol)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    /// 日期格子（每行 7 个）
    private var daysGrid: some View {
        let days = Self.monthGrid(for: visibleMonth, calendar: calendar)
        let rowCount = (days.count + 6) / 7
        return VStack(spacing: 4) {
            ForEach(0..<rowCount, id: \.self) { rowIndex in
                HStack(spacing: 4) {
                    ForEach(0..<7, id: \.self) { columnIndex in
                        dayCell(day(at: rowIndex * 7 + columnIndex, in: days))
                    }
                }
            }
        }
    }

    /// 越界时返回 `nil`，避免日历异常导致下标越界崩溃
    private func day(at index: Int, in days: [Date?]) -> Date? {
        index < days.count ? days[index] : nil
    }

    @ViewBuilder
    private func dayCell(_ day: Date?) -> some View {
        if let day = day {
            let selectable = isSelectable(day)
            Text("\(calendar.component(.day, from: day))")
                .font(.callout)
                .monospacedDigit()
                .foregroundStyle(foreground(day, selectable: selectable))
                .frame(maxWidth: .infinity, minHeight: 34)
                .background { highlight(day) }
                .contentShape(Rectangle())
                .onTapGesture { if selectable { select(day) } }
                .accessibilityLabel(Text(Self.monthFormatter.string(from: day) + "\(calendar.component(.day, from: day))日"))
                .accessibilityAddTraits(traits(for: day))
        } else {
            Color.clear.frame(maxWidth: .infinity, minHeight: 34)
        }
    }

    /// 日期背景：选中日 / 区间内 / 今天描边，三种高亮
    @ViewBuilder
    private func highlight(_ day: Date) -> some View {
        if isEndpoint(day) {
            Circle().fill(tint).frame(width: 32, height: 32)
        } else if isInRange(day) {
            Circle().fill(tint.opacity(0.18)).frame(width: 32, height: 32)
        } else if isToday(day) {
            Circle().strokeBorder(tint.opacity(0.6), lineWidth: 1.5).frame(width: 32, height: 32)
        } else {
            Color.clear.frame(width: 32, height: 32)
        }
    }

    // MARK: - 状态判断

    private func foreground(_ day: Date, selectable: Bool) -> Color {
        guard selectable else { return Color.secondary.opacity(0.35) }
        return isEndpoint(day) ? .white : .primary
    }

    /// 选中日的无障碍特征（拆出来写，避免在视图构建器里做 `?:` 类型推断）
    private func traits(for day: Date) -> AccessibilityTraits {
        isEndpoint(day) ? .isSelected : []
    }

    /// 是否在可选范围内
    private func isSelectable(_ day: Date) -> Bool {
        if let minimumDate, day < calendar.startOfDay(for: minimumDate) { return false }
        if let maximumDate, day > calendar.startOfDay(for: maximumDate) { return false }
        return true
    }

    /// 是否是「已选中」的那一天（单选）或区间端点（区间模式）
    private func isEndpoint(_ day: Date) -> Bool {
        switch mode {
        case .single:
            guard let value = selection?.wrappedValue else { return false }
            return Self.isSameDay(day, value, calendar: calendar)
        case .range:
            if let start = rangeStart, Self.isSameDay(day, start, calendar: calendar) { return true }
            guard let range = range?.wrappedValue else { return false }
            return Self.isSameDay(day, range.lowerBound, calendar: calendar)
                || Self.isSameDay(day, range.upperBound, calendar: calendar)
        }
    }

    /// 是否落在区间内部（不含首尾——首尾由 `isEndpoint` 高亮，避免样式打架）
    private func isInRange(_ day: Date) -> Bool {
        guard mode == .range, let range = range?.wrappedValue else { return false }
        let lower = calendar.startOfDay(for: range.lowerBound)
        let upper = calendar.startOfDay(for: range.upperBound)
        return day > lower && day < upper
    }

    private func isToday(_ day: Date) -> Bool {
        Self.isSameDay(day, Date(), calendar: calendar)
    }

    // MARK: - 交互

    private func select(_ day: Date) {
        switch mode {
        case .single:
            selection?.wrappedValue = day
        case .range:
            if let start = rangeStart {
                range?.wrappedValue = min(start, day)...max(start, day)
                rangeStart = nil
            } else {
                // 起点先记着，清空旧区间，等第二次点击再落定
                rangeStart = day
                range?.wrappedValue = nil
            }
        }
    }
}

// MARK: 中文命名别名

/// 中文名：日历选择器（等同 `CalendarPicker`）
public typealias 日历选择器 = CalendarPicker

/// 中文名：日历选择模式（等同 `CalendarPicker.Mode`）
public typealias 日历选择模式 = CalendarPicker.Mode

public extension CalendarPicker {

    /// 单选日历（中文参数）
    ///
    /// 首参 `选择` 无默认值，与另一个中文 `init(区间:…)` 凭标签区分，不会歧义。
    ///
    /// - Parameters:
    ///   - 选择: 选中的日期（双向绑定）
    ///   - 日历: 使用的日历，默认 `.current`
    ///   - 主题色: 选中色，默认 `.accentColor`
    ///   - 最早: 最早可选日期，默认不限
    ///   - 最晚: 最晚可选日期，默认不限
    init(选择: Binding<Date>,
         日历: Calendar = .current,
         主题色: Color = .accentColor,
         最早: Date? = nil,
         最晚: Date? = nil) {
        self.init(selection: 选择, calendar: 日历, tint: 主题色,
                  minimumDate: 最早, maximumDate: 最晚)
    }

    /// 区间日历（中文参数）
    /// - Parameters:
    ///   - 区间: 选中的区间（双向绑定，未选完为 `nil`）
    ///   - 日历: 使用的日历，默认 `.current`
    ///   - 主题色: 选中色，默认 `.accentColor`
    ///   - 最早: 最早可选日期，默认不限
    ///   - 最晚: 最晚可选日期，默认不限
    init(区间: Binding<ClosedRange<Date>?>,
         日历: Calendar = .current,
         主题色: Color = .accentColor,
         最早: Date? = nil,
         最晚: Date? = nil) {
        self.init(range: 区间, calendar: 日历, tint: 主题色,
                  minimumDate: 最早, maximumDate: 最晚)
    }

    /// 月份矩阵（等同 `monthGrid(for:calendar:)`）
    static func 月份矩阵(月份: Date, 日历: Calendar = .current) -> [Date?] {
        monthGrid(for: 月份, calendar: 日历)
    }

    /// 是否同一天（等同 `isSameDay(_:_:calendar:)`）
    static func 同一天(_ 甲: Date, _ 乙: Date, 日历: Calendar = .current) -> Bool {
        isSameDay(甲, 乙, calendar: 日历)
    }

    /// 星期表头（等同 `weekdaySymbols(calendar:)`）
    static func 星期表头(日历: Calendar = .current) -> [String] {
        weekdaySymbols(calendar: 日历)
    }
}
