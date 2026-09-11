import SwiftUI

// MARK: - 图表数据系列

/// 图表里的一条数据系列（折线图 / 柱状图共用）
///
/// 一条系列 = 一个名字 + 一串按先后顺序排列的数值 + 一个颜色。
/// 单系列时名字可以不填；多系列时名字用于图例。
public struct ChartSeries {

    /// 系列名称（图例里显示；留空则显示「系列 N」）
    public let label: String
    /// 数值序列（按先后顺序）
    public let values: [Double]
    /// 该系列的颜色
    public let color: Color

    /// 创建一条数据系列
    /// - Parameters:
    ///   - label: 系列名称
    ///   - values: 数值序列（按先后顺序）
    ///   - color: 颜色，默认 `.accentColor`
    public init(label: String, values: [Double], color: Color = .accentColor) {
        self.label = label
        self.values = values
        self.color = color
    }
}

// MARK: - 图表坐标轴（纯逻辑）

/// 图表坐标轴的取值范围 / 刻度 / 映射计算（折线图 / 柱状图共用）
///
/// 这里的方法都是**纯函数**，不依赖任何视图状态，可以直接单元测试。
public enum ChartAxis {

    /// 把一组数值扩展成「带留白」的取值范围
    ///
    /// 上下各留 `paddingRatio`（相对数据跨度）的余量，避免折线顶端 / 柱子顶端正好顶到边框。
    /// 空数组（或全不是有限数）返回 `0...1`；取值全部相同（跨度为 `0`）时在中值上下各撑开一点。
    ///
    /// - Parameters:
    ///   - values: 数值序列
    ///   - paddingRatio: 上下留白占数据跨度的比例，默认 `0.05`
    public static func paddedRange(_ values: [Double], paddingRatio: Double = 0.05) -> ClosedRange<Double> {
        let finite = values.filter { $0.isFinite }
        guard let lower = finite.min(), let upper = finite.max() else { return 0...1 }
        guard upper > lower else {
            // 跨度为零：围绕这个唯一值上下撑开，绝对值本身也参与，避免「全是 0」时撑不开
            let pad = max(0.5, abs(lower) * paddingRatio)
            return (lower - pad)...(upper + pad)
        }
        let pad = (upper - lower) * paddingRatio
        return (lower - pad)...(upper + pad)
    }

    /// 合成多条系列后的取值范围（把所有系列的数值摊平再算）
    /// - Parameters:
    ///   - series: 多条数据系列
    ///   - paddingRatio: 上下留白比例，默认 `0.05`
    public static func paddedRange(_ series: [ChartSeries], paddingRatio: Double = 0.05) -> ClosedRange<Double> {
        paddedRange(series.flatMap { $0.values }, paddingRatio: paddingRatio)
    }

    /// 在取值范围内等分生成刻度值（含首尾两端，共 `count + 1` 个）
    ///
    /// `count` 小于 `1` 时按 `1` 处理；范围跨度为 `0` 时只返回下限一个值。
    ///
    /// - Parameters:
    ///   - range: 取值范围
    ///   - count: 分段数，默认 `4`（即 5 个刻度）
    public static func ticks(in range: ClosedRange<Double>, count: Int = 4) -> [Double] {
        let steps = max(1, count)
        let lower = range.lowerBound
        let upper = range.upperBound
        guard upper > lower else { return [lower] }
        let span = upper - lower
        return (0...steps).map { index in
            lower + span * Double(index) / Double(steps)
        }
    }

    /// 把数值映射到 `0...1`（相对给定范围）
    ///
    /// 超出范围的会被夹到 `0` / `1`，所以调用方不用再做钳制；
    /// 范围跨度为 `0` 时全部返回 `0.5`（画在中线）。
    ///
    /// - Parameters:
    ///   - values: 数值序列
    ///   - range: 取值范围
    public static func ratios(_ values: [Double], in range: ClosedRange<Double>) -> [Double] {
        let lower = range.lowerBound
        let span = range.upperBound - lower
        guard span > 0 else { return values.map { _ in 0.5 } }
        return values.map { value in
            let ratio = (value - lower) / span
            return min(1, max(0, ratio))
        }
    }

