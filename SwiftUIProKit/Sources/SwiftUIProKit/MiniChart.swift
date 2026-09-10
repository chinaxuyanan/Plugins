import SwiftUI

// MARK: - 迷你折线图

/// 迷你折线图（Sparkline）
///
/// 一条没有坐标轴、没有刻度的折线，用来在列表行、卡片角落快速示意「趋势」。
/// 数值按自身的最小 / 最大值归一化铺满整个高度——空数组不画线，
/// 只有一个值或所有值相同时按中线处理，不会出现除零或线条跳顶。
///
/// - Example:
///   ```swift
///   Sparkline(values: [3, 7, 4, 9, 6, 11])
///   Sparkline(values: prices, tint: .green, height: 32, showsArea: false)
///   ```
public struct Sparkline: View {

    /// 数值序列（按先后顺序）
    private let values: [Double]
    /// 线条颜色
    private let tint: Color
    /// 线宽
    private let lineWidth: CGFloat
    /// 高度
    private let height: CGFloat
    /// 是否在折线下方填充渐变
    private let showsArea: Bool
    /// 是否在每个数据点上画小圆点
    private let showsDots: Bool

    /// - Parameters:
    ///   - values: 数值序列（按先后顺序）
    ///   - tint: 线条颜色，默认 `.accentColor`
    ///   - lineWidth: 线宽，默认 `2`
    ///   - height: 高度，默认 `40`
    ///   - showsArea: 是否在折线下方填充渐变，默认 `true`
    ///   - showsDots: 是否在每个数据点上画小圆点，默认 `false`
    public init(values: [Double],
                tint: Color = .accentColor,
                lineWidth: CGFloat = 2,
                height: CGFloat = 40,
                showsArea: Bool = true,
                showsDots: Bool = false) {
        self.values = values
        self.tint = tint
        self.lineWidth = lineWidth
        self.height = height
        self.showsArea = showsArea
        self.showsDots = showsDots
    }

    public var body: some View {
        GeometryReader { geo in
            ZStack {
                if showsArea {
                    areaPath(in: geo.size)
                        .fill(LinearGradient(colors: [tint.opacity(0.28), tint.opacity(0.02)],
                                             startPoint: .top, endPoint: .bottom))
                }
                linePath(in: geo.size)
                    .stroke(tint, style: StrokeStyle(lineWidth: lineWidth,
                                                     lineCap: .round,
                                                     lineJoin: .round))
                if showsDots {
                    ForEach(Array(points(in: geo.size).enumerated()), id: \.offset) { _, point in
                        Circle()
                            .fill(tint)
                            .frame(width: lineWidth * 1.6, height: lineWidth * 1.6)
                            .position(point)
                    }
                }
            }
        }
        .frame(height: height)
    }

    // MARK: 几何

    /// 归一化后各数据点在画布上的坐标
    private func points(in size: CGSize) -> [CGPoint] {
        let ratios = Self.normalizedRatios(values)
        guard !ratios.isEmpty else { return [] }

        let inset = lineWidth / 2
        let usableHeight = max(0, size.height - lineWidth)
        // 只有一个点时居中，其余情况首尾贴边等分
        let stepX = ratios.count > 1 ? (size.width - lineWidth) / CGFloat(ratios.count - 1) : 0
        let startX = ratios.count > 1 ? inset : size.width / 2

        return ratios.enumerated().map { index, ratio in
            let x = startX + CGFloat(index) * stepX
            let y = inset + (1 - CGFloat(ratio)) * usableHeight
            return CGPoint(x: x, y: y)
        }
    }

    private func linePath(in size: CGSize) -> Path {
        var path = Path()
        let pts = points(in: size)
        guard let first = pts.first else { return path }
        path.move(to: first)
        for point in pts.dropFirst() { path.addLine(to: point) }
        return path
    }

    private func areaPath(in size: CGSize) -> Path {
        var path = linePath(in: size)
        let pts = points(in: size)
        guard let first = pts.first, let last = pts.last else { return path }
        path.addLine(to: CGPoint(x: last.x, y: size.height))
        path.addLine(to: CGPoint(x: first.x, y: size.height))
        path.closeSubpath()
        return path
    }

    // MARK: 归一化

    /// 把数值序列映射到 `0...1`
    ///
    /// - 空数组返回空数组；
    /// - 只有一个值、或所有值相同 → 全部返回 `0.5`（画在中线，避免除零）；
    /// - 其余情况按 `(值 - 最小值) / (最大值 - 最小值)` 计算。
    static func normalizedRatios(_ values: [Double]) -> [Double] {
        guard !values.isEmpty else { return [] }
        guard let minValue = values.min(), let maxValue = values.max(),
              maxValue > minValue else {
            return Array(repeating: 0.5, count: values.count)
        }
        let span = maxValue - minValue
        return values.map { ($0 - minValue) / span }
    }
}

// MARK: - 迷你柱状图

