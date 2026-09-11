import SwiftUI

// MARK: - 饼图 / 环形占比图

/// 饼图 / 环形占比图
///
/// 用扇形（或环形扇段）展示各部分占比，可选在右侧带一份图例（色块 + 名称 + 百分比）。
/// 与 `MiniChart`（折线 / 柱状，看趋势）不同，本组件看的是**构成比例**；
/// 与 `RingProgress`（单个圆环表示一个进度）也不同，本组件是**多段**汇总成一个整圆。
///
/// 数值会先按「各段之和」归一化：负值按 `0` 处理，总和为 `0`（或全为负）时不画任何扇形。
/// 只有一段时会被画成整圆（内部走椭圆分支，不会因为起止角相同而画空）。
///
/// - Example:
///   ```swift
///   PieChart(values: [40, 35, 25], labels: ["iOS", "Android", "其他"], isDonut: true)
///
///   PieChart(slices: [
///       .init(label: "已完成", value: 12, color: .green),
///       .init(label: "进行中", value: 5,  color: .orange)
///   ], centerText: "17")
///   ```
/// 中文名 `饼图` 与 `PieChart` 等价。
public struct PieChart: View {

    /// 饼图里的一段
    public struct Slice {
        /// 名称（图例里显示；留空则显示「第 N 项」）
        public let label: String
        /// 数值（会被归一化，负数按 `0` 处理）
        public let value: Double
        /// 该段的颜色
        public let color: Color

        /// 创建一段
        /// - Parameters:
        ///   - label: 名称
        ///   - value: 数值
        ///   - color: 颜色
        public init(label: String, value: Double, color: Color) {
            self.label = label
            self.value = value
            self.color = color
        }
    }

    /// 各段
    private let slices: [Slice]
    /// 绘图区直径
    private let size: CGFloat
    /// 是否画成环形（中间挖空）
    private let isDonut: Bool
    /// 挖空内径占外径的比例（仅环形时有意义，`0...1`）
    private let innerRatio: CGFloat
    /// 是否显示图例
    private let showsLegend: Bool
    /// 环形中心的文字（仅环形时显示，`nil` 表示不显示）
    private let centerText: String?
    /// 图例字体
    private let legendFont: Font

    /// 默认配色（六色，段数超出时会循环取用）
    public static var defaultColors: [Color] {
        [.blue, .green, .orange, .pink, .purple, .gray]
    }

    /// 直接用分片创建饼图
    /// - Parameters:
    ///   - slices: 各段
    ///   - size: 绘图区直径，默认 `160`
    ///   - isDonut: 是否画成环形，默认 `false`
    ///   - innerRatio: 挖空内径比例，默认 `0.55`（仅环形有效）
    ///   - showsLegend: 是否显示图例，默认 `true`
    ///   - centerText: 环形中心文字，默认 `nil`
    ///   - legendFont: 图例字体，默认 `.callout`
    public init(slices: [Slice],
                size: CGFloat = 160,
                isDonut: Bool = false,
                innerRatio: CGFloat = 0.55,
                showsLegend: Bool = true,
                centerText: String? = nil,
                legendFont: Font = .callout) {
        self.slices = slices
        self.size = size
        self.isDonut = isDonut
        self.innerRatio = innerRatio
        self.showsLegend = showsLegend
        self.centerText = centerText
        self.legendFont = legendFont
    }

    /// 用「数值 + 名称 + 配色」创建饼图
    ///
    /// 名称数量少于数值时，缺的名字留空（图例显示「第 N 项」）；配色不够时循环取用。
    ///
    /// - Parameters:
    ///   - values: 各段数值
    ///   - labels: 各段名称，默认空
    ///   - colors: 配色，默认 `PieChart.defaultColors`
    ///   - size: 绘图区直径，默认 `160`
    ///   - isDonut: 是否画成环形，默认 `false`
    ///   - innerRatio: 挖空内径比例，默认 `0.55`
    ///   - showsLegend: 是否显示图例，默认 `true`
    ///   - centerText: 环形中心文字，默认 `nil`
    ///   - legendFont: 图例字体，默认 `.callout`
    public init(values: [Double],
                labels: [String] = [],
                colors: [Color] = PieChart.defaultColors,
                size: CGFloat = 160,
                isDonut: Bool = false,
                innerRatio: CGFloat = 0.55,
                showsLegend: Bool = true,
                centerText: String? = nil,
                legendFont: Font = .callout) {
        let palette = colors.isEmpty ? PieChart.defaultColors : colors
        let built = values.enumerated().map { index, value in
            Slice(label: index < labels.count ? labels[index] : "",
                  value: value,
                  color: palette[index % palette.count])
        }
        self.init(slices: built,
                  size: size,
                  isDonut: isDonut,
                  innerRatio: innerRatio,
                  showsLegend: showsLegend,
                  centerText: centerText,
                  legendFont: legendFont)
    }