    /// X 轴标签抽稀：`count` 个位置里最多挑 `maxLabels` 个显示，返回要显示的下标
    ///
    /// 尽量带上首尾；`maxLabels` 不小于 `count` 时全部显示；`maxLabels` 为 `1` 时只显示第一个。
    ///
    /// - Parameters:
    ///   - count: 标签总个数
    ///   - maxLabels: 最多显示几个
    public static func labelIndexes(count: Int, maxLabels: Int) -> [Int] {
        guard count > 0, maxLabels > 0 else { return [] }
        guard maxLabels < count else { return Array(0..<count) }
        if maxLabels == 1 { return [0] }
        let step = Double(count - 1) / Double(maxLabels - 1)
        var result: [Int] = []
        for index in 0..<maxLabels {
            let raw = (Double(index) * step).rounded()
            let position = min(count - 1, max(0, Int(raw)))
            // 四舍五入后可能连续两个落在同一格，去重避免重复画
            if result.last != position { result.append(position) }
        }
        return result
    }

    /// 刻度文字：整数值不带小数点，非整数保留一位小数，可加单位后缀
    /// - Parameters:
    ///   - value: 刻度值
    ///   - suffix: 单位后缀（如 `"%"`），默认空
    public static func label(_ value: Double, suffix: String = "") -> String {
        guard value.isFinite else { return "—" + suffix }
        let text: String
        if value == value.rounded() && abs(value) < 1e15 {
            text = String(Int(value))
        } else {
            text = String(format: "%.1f", value)
        }
        return text + suffix
    }
}

// MARK: - 折线图

/// 折线图（带坐标轴 / 网格 / 图例）
///
/// 与迷你折线图 `Sparkline`（没有坐标轴、只表示趋势）不同，本组件是**正式图表**：
/// 带 Y 轴刻度文字、横向网格线、可选 X 轴标签与多系列图例。
///
/// 多条系列时共用一个取值范围（所有系列的数值一起算），所以不同系列的高低可以直接对比；
/// 传入空数组不画线，只留下坐标轴与网格。
///
/// - Example:
///   ```swift
///   LineChart(values: [3, 7, 4, 9, 6, 11], labels: ["一", "二", "三", "四", "五", "六"])
///
///   LineChart(series: [
///       .init(label: "本周", values: [3, 7, 4, 9], color: .blue),
///       .init(label: "上周", values: [5, 6, 6, 7], color: .orange)
///   ], height: 200, ySuffix: "次")
///   ```
/// 中文名 `折线图` 与 `LineChart` 等价。
public struct LineChart: View {

    /// 各条数据系列
    private let series: [ChartSeries]
    /// 绘图区高度
    private let height: CGFloat
    /// 线宽
    private let lineWidth: CGFloat
    /// 是否在折线下方填渐变
    private let showsArea: Bool
    /// 是否在数据点上画圆点
    private let showsDots: Bool
    /// 是否画网格线
    private let showsGrid: Bool
    /// Y 轴分段数（刻度数为它加一）
    private let tickCount: Int
    /// X 轴标签（与数据点一一对应；留空则不画 X 轴）
    private let xLabels: [String]
    /// X 轴最多显示几个标签（多了自动抽稀）
    private let maxXLabels: Int
    /// 是否显示 Y 轴刻度文字
    private let showsYLabels: Bool
    /// 是否显示图例（多系列时才有意义）
    private let showsLegend: Bool
    /// Y 轴刻度单位后缀
    private let ySuffix: String

    /// Y 轴文字列宽（左边留给刻度文字）
    private var gutter: CGFloat { showsYLabels ? 38 : 0 }

    /// 用多条系列创建折线图
    /// - Parameters:
    ///   - series: 各条数据系列
    ///   - height: 绘图区高度，默认 `180`
    ///   - lineWidth: 线宽，默认 `2`
    ///   - showsArea: 是否在折线下方填渐变，默认 `true`（多系列时建议关掉）
    ///   - showsDots: 是否在数据点上画圆点，默认 `true`
    ///   - showsGrid: 是否画网格线，默认 `true`
    ///   - tickCount: Y 轴分段数，默认 `4`
    ///   - xLabels: X 轴标签，默认空
    ///   - maxXLabels: X 轴最多显示几个标签，默认 `6`
    ///   - showsYLabels: 是否显示 Y 轴刻度文字，默认 `true`
    ///   - showsLegend: 是否显示图例，默认 `true`
    ///   - ySuffix: Y 轴刻度单位后缀，默认空
    public init(series: [ChartSeries],
                height: CGFloat = 180,
                lineWidth: CGFloat = 2,
                showsArea: Bool = true,
                showsDots: Bool = true,
                showsGrid: Bool = true,
                tickCount: Int = 4,
                xLabels: [String] = [],
                maxXLabels: Int = 6,
                showsYLabels: Bool = true,
                showsLegend: Bool = true,
                ySuffix: String = "") {
        self.series = series
        self.height = height
        self.lineWidth = lineWidth
        self.showsArea = showsArea
        self.showsDots = showsDots
        self.showsGrid = showsGrid
        self.tickCount = tickCount
        self.xLabels = xLabels
        self.maxXLabels = maxXLabels
        self.showsYLabels = showsYLabels
        self.showsLegend = showsLegend
        self.ySuffix = ySuffix
    }

