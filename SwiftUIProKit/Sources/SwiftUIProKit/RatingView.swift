import SwiftUI

// MARK: - 评分视图

/// 评分视图：星级评分
///
/// 支持三种用法：只读展示、`Binding` 双向可交互、闭包回调可交互。
/// 可交互时点击第 N 颗星即把评分设为 N 分；支持半星（0.25 ~ 0.75 显示半颗）。
///
/// - Example:
///   ```swift
///   @State private var score = 4.5
///   RatingView(rating: $score)          // 可交互
///   RatingView(rating: 3.0)             // 只读展示
///   ```
public struct RatingView: View {

    /// 当前评分
    private let rating: Double
    /// 满分星数
    private let maximum: Int
    /// 星星字号
    private let starSize: CGFloat
    /// 已点亮星的颜色
    private let activeColor: Color
    /// 未点亮星的颜色
    private let inactiveColor: Color
    /// 评分变化回调（`nil` 表示只读）
    private let onRatingChange: ((Double) -> Void)?

    /// 只读评分展示
    /// - Parameters:
    ///   - rating: 当前评分
    ///   - maximum: 满分星数，默认 `5`
    ///   - starSize: 星星字号，默认 `22`
    ///   - activeColor: 已点亮星颜色，默认 `.yellow`
    ///   - inactiveColor: 未点亮星颜色，默认 `Color.gray.opacity(0.35)`
    public init(rating: Double,
                maximum: Int = 5,
                starSize: CGFloat = 22,
                activeColor: Color = .yellow,
                inactiveColor: Color = Color.gray.opacity(0.35)) {
        self.rating = rating
        self.maximum = maximum
        self.starSize = starSize
        self.activeColor = activeColor
        self.inactiveColor = inactiveColor
        self.onRatingChange = nil
    }

    /// 可交互评分（`Binding` 双向绑定）
    /// - Parameters:
    ///   - rating: 评分绑定值，点击星即回写
    ///   - maximum: 满分星数，默认 `5`
    ///   - starSize: 星星字号，默认 `22`
    ///   - activeColor: 已点亮星颜色，默认 `.yellow`
    ///   - inactiveColor: 未点亮星颜色，默认 `Color.gray.opacity(0.35)`
    public init(rating: Binding<Double>,
                maximum: Int = 5,
                starSize: CGFloat = 22,
                activeColor: Color = .yellow,
                inactiveColor: Color = Color.gray.opacity(0.35)) {
        self.rating = rating.wrappedValue
        self.maximum = maximum
        self.starSize = starSize
        self.activeColor = activeColor
        self.inactiveColor = inactiveColor
        self.onRatingChange = { rating.wrappedValue = $0 }
    }

    /// 可交互评分（闭包回调）
    /// - Parameters:
    ///   - rating: 当前评分
    ///   - maximum: 满分星数，默认 `5`
    ///   - starSize: 星星字号，默认 `22`
    ///   - activeColor: 已点亮星颜色，默认 `.yellow`
    ///   - inactiveColor: 未点亮星颜色，默认 `Color.gray.opacity(0.35)`
    ///   - onRatingChange: 点击星后回调新评分
    public init(rating: Double,
                maximum: Int = 5,
                starSize: CGFloat = 22,
                activeColor: Color = .yellow,
                inactiveColor: Color = Color.gray.opacity(0.35),
                onRatingChange: @escaping (Double) -> Void) {
        self.rating = rating
        self.maximum = maximum
        self.starSize = starSize
        self.activeColor = activeColor
        self.inactiveColor = inactiveColor
        self.onRatingChange = onRatingChange
    }

    public var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<maximum, id: \.self) { index in
                starView(position: index)
            }
        }
    }

    /// 单颗星的视图（可交互时包一层 Button）
    private func starView(position: Int) -> some View {
        let content = Group {
            if let symbol = overlaySymbol(position: position) {
                Image(systemName: "star")
                    .font(.system(size: starSize))
                    .foregroundStyle(inactiveColor)
                    .overlay(
                        Image(systemName: symbol)
                            .font(.system(size: starSize))
                            .foregroundStyle(activeColor)
                    )
            } else {
                Image(systemName: "star")
                    .font(.system(size: starSize))
                    .foregroundStyle(inactiveColor)
            }
        }
        return Group {
            if onRatingChange != nil {
                Button {
                    onRatingChange?(Double(position + 1))
                } label: {
                    content
                }
                .buttonStyle(.plain)
            } else {
                content
            }
        }
    }

    /// 根据评分算出该位置应叠加的实心符号（全星 / 半星 / 无）
    private func overlaySymbol(position: Int) -> String? {
        let value = rating - Double(position)
        if value >= 0.75 { return "star.fill" }
        if value >= 0.25 { return "star.leadinghalf.fill" }
        return nil
    }
}

// MARK: 中文命名别名

/// 中文名：评分视图（等同 `RatingView`）
public typealias 评分视图 = RatingView

public extension RatingView {
    /// 只读评分展示（中文参数）
    /// - Parameters:
    ///   - 评分: 当前评分
    ///   - 最大: 满分星数，默认 `5`
    ///   - 星大小: 星星字号，默认 `22`
    ///   - 激活色: 已点亮星颜色，默认 `.yellow`
    ///   - 未激活色: 未点亮星颜色，默认 `Color.gray.opacity(0.35)`
    init(评分: Double, 最大: Int = 5, 星大小: CGFloat = 22,
         激活色: Color = .yellow, 未激活色: Color = Color.gray.opacity(0.35)) {
        self.init(rating: 评分, maximum: 最大, starSize: 星大小,
                  activeColor: 激活色, inactiveColor: 未激活色)
    }

    /// 可交互评分（`Binding`，中文参数）
    /// - Parameters:
    ///   - 评分: 评分绑定值，点击星即回写
    ///   - 最大: 满分星数，默认 `5`
    ///   - 星大小: 星星字号，默认 `22`
    ///   - 激活色: 已点亮星颜色，默认 `.yellow`
    ///   - 未激活色: 未点亮星颜色，默认 `Color.gray.opacity(0.35)`
    init(评分: Binding<Double>, 最大: Int = 5, 星大小: CGFloat = 22,
         激活色: Color = .yellow, 未激活色: Color = Color.gray.opacity(0.35)) {
        self.init(rating: 评分, maximum: 最大, starSize: 星大小,
                  activeColor: 激活色, inactiveColor: 未激活色)
    }
}