    // MARK: - 纯逻辑（可单测）

    /// 把数值序列归一化成占比（各项之和为 `1`）
    ///
    /// - 负数一律按 `0` 处理，不会出现「反向扇形」；
    /// - 总和为 `0`（含空数组、全部为 0 或负数）时返回等长的全 `0` 数组，调用方据此不画扇形。
    public static func ratios(_ values: [Double]) -> [Double] {
        let positives = values.map { max(0, $0) }
        let total = positives.reduce(0, +)
        guard total > 0 else { return Array(repeating: 0, count: values.count) }
        return positives.map { $0 / total }
    }

    /// 各段的起止角度（单位：度，`0` 表示 12 点方向，顺时针增大）
    ///
    /// 这是**与 SwiftUI 角度约定无关**的「表盘角度」：调用方画图时再减去 `90` 即可。
    /// 只有一段时返回 `(0, 360)`。
    public static func angleRanges(_ values: [Double]) -> [(start: Double, end: Double)] {
        var cursor = 0.0
        return ratios(values).map { ratio in
            let start = cursor
            cursor += ratio * 360
            return (start: start, end: cursor)
        }
    }

    // MARK: - 视图

    public var body: some View {
        HStack(spacing: 16) {
            chart
            if showsLegend && !slices.isEmpty {
                legend
            }
        }
    }