    /// 用单条数值序列创建折线图
    /// - Parameters:
    ///   - values: 数值序列（按先后顺序）
    ///   - labels: X 轴标签，默认空
    ///   - color: 折线颜色，默认 `.accentColor`
    ///   - height: 绘图区高度，默认 `180`
    ///   - lineWidth: 线宽，默认 `2`
    ///   - showsArea: 是否在折线下方填渐变，默认 `true`
    ///   - showsDots: 是否在数据点上画圆点，默认 `true`
    ///   - showsGrid: 是否画网格线，默认 `true`
    ///   - tickCount: Y 轴分段数，默认 `4`
    ///   - maxXLabels: X 轴最多显示几个标签，默认 `6`
    ///   - showsYLabels: 是否显示 Y 轴刻度文字，默认 `true`
    ///   - ySuffix: Y 轴刻度单位后缀，默认空
    public init(values: [Double],
                labels: [String] = [],
                color: Color = .accentColor,
                height: CGFloat = 180,
                lineWidth: CGFloat = 2,
                showsArea: Bool = true,
                showsDots: Bool = true,
                showsGrid: Bool = true,
                tickCount: Int = 4,
                maxXLabels: Int = 6,
                showsYLabels: Bool = true,
                ySuffix: String = "") {
        self.init(series: [ChartSeries(label: "", values: values, color: color)],
                  height: height,
                  lineWidth: lineWidth,
                  showsArea: showsArea,
                  showsDots: showsDots,
                  showsGrid: showsGrid,
                  tickCount: tickCount,
                  xLabels: labels,
                  maxXLabels: maxXLabels,
                  showsYLabels: showsYLabels,
                  showsLegend: false,
                  ySuffix: ySuffix)
    }

    // MARK: 视图

    public var body: some View {
        let range = ChartAxis.paddedRange(series)
        let ticks = ChartAxis.ticks(in: range, count: tickCount)
        VStack(alignment: .leading, spacing: 4) {
            chartArea(range: range, ticks: ticks)
                .frame(height: height)
            if !xLabels.isEmpty {
                xAxisRow(range: range)
            }
            if showsLegend && series.count > 1 {
                legendRow
            }
        }
    }

    private func chartArea(range: ClosedRange<Double>, ticks: [Double]) -> some View {
        GeometryReader { geo in
            let rect = plotRect(in: geo.size)
            ZStack(alignment: .topLeading) {
                if showsGrid {
                    gridPath(ticks: ticks, range: range, in: rect)
                        .stroke(Color.secondary.opacity(0.18), lineWidth: 1)
                }
                ForEach(Array(series.enumerated()), id: \.offset) { _, item in
                    if showsArea && series.count == 1 {
                        areaPath(values: item.values, range: range, in: rect)
                            .fill(LinearGradient(colors: [item.color.opacity(0.25),
                                                          item.color.opacity(0.02)],
                                                 startPoint: .top, endPoint: .bottom))
                    }
                    linePath(values: item.values, range: range, in: rect)
                        .stroke(item.color,
                                style: StrokeStyle(lineWidth: lineWidth,
                                                   lineCap: .round,
                                                   lineJoin: .round))
                    if showsDots {
                        ForEach(Array(points(values: item.values, range: range, in: rect).enumerated()),
                                id: \.offset) { _, point in
                            Circle()
                                .fill(item.color)
                                .frame(width: lineWidth * 1.8, height: lineWidth * 1.8)
                                .position(point)
                        }
                    }
                }
                if showsYLabels {
                    yAxisLabels(ticks: ticks, range: range, in: rect, canvas: geo.size)
                }
            }
        }
    }

    private func xAxisRow(range: ClosedRange<Double>) -> some View {
        GeometryReader { geo in
            let rect = plotRect(in: geo.size)
            let maxCount = max(series.map { $0.values.count }.max() ?? 0, xLabels.count)
            let indexes = ChartAxis.labelIndexes(count: xLabels.count, maxLabels: maxXLabels)
            ZStack(alignment: .topLeading) {
                ForEach(indexes, id: \.self) { index in
                    Text(xLabels[index])
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .fixedSize()
                        .position(x: pointX(index: index, count: maxCount, in: rect),
                                  y: geo.size.height / 2)
                }
            }
        }
        .frame(height: 14)
    }

