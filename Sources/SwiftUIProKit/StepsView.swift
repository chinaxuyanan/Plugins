import SwiftUI

// MARK: - 步骤条

/// 步骤条方向
public enum StepsDirection {
    /// 横向（默认，适合「下单 → 支付 → 完成」这类短流程）
    case horizontal
    /// 纵向（适合步骤标题较长、或步骤较多的场景）
    case vertical
}

/// 中文名：步骤条方向（等同 `StepsDirection`）
public typealias 步骤条方向 = StepsDirection

/// 步骤条
///
/// 展示多步骤流程的当前进度：已完成的步骤打勾、当前步骤高亮、未到的步骤置灰，
/// 步骤之间用连接线串联，支持横向 / 纵向两种排布。
///
/// - Example:
///   ```swift
///   StepsView(steps: ["填信息", "选套餐", "付定金", "完成"], current: 1)
///   StepsView(steps: ["注册", "实名", "开卡"], current: 2, direction: .vertical)
///   ```
public struct StepsView: View {

    /// 步骤标题
    private let steps: [String]
    /// 当前步骤下标（从 `0` 开始）
    private let current: Int
    /// 已完成 / 当前步骤的颜色
    private let tint: Color
    /// 未完成步骤的颜色
    private let inactiveColor: Color
    /// 排布方向
    private let direction: StepsDirection
    /// 未完成步骤是否显示序号（`false` 时未完成步骤为空心圆）
    private let showsIndex: Bool
    /// 圆点直径
    private let circleSize: CGFloat

    /// - Parameters:
    ///   - steps: 步骤标题数组
    ///   - current: 当前步骤下标（从 `0` 开始），默认 `0`
    ///   - tint: 已完成 / 当前步骤的颜色，默认 `.accentColor`
    ///   - inactiveColor: 未完成步骤的颜色，默认 `.gray`
    ///   - direction: 排布方向，默认 `.horizontal`
    ///   - showsIndex: 未完成步骤是否显示序号，默认 `true`
    ///   - circleSize: 圆点直径，默认 `28`
    public init(steps: [String],
                current: Int = 0,
                tint: Color = .accentColor,
                inactiveColor: Color = .gray,
                direction: StepsDirection = .horizontal,
                showsIndex: Bool = true,
                circleSize: CGFloat = 28) {
        self.steps = steps
        self.current = current
        self.tint = tint
        self.inactiveColor = inactiveColor
        self.direction = direction
        self.showsIndex = showsIndex
        self.circleSize = circleSize
    }

    public var body: some View {
        switch direction {
        case .horizontal:
            horizontalBody
        case .vertical:
            verticalBody
        }
    }

    // MARK: 横向

    private var horizontalBody: some View {
        HStack(alignment: .top, spacing: 0) {
            ForEach(Array(steps.enumerated()), id: \.offset) { index, title in
                if index > 0 {
                    Rectangle()
                        .fill(index <= current ? tint : inactiveColor.opacity(0.25))
                        .frame(height: 2)
                        .frame(maxWidth: .infinity)
                        .padding(.top, circleSize / 2 - 1)
                }
                VStack(spacing: 6) {
                    circle(at: index)
                    Text(title)
                        .font(.caption)
                        .foregroundStyle(index <= current ? tint : inactiveColor)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(width: circleSize * 2.6)
            }
        }
    }

    // MARK: 纵向

    private var verticalBody: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(steps.enumerated()), id: \.offset) { index, title in
                HStack(alignment: .top, spacing: 12) {
                    VStack(spacing: 0) {
                        circle(at: index)
                        if index < steps.count - 1 {
                            Rectangle()
                                .fill(index < current ? tint : inactiveColor.opacity(0.25))
                                .frame(width: 2, height: 28)
                        }
                    }
                    Text(title)
                        .font(.subheadline)
                        .foregroundStyle(index <= current ? Color.primary : Color.secondary)
                        .frame(height: circleSize, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                }
            }
        }
    }

    // MARK: 圆点

    /// 第 `index` 个步骤的圆点：已完成打勾、当前高亮、未完成显示序号（或空心圆）
    private func circle(at index: Int) -> some View {
        let done = index < current
        let active = index == current
        return ZStack {
            Circle()
                .fill(done || active ? tint : inactiveColor.opacity(0.25))
            if done {
                Image(systemName: "checkmark")
                    .font(.system(size: circleSize * 0.42, weight: .bold))
                    .foregroundStyle(.white)
            } else if showsIndex {
                Text("\(index + 1)")
                    .font(.system(size: circleSize * 0.42, weight: .semibold, design: .rounded))
                    .foregroundStyle(active ? Color.white : Color.secondary)
            }
        }
        .frame(width: circleSize, height: circleSize)
    }
}

// MARK: 中文命名别名

/// 中文名：步骤条（等同 `StepsView`）
public typealias 步骤条 = StepsView

public extension StepsView {

    /// 步骤条（中文参数）
    /// - Parameters:
    ///   - 步骤: 步骤标题数组
    ///   - 当前: 当前步骤下标（从 `0` 开始），默认 `0`
    ///   - 颜色: 已完成 / 当前步骤的颜色，默认 `.accentColor`
    ///   - 未完成颜色: 未完成步骤的颜色，默认 `.gray`
    ///   - 方向: 排布方向，默认 `.horizontal`
    ///   - 显示序号: 未完成步骤是否显示序号，默认 `true`
    ///   - 圆点尺寸: 圆点直径，默认 `28`
    init(步骤: [String],
         当前: Int = 0,
         颜色: Color = .accentColor,
         未完成颜色: Color = .gray,
         方向: StepsDirection = .horizontal,
         显示序号: Bool = true,
         圆点尺寸: CGFloat = 28) {
        self.init(steps: 步骤,
                  current: 当前,
                  tint: 颜色,
                  inactiveColor: 未完成颜色,
                  direction: 方向,
                  showsIndex: 显示序号,
                  circleSize: 圆点尺寸)
    }
}