    private var chart: some View {
        let ranges = Self.angleRanges(slices.map(\.value))
        let hole = isDonut ? max(0, min(0.95, innerRatio)) : 0
        return ZStack {
            ForEach(Array(ranges.enumerated()), id: \.offset) { index, range in
                PieSliceShape(startAngle: .degrees(range.start - 90),
                              endAngle: .degrees(range.end - 90),
                              innerRatio: hole)
                    .fill(color(at: index), style: FillStyle(eoFill: true))
            }
            if let centerText, hole > 0 {
                Text(centerText)
                    .font(.headline)
                    .monospacedDigit()
                    .frame(width: size * hole)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(width: size, height: size)
    }

    private var legend: some View {
        let ratios = Self.ratios(slices.map(\.value))
        return VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(slices.enumerated()), id: \.offset) { index, slice in
                HStack(spacing: 6) {
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(slice.color)
                        .frame(width: 10, height: 10)
                    Text(displayLabel(slice, at: index))
                        .font(legendFont)
                    Spacer(minLength: 8)
                    Text(percentText(ratios[index]))
                        .font(legendFont)
                        .monospacedDigit()
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func color(at index: Int) -> Color {
        guard !slices.isEmpty else { return .clear }
        return slices[min(index, slices.count - 1)].color
    }

    private func displayLabel(_ slice: Slice, at index: Int) -> String {
        slice.label.isEmpty ? "第 \(index + 1) 项" : slice.label
    }

    private func percentText(_ ratio: Double) -> String {
        let percent = ratio * 100
        // 极小但非零的占比四舍五入后会变成 0%，这里改写成 <1%，避免看着像没数据
        if percent > 0, percent < 0.5 { return "<1%" }
        return String(format: "%.0f%%", percent)
    }
}

// MARK: - 扇形形状（内部实现）

/// 饼图的一段：`innerRatio` 为 `0` 时是实心扇形，大于 `0` 时是环形扇段
///
/// 起止角相同（整圈）时 `addArc` 什么都画不出来，所以整圈单独走椭圆分支；
/// 环形整圈则由外圆 + 内圆两个椭圆组成，靠调用方 `fill(style: FillStyle(eoFill: true))` 挖空。
private struct PieSliceShape: Shape {

    /// 起始角（SwiftUI 角度约定：`0` 在 3 点方向、顺时针增大）
    var startAngle: Angle
    /// 结束角
    var endAngle: Angle
    /// 内圈半径占外圈的比例，`0` 表示实心
    var innerRatio: CGFloat

    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * max(0, min(1, innerRatio))
        var path = Path()

        if endAngle.degrees - startAngle.degrees >= 360 - 0.01 {
            path.addEllipse(in: CGRect(x: center.x - outerRadius, y: center.y - outerRadius,
                                       width: outerRadius * 2, height: outerRadius * 2))
            if innerRadius > 0 {
                path.addEllipse(in: CGRect(x: center.x - innerRadius, y: center.y - innerRadius,
                                           width: innerRadius * 2, height: innerRadius * 2))
            }
            return path
        }

        path.addArc(center: center, radius: outerRadius,
                    startAngle: startAngle, endAngle: endAngle, clockwise: false)
        if innerRadius > 0 {
            path.addLine(to: point(on: innerRadius, at: endAngle, center: center))
            path.addArc(center: center, radius: innerRadius,
                        startAngle: endAngle, endAngle: startAngle, clockwise: true)
        } else {
            path.addLine(to: center)
        }
        path.closeSubpath()
        return path
    }

    private func point(on radius: CGFloat, at angle: Angle, center: CGPoint) -> CGPoint {
        CGPoint(x: center.x + radius * CGFloat(cos(angle.radians)),
                y: center.y + radius * CGFloat(sin(angle.radians)))
    }
}

// MARK: 中文命名别名

/// 中文名：饼图 / 环形占比图（等同 `PieChart`）
public typealias 饼图 = PieChart

/// 中文名：饼图分片（等同 `PieChart.Slice`）
public typealias 饼图分片 = PieChart.Slice

public extension PieChart.Slice {

    /// 一个分片（中文参数）
    /// - Parameters:
    ///   - 名称: 名称（图例里显示）
    ///   - 数值: 数值（会被归一化）
    ///   - 颜色: 颜色
    init(名称: String, 数值: Double, 颜色: Color) {
        self.init(label: 名称, value: 数值, color: 颜色)
    }

    /// 名称（等同 `label`）
    var 名称: String { label }
    /// 数值（等同 `value`）
    var 数值: Double { value }
    /// 颜色（等同 `color`）
    var 颜色: Color { color }
}

public extension PieChart {

    /// 饼图（中文参数，直接用分片）
    ///
    /// 首参 `分片` 无默认值，与 `init(数值:…)` 凭标签区分，不会歧义。
    ///
    /// - Parameters:
    ///   - 分片: 各段
    ///   - 尺寸: 绘图区直径，默认 `160`
    ///   - 环形: 是否画成环形，默认 `false`
    ///   - 内径比例: 挖空内径比例，默认 `0.55`
    ///   - 显示图例: 是否显示图例，默认 `true`
    ///   - 中心文字: 环形中心文字，默认 `nil`
    ///   - 图例字体: 图例字体，默认 `.callout`
    init(分片: [Slice],
         尺寸: CGFloat = 160,
         环形: Bool = false,
         内径比例: CGFloat = 0.55,
         显示图例: Bool = true,
         中心文字: String? = nil,
         图例字体: Font = .callout) {
        self.init(slices: 分片, size: 尺寸, isDonut: 环形, innerRatio: 内径比例,
                  showsLegend: 显示图例, centerText: 中心文字, legendFont: 图例字体)
    }

    /// 饼图（中文参数，用数值 + 名称）
    /// - Parameters:
    ///   - 数值: 各段数值
    ///   - 名称: 各段名称，默认空
    ///   - 颜色: 配色，默认六色循环
    ///   - 尺寸: 绘图区直径，默认 `160`
    ///   - 环形: 是否画成环形，默认 `false`
    ///   - 内径比例: 挖空内径比例，默认 `0.55`
    ///   - 显示图例: 是否显示图例，默认 `true`
    ///   - 中心文字: 环形中心文字，默认 `nil`
    ///   - 图例字体: 图例字体，默认 `.callout`
    init(数值: [Double],
         名称: [String] = [],
         颜色: [Color] = PieChart.defaultColors,
         尺寸: CGFloat = 160,
         环形: Bool = false,
         内径比例: CGFloat = 0.55,
         显示图例: Bool = true,
         中心文字: String? = nil,
         图例字体: Font = .callout) {
        self.init(values: 数值, labels: 名称, colors: 颜色, size: 尺寸,
                  isDonut: 环形, innerRatio: 内径比例,
                  showsLegend: 显示图例, centerText: 中心文字, legendFont: 图例字体)
    }

    /// 占比归一化（等同 `ratios(_:)`）
    static func 占比(_ 数值: [Double]) -> [Double] {
        ratios(数值)
    }

    /// 各段角度区间（等同 `angleRanges(_:)`）
    static func 角度区间(_ 数值: [Double]) -> [(start: Double, end: Double)] {
        angleRanges(数值)
    }
}