/// 迷你柱状图
///
/// 一排等宽柱子，高度按「相对最大值」的比例计算，最大值可高亮。
/// 空数组不显示；最大值不大于 `0` 时所有柱子给一个最小高度，避免整排消失。
///
/// - Example:
///   ```swift
///   MiniBarChart(values: [3, 7, 4, 9, 6, 11])
///   MiniBarChart(values: hourlyCounts, tint: .orange, height: 48, highlightsMax: false)
///   ```
public struct MiniBarChart: View {

    /// 数值序列（按先后顺序）
    private let values: [Double]
    /// 柱子颜色
    private let tint: Color
    /// 高度
    private let height: CGFloat
    /// 柱间距
    private let spacing: CGFloat
    /// 圆角半径
    private let cornerRadius: CGFloat
    /// 是否把最大值那根柱子高亮
    private let highlightsMax: Bool

    /// - Parameters:
    ///   - values: 数值序列（按先后顺序）
    ///   - tint: 柱子颜色，默认 `.accentColor`
    ///   - height: 高度，默认 `60`
    ///   - spacing: 柱间距，默认 `6`
    ///   - cornerRadius: 圆角半径，默认 `3`
    ///   - highlightsMax: 是否把最大值那根柱子高亮，默认 `true`
    public init(values: [Double],
                tint: Color = .accentColor,
                height: CGFloat = 60,
                spacing: CGFloat = 6,
                cornerRadius: CGFloat = 3,
                highlightsMax: Bool = true) {
        self.values = values
        self.tint = tint
        self.height = height
        self.spacing = spacing
        self.cornerRadius = cornerRadius
        self.highlightsMax = highlightsMax
    }

    public var body: some View {
        let ratios = Self.barRatios(values)
        HStack(alignment: .bottom, spacing: spacing) {
            ForEach(Array(values.enumerated()), id: \.offset) { index, value in
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(isHighlighted(index: index, value: value) ? tint : tint.opacity(0.45))
                    .frame(maxWidth: .infinity)
                    .frame(height: barHeight(ratio: ratios[index]))
            }
        }
        .frame(height: height, alignment: .bottom)
    }

    /// 柱高：比例 × 总高度，最矮 `2`（保证极小值也可见）
    private func barHeight(ratio: Double) -> CGFloat {
        max(2, CGFloat(ratio) * height)
    }

    private func isHighlighted(index: Int, value: Double) -> Bool {
        guard highlightsMax, let maxValue = values.max(), maxValue > 0 else { return false }
        // 只高亮第一根达到最大值的柱子，并列最大值时不会全部高亮
        return value == maxValue && values.firstIndex(of: maxValue) == index
    }

    /// 按「值 / 最大值」把数值序列映射到 `0...1`
    ///
    /// - 空数组返回空数组；
    /// - 最大值为 `0` 或负数 → 全部返回 `0`（调用方兜底最小高度）；
    /// - 负数按 `0` 处理，不让柱子反向。
    static func barRatios(_ values: [Double]) -> [Double] {
        guard !values.isEmpty else { return [] }
        guard let maxValue = values.max(), maxValue > 0 else {
            return Array(repeating: 0, count: values.count)
        }
        return values.map { max(0, min(1, $0 / maxValue)) }
    }
}

// MARK: 中文命名别名

/// 中文名：迷你折线图（等同 `Sparkline`）
public typealias 迷你折线图 = Sparkline

/// 中文名：迷你柱状图（等同 `MiniBarChart`）
public typealias 迷你柱状图 = MiniBarChart

public extension Sparkline {

    /// 迷你折线图（中文参数）
    /// - Parameters:
    ///   - 数值: 数值序列（按先后顺序）
    ///   - 颜色: 线条颜色，默认 `.accentColor`
    ///   - 线宽: 线宽，默认 `2`
    ///   - 高度: 高度，默认 `40`
    ///   - 显示面积: 是否在折线下方填充渐变，默认 `true`
    ///   - 显示数据点: 是否在每个数据点上画小圆点，默认 `false`
    init(数值: [Double],
         颜色: Color = .accentColor,
         线宽: CGFloat = 2,
         高度: CGFloat = 40,
         显示面积: Bool = true,
         显示数据点: Bool = false) {
        self.init(values: 数值,
                  tint: 颜色,
                  lineWidth: 线宽,
                  height: 高度,
                  showsArea: 显示面积,
                  showsDots: 显示数据点)
    }
}

public extension MiniBarChart {

    /// 迷你柱状图（中文参数）
    /// - Parameters:
    ///   - 数值: 数值序列（按先后顺序）
    ///   - 颜色: 柱子颜色，默认 `.accentColor`
    ///   - 高度: 高度，默认 `60`
    ///   - 柱间距: 柱间距，默认 `6`
    ///   - 圆角: 圆角半径，默认 `3`
    ///   - 高亮最大值: 是否把最大值那根柱子高亮，默认 `true`
    init(数值: [Double],
         颜色: Color = .accentColor,
         高度: CGFloat = 60,
         柱间距: CGFloat = 6,
         圆角: CGFloat = 3,
         高亮最大值: Bool = true) {
        self.init(values: 数值,
                  tint: 颜色,
                  height: 高度,
                  spacing: 柱间距,
                  cornerRadius: 圆角,
                  highlightsMax: 高亮最大值)
    }
}