    private func yAxisLabels(ticks: [Double],
                             range: ClosedRange<Double>,
                             in rect: CGRect,
                             canvas: CGSize) -> some View {
        let width = max(0, gutter - 8)
        return ForEach(Array(ticks.enumerated()), id: \.offset) { _, value in
            Text(ChartAxis.label(value, suffix: ySuffix))
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(width: width, alignment: .trailing)
                .position(x: width / 2,
                          y: clampY(yFor(value: value, range: range, in: rect), canvas: canvas))
        }
    }

    private var legendRow: some View {
        HStack(spacing: 14) {
            ForEach(Array(series.enumerated()), id: \.offset) { index, item in
                HStack(spacing: 5) {
                    Circle()
                        .fill(item.color)
                        .frame(width: 8, height: 8)
                    Text(legendLabel(item, at: index))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func legendLabel(_ item: ChartSeries, at index: Int) -> String {
        item.label.isEmpty ? "系列 \(index + 1)" : item.label
    }

    // MARK: 几何

    /// 绘图区矩形（左边留出 Y 轴文字的位置，其余方向留线宽的一半避免描边被切）
    private func plotRect(in size: CGSize) -> CGRect {
        let inset = lineWidth / 2
        let width = max(1, size.width - gutter - inset)
        let height = max(1, size.height - lineWidth)
        return CGRect(x: gutter, y: inset, width: width, height: height)
    }

    /// 第 `index` 个数据点的 X 坐标
    private func pointX(index: Int, count: Int, in rect: CGRect) -> CGFloat {
        guard count > 1 else { return rect.midX }
        let step = rect.width / CGFloat(count - 1)
        return rect.minX + CGFloat(index) * step
    }

    /// 某个值对应的 Y 坐标
    private func yFor(value: Double, range: ClosedRange<Double>, in rect: CGRect) -> CGFloat {
        let ratio = ChartAxis.ratios([value], in: range).first ?? 0
        return rect.maxY - CGFloat(ratio) * rect.height
    }

    /// 把 Y 坐标夹在画布内，避免首尾刻度文字被切掉
    private func clampY(_ y: CGFloat, canvas: CGSize) -> CGFloat {
        min(max(y, 7), max(7, canvas.height - 7))
    }

    /// 各数据点的坐标
    private func points(values: [Double], range: ClosedRange<Double>, in rect: CGRect) -> [CGPoint] {
        let ratios = ChartAxis.ratios(values, in: range)
        return ratios.enumerated().map { index, ratio in
            CGPoint(x: pointX(index: index, count: ratios.count, in: rect),
                    y: rect.maxY - CGFloat(ratio) * rect.height)
        }
    }

    private func linePath(values: [Double], range: ClosedRange<Double>, in rect: CGRect) -> Path {
        var path = Path()
        let pts = points(values: values, range: range, in: rect)
        guard let first = pts.first else { return path }
        path.move(to: first)
        for point in pts.dropFirst() { path.addLine(to: point) }
        return path
    }

    private func areaPath(values: [Double], range: ClosedRange<Double>, in rect: CGRect) -> Path {
        var path = linePath(values: values, range: range, in: rect)
        let pts = points(values: values, range: range, in: rect)
        guard let first = pts.first, let last = pts.last else { return path }
        path.addLine(to: CGPoint(x: last.x, y: rect.maxY))
        path.addLine(to: CGPoint(x: first.x, y: rect.maxY))
        path.closeSubpath()
        return path
    }

    /// 横向网格线（对应每个刻度）
    private func gridPath(ticks: [Double], range: ClosedRange<Double>, in rect: CGRect) -> Path {
        var path = Path()
        for value in ticks {
            let y = clampY(yFor(value: value, range: range, in: rect), canvas: rect.size)
            path.move(to: CGPoint(x: rect.minX, y: y))
            path.addLine(to: CGPoint(x: rect.maxX, y: y))
        }
        return path
    }
}

// MARK: - 柱状图

/// 柱状图（带坐标轴 / 网格 / 图例）
///
/// 每个 X 位置一组柱子，多系列时组内并排；基线固定在 `0`（有的值为负时会画出向下的柱子）。
/// Y 轴刻度、网格线与 X 轴标签的规则与 `LineChart` 一致。
///
/// - Example:
///   ```swift
///   BarChart(values: [3, 7, 4, 9, 6, 11], labels: ["一", "二", "三", "四", "五", "六"])
///
///   BarChart(series: [
///       .init(label: "线上", values: [12, 8, 15], color: .blue),
///       .init(label: "线下", values: [6, 10, 4], color: .orange)
///   ], labels: ["一月", "二月", "三月"], height: 200)
///   ```
/// 中文名 `柱状图` 与 `BarChart` 等价。
public struct BarChart: View {

    /// 各条数据系列
    private let series: [ChartSeries]
    /// 绘图区高度
    private let height: CGFloat
    /// 柱子间距（组内与组间都用它）
    private let spacing: CGFloat
    /// 柱子圆角
    private let cornerRadius: CGFloat
    /// 是否画网格线
    private let showsGrid: Bool
    /// Y 轴分段数
    private let tickCount: Int
    /// X 轴标签
    private let labels: [String]
    /// X 轴最多显示几个标签
    private let maxXLabels: Int
    /// 是否显示 Y 轴刻度文字
    private let showsYLabels: Bool
    /// 是否显示图例
    private let showsLegend: Bool
    /// 是否把每组里最大的那根柱子高亮（其余降透明度）
    private let highlightsMax: Bool
    /// Y 轴刻度单位后缀
    private let ySuffix: String

    /// Y 轴文字列宽
    private var gutter: CGFloat { showsYLabels ? 38 : 0 }

    /// 用多条系列创建柱状图
    /// - Parameters:
    ///   - series: 各条数据系列
    ///   - labels: X 轴标签，默认空
    ///   - height: 绘图区高度，默认 `180`
    ///   - spacing: 柱子间距，默认 `6`
    ///   - cornerRadius: 柱子圆角，默认 `3`
    ///   - showsGrid: 是否画网格线，默认 `true`
    ///   - tickCount: Y 轴分段数，默认 `4`
    ///   - maxXLabels: X 轴最多显示几个标签，默认 `6`
    ///   - showsYLabels: 是否显示 Y 轴刻度文字，默认 `true`
    ///   - showsLegend: 是否显示图例，默认 `true`
    ///   - highlightsMax: 是否高亮每组最大值，默认 `false`
    ///   - ySuffix: Y 轴刻度单位后缀，默认空
    public init(series: [ChartSeries],
                labels: [String] = [],
                height: CGFloat = 180,
                spacing: CGFloat = 6,
                cornerRadius: CGFloat = 3,
                showsGrid: Bool = true,
                tickCount: Int = 4,
                maxXLabels: Int = 6,
                showsYLabels: Bool = true,
                showsLegend: Bool = true,
                highlightsMax: Bool = false,
                ySuffix: String = "") {
        self.series = series
        self.labels = labels
        self.height = height
        self.spacing = spacing
        self.cornerRadius = cornerRadius
        self.showsGrid = showsGrid
        self.tickCount = tickCount
        self.maxXLabels = maxXLabels
        self.showsYLabels = showsYLabels
        self.showsLegend = showsLegend
        self.highlightsMax = highlightsMax
        self.ySuffix = ySuffix
    }

    /// 用单条数值序列创建柱状图
    /// - Parameters:
    ///   - values: 数值序列（按先后顺序）
    ///   - labels: X 轴标签，默认空
    ///   - color: 柱子颜色，默认 `.accentColor`
    ///   - height: 绘图区高度，默认 `180`
    ///   - spacing: 柱子间距，默认 `6`
    ///   - cornerRadius: 柱子圆角，默认 `3`
    ///   - showsGrid: 是否画网格线，默认 `true`
    ///   - tickCount: Y 轴分段数，默认 `4`
    ///   - maxXLabels: X 轴最多显示几个标签，默认 `6`
    ///   - showsYLabels: 是否显示 Y 轴刻度文字，默认 `true`
    ///   - highlightsMax: 是否高亮最大值，默认 `true`
    ///   - ySuffix: Y 轴刻度单位后缀，默认空
    public init(values: [Double],
                labels: [String] = [],
                color: Color = .accentColor,
                height: CGFloat = 180,
                spacing: CGFloat = 6,
                cornerRadius: CGFloat = 3,
                showsGrid: Bool = true,
                tickCount: Int = 4,
                maxXLabels: Int = 6,
                showsYLabels: Bool = true,
                highlightsMax: Bool = true,
                ySuffix: String = "") {
        self.init(series: [ChartSeries(label: "", values: values, color: color)],
                  labels: labels,
                  height: height,
                  spacing: spacing,
                  cornerRadius: cornerRadius,
                  showsGrid: showsGrid,
                  tickCount: tickCount,
                  maxXLabels: maxXLabels,
                  showsYLabels: showsYLabels,
                  showsLegend: false,
                  highlightsMax: highlightsMax,
                  ySuffix: ySuffix)
    }

    // MARK: 纯逻辑

    /// 单根柱子的宽度
    ///
    /// - 一组里并排 `barCount` 根柱子，两端与柱间各留 `spacing`；
    /// - 结果不会小于 `1`，避免柱子窄到看不见。
    ///
    /// - Parameters:
    ///   - groupWidth: 一组（一个 X 位置）可分到的宽度
    ///   - spacing: 柱子间距
    ///   - barCount: 组内柱子根数
    public static func barWidth(groupWidth: CGFloat,
                                spacing: CGFloat,
                                barCount: Int) -> CGFloat {
        guard barCount > 0 else { return 0 }
        let gaps = CGFloat(barCount + 1)
        let usable = groupWidth - gaps * spacing
        return max(1, usable / CGFloat(barCount))
    }

    // MARK: 视图

    public var body: some View {
        let range = barRange
        let ticks = ChartAxis.ticks(in: range, count: tickCount)
        VStack(alignment: .leading, spacing: 4) {
            chartArea(range: range, ticks: ticks)
                .frame(height: height)
            if !labels.isEmpty {
                xAxisRow(range: range)
            }
            if showsLegend && series.count > 1 {
                legendRow
            }
        }
    }

    /// 柱状图的取值范围：基线固定在 `0`，有负值时向下延伸
    private var barRange: ClosedRange<Double> {
        let all = series.flatMap { $0.values }.filter { $0.isFinite }
        let upper = max(0, all.max() ?? 0)
        let lower = min(0, all.min() ?? 0)
        guard upper > lower else { return 0...1 }
        return lower...upper
    }

    /// 每个 X 位置的数据点个数（取最长的一条系列）
    private var slotCount: Int {
        series.map { $0.values.count }.max() ?? 0
    }

    private func chartArea(range: ClosedRange<Double>, ticks: [Double]) -> some View {
        GeometryReader { geo in
            let rect = plotRect(in: geo.size)
            ZStack(alignment: .topLeading) {
                if showsGrid {
                    gridPath(ticks: ticks, range: range, in: rect)
                        .stroke(Color.secondary.opacity(0.18), lineWidth: 1)
                }
                bars(range: range, in: rect)
                if showsYLabels {
                    yAxisLabels(ticks: ticks, range: range, in: rect, canvas: geo.size)
                }
            }
        }
    }

    private func bars(range: ClosedRange<Double>, in rect: CGRect) -> some View {
        let count = slotCount
        let groupWidth = count > 0 ? rect.width / CGFloat(count) : rect.width
        let width = Self.barWidth(groupWidth: groupWidth, spacing: spacing, barCount: series.count)
        let baselineY = yFor(value: 0, range: range, in: rect)
        return ForEach(Array(series.enumerated()), id: \.offset) { seriesIndex, item in
            ForEach(Array(item.values.enumerated()), id: \.offset) { valueIndex, value in
                let topY = yFor(value: value, range: range, in: rect)
                let barTop = min(topY, baselineY)
                let barHeight = max(1, abs(baselineY - topY))
                let groupLeft = rect.minX + groupWidth * CGFloat(valueIndex)
                let x = groupLeft + spacing + CGFloat(seriesIndex) * (width + spacing)
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(barColor(item: item, seriesIndex: seriesIndex, valueIndex: valueIndex, value: value))
                    .frame(width: width, height: barHeight)
                    .position(x: x + width / 2, y: barTop + barHeight / 2)
            }
        }
    }

    private func barColor(item: ChartSeries,
                          seriesIndex: Int,
                          valueIndex: Int,
                          value: Double) -> Color {
        guard highlightsMax else { return item.color }
        let maxValue = item.values.max() ?? 0
        let firstMaxIndex = item.values.firstIndex(of: maxValue)
        return value == maxValue && valueIndex == firstMaxIndex ? item.color : item.color.opacity(0.45)
    }

    private func xAxisRow(range: ClosedRange<Double>) -> some View {
        GeometryReader { geo in
            let rect = plotRect(in: geo.size)
            let count = slotCount
            let groupWidth = count > 0 ? rect.width / CGFloat(count) : rect.width
            let indexes = ChartAxis.labelIndexes(count: labels.count, maxLabels: maxXLabels)
            ZStack(alignment: .topLeading) {
                ForEach(indexes, id: \.self) { index in
                    Text(labels[index])
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .fixedSize()
                        .position(x: rect.minX + groupWidth * (CGFloat(index) + 0.5),
                                  y: geo.size.height / 2)
                }
            }
        }
        .frame(height: 14)
    }

    private func yAxisLabels(ticks: [Double],
                             range: ClosedRange<Double>,
                             in rect: CGRect,
                             canvas: CGSize) -> some View {
        let width = max(0, gutter - 8)
        return ForEach(Array(ticks.enumerated()), id: \.offset) { _, value in
            Text(ChartAxis.label(value, suffix: ySuffix))
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .frame(width: width, alignment: .trailing)
                .position(x: width / 2,
                          y: min(max(yFor(value: value, range: range, in: rect), 7),
                                 max(7, canvas.height - 7)))
        }
    }

    private var legendRow: some View {
        HStack(spacing: 14) {
            ForEach(Array(series.enumerated()), id: \.offset) { index, item in
                HStack(spacing: 5) {
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(item.color)
                        .frame(width: 10, height: 10)
                    Text(item.label.isEmpty ? "系列 \(index + 1)" : item.label)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    // MARK: 几何

    private func plotRect(in size: CGSize) -> CGRect {
        let inset: CGFloat = 0.5
        let width = max(1, size.width - gutter - inset)
        let height = max(1, size.height - 1)
        return CGRect(x: gutter, y: inset, width: width, height: height)
    }

    private func yFor(value: Double, range: ClosedRange<Double>, in rect: CGRect) -> CGFloat {
        let ratio = ChartAxis.ratios([value], in: range).first ?? 0
        return rect.maxY - CGFloat(ratio) * rect.height
    }

    private func gridPath(ticks: [Double], range: ClosedRange<Double>, in rect: CGRect) -> Path {
        var path = Path()
        for value in ticks {
            let y = min(max(yFor(value: value, range: range, in: rect), 0.5), rect.maxY)
            path.move(to: CGPoint(x: rect.minX, y: y))
            path.addLine(to: CGPoint(x: rect.maxX, y: y))
        }
        return path
    }
}

// MARK: 中文命名别名

/// 中文名：图表数据系列（等同 `ChartSeries`）
public typealias 图表数据系列 = ChartSeries

/// 中文名：图表坐标轴（等同 `ChartAxis`）
public typealias 图表坐标轴 = ChartAxis

/// 中文名：折线图（等同 `LineChart`）
public typealias 折线图 = LineChart

/// 中文名：柱状图（等同 `BarChart`）
public typealias 柱状图 = BarChart

public extension ChartSeries {

    /// 一条数据系列（中文参数）
    /// - Parameters:
    ///   - 名称: 系列名称
    ///   - 数值: 数值序列
    ///   - 颜色: 颜色，默认 `.accentColor`
    init(名称: String, 数值: [Double], 颜色: Color = .accentColor) {
        self.init(label: 名称, values: 数值, color: 颜色)
    }

    /// 系列名称（等同 `label`）
    var 名称: String { label }
    /// 数值序列（等同 `values`）
    var 数值: [Double] { values }
    /// 颜色（等同 `color`）
    var 颜色: Color { color }
}

public extension ChartAxis {

    /// 数据范围加留白（等同 `paddedRange(_:paddingRatio:)`）
    static func 留白范围(_ 数值: [Double], 留白比例: Double = 0.05) -> ClosedRange<Double> {
        paddedRange(数值, paddingRatio: 留白比例)
    }

    /// 多条系列的数据范围加留白（等同 `paddedRange(_:paddingRatio:)`）
    static func 留白范围(_ 系列: [ChartSeries], 留白比例: Double = 0.05) -> ClosedRange<Double> {
        paddedRange(系列, paddingRatio: 留白比例)
    }

    /// 等分刻度值（等同 `ticks(in:count:)`）
    static func 刻度(in 范围: ClosedRange<Double>, 段数: Int = 4) -> [Double] {
        ticks(in: 范围, count: 段数)
    }

    /// 数值映射到 0~1 并夹紧（等同 `ratios(_:in:)`）
    static func 比例(_ 数值: [Double], 范围: ClosedRange<Double>) -> [Double] {
        ratios(数值, in: 范围)
    }

    /// X 轴标签抽稀下标（等同 `labelIndexes(count:maxLabels:)`）
    static func 标签下标(总数: Int, 最多: Int) -> [Int] {
        labelIndexes(count: 总数, maxLabels: 最多)
    }

    /// 刻度文字（等同 `label(_:suffix:)`）
    static func 刻度文字(_ 数值: Double, 单位: String = "") -> String {
        label(数值, suffix: 单位)
    }
}

public extension LineChart {

    /// 折线图（中文参数，多条系列）
    ///
    /// 首参 `系列` 无默认值，与 `init(数值:…)` 凭标签区分，不会歧义。
    init(系列: [ChartSeries],
         高度: CGFloat = 180,
         线宽: CGFloat = 2,
         显示面积: Bool = true,
         显示数据点: Bool = true,
         显示网格: Bool = true,
         分段数: Int = 4,
         横轴标签: [String] = [],
         最多横轴标签: Int = 6,
         显示纵轴文字: Bool = true,
         显示图例: Bool = true,
         纵轴单位: String = "") {
        self.init(series: 系列, height: 高度, lineWidth: 线宽,
                  showsArea: 显示面积, showsDots: 显示数据点, showsGrid: 显示网格,
                  tickCount: 分段数, xLabels: 横轴标签, maxXLabels: 最多横轴标签,
                  showsYLabels: 显示纵轴文字, showsLegend: 显示图例, ySuffix: 纵轴单位)
    }

    /// 折线图（中文参数，单条数值序列）
    init(数值: [Double],
         横轴标签: [String] = [],
         颜色: Color = .accentColor,
         高度: CGFloat = 180,
         线宽: CGFloat = 2,
         显示面积: Bool = true,
         显示数据点: Bool = true,
         显示网格: Bool = true,
         分段数: Int = 4,
         最多横轴标签: Int = 6,
         显示纵轴文字: Bool = true,
         纵轴单位: String = "") {
        self.init(values: 数值, labels: 横轴标签, color: 颜色, height: 高度, lineWidth: 线宽,
                  showsArea: 显示面积, showsDots: 显示数据点, showsGrid: 显示网格,
                  tickCount: 分段数, maxXLabels: 最多横轴标签,
                  showsYLabels: 显示纵轴文字, ySuffix: 纵轴单位)
    }
}

public extension BarChart {

    /// 柱状图（中文参数，多条系列）
    init(系列: [ChartSeries],
         横轴标签: [String] = [],
         高度: CGFloat = 180,
         柱间距: CGFloat = 6,
         圆角: CGFloat = 3,
         显示网格: Bool = true,
         分段数: Int = 4,
         最多横轴标签: Int = 6,
         显示纵轴文字: Bool = true,
         显示图例: Bool = true,
         高亮最大值: Bool = false,
         纵轴单位: String = "") {
        self.init(series: 系列, labels: 横轴标签, height: 高度, spacing: 柱间距,
                  cornerRadius: 圆角, showsGrid: 显示网格, tickCount: 分段数,
                  maxXLabels: 最多横轴标签, showsYLabels: 显示纵轴文字,
                  showsLegend: 显示图例, highlightsMax: 高亮最大值, ySuffix: 纵轴单位)
    }

    /// 柱状图（中文参数，单条数值序列）
    init(数值: [Double],
         横轴标签: [String] = [],
         颜色: Color = .accentColor,
         高度: CGFloat = 180,
         柱间距: CGFloat = 6,
         圆角: CGFloat = 3,
         显示网格: Bool = true,
         分段数: Int = 4,
         最多横轴标签: Int = 6,
         显示纵轴文字: Bool = true,
         高亮最大值: Bool = true,
         纵轴单位: String = "") {
        self.init(values: 数值, labels: 横轴标签, color: 颜色, height: 高度, spacing: 柱间距,
                  cornerRadius: 圆角, showsGrid: 显示网格, tickCount: 分段数,
                  maxXLabels: 最多横轴标签, showsYLabels: 显示纵轴文字,
                  highlightsMax: 高亮最大值, ySuffix: 纵轴单位)
    }

    /// 单根柱子宽度（等同 `barWidth(groupWidth:spacing:barCount:)`）
    static func 柱宽(组宽: CGFloat, 柱间距: CGFloat, 柱数: Int) -> CGFloat {
        barWidth(groupWidth: 组宽, spacing: 柱间距, barCount: 柱数)
    }
}
