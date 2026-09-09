import SwiftUI

// MARK: - 背景、圆角、边框、阴影

public extension View {

    /// 设置视图的背景颜色
    ///
    /// 在视图下层铺一层指定颜色作为背景。
    ///
    /// - Parameter color: 背景颜色。
    ///
    /// - Example:
    ///   ```swift
    ///   Text("标签")
    ///       .backgroundColor(.orange)
    ///   ```
    @ViewBuilder
    func backgroundColor(_ color: Color) -> some View {
        background(color)
    }

    /// 设置视图的线性渐变背景
    ///
    /// 使用两个或更多颜色做线性渐变作为背景。
    ///
    /// - Parameters:
    ///   - colors: 渐变颜色数组，至少两个颜色。
    ///   - startPoint: 渐变起点，默认 `.topLeading`（左上）。
    ///   - endPoint: 渐变终点，默认 `.bottomTrailing`（右下）。
    ///
    /// - Example:
    ///   ```swift
    ///   RoundedRectangle(cornerRadius: 12)
    ///       .backgroundGradient([.blue, .purple])
    ///   ```
    @ViewBuilder
    func backgroundGradient(_ colors: [Color],
                            startPoint: UnitPoint = .topLeading,
                            endPoint: UnitPoint = .bottomTrailing) -> some View {
        background(LinearGradient(gradient: Gradient(colors: colors), startPoint: startPoint, endPoint: endPoint))
    }

    /// 圆角裁剪
    ///
    /// 将视图内容裁剪为指定圆角半径的圆角矩形（连续曲率）。
    ///
    /// - Parameter radius: 圆角半径（单位：pt），值越大边角越圆润。
    ///
    /// - Example:
    ///   ```swift
    ///   Image("avatar")
    ///       .clippedToRoundedRect(12)
    ///   ```
    @ViewBuilder
    func clippedToRoundedRect(_ radius: CGFloat) -> some View {
        clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }

    /// 圆角描边
    ///
    /// 沿视图边缘绘制一圈指定颜色、宽度的圆角边框。
    /// 相比系统 `border`，本方法使用 overlay + stroke 实现，能保持圆角不被拉伸变形。
    ///
    /// - Parameters:
    ///   - color: 边框颜色。
    ///   - width: 边框线宽（单位：pt）。
    ///   - cornerRadius: 圆角半径（单位：pt），默认 `0` 表示直角。
    ///
    /// - Example:
    ///   ```swift
    ///   Image("avatar")
    ///       .overlayBorder(color: .gray, width: 1, cornerRadius: 12)
    ///   ```
    @ViewBuilder
    func overlayBorder(color: Color, width: CGFloat = 1, cornerRadius: CGFloat = 0) -> some View {
        overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(color, lineWidth: width)
        )
    }

    /// 轻量阴影
    ///
    /// 应用一层较小的阴影，适合卡片、按钮等需要轻微浮起感的元素。
    ///
    /// - Example:
    ///   ```swift
    ///   card.shadowSm()
    ///   ```
    @ViewBuilder
    func shadowSm() -> some View {
        shadow(color: .black.opacity(0.06), radius: 4, x: 0, y: 2)
    }

    /// 中等阴影
    ///
    /// 应用一层中等强度的阴影，适合悬浮的卡片、弹窗等。
    ///
    /// - Example:
    ///   ```swift
    ///   card.shadowMd()
    ///   ```
    @ViewBuilder
    func shadowMd() -> some View {
        shadow(color: .black.opacity(0.10), radius: 8, x: 0, y: 4)
    }

    /// 强阴影
    ///
    /// 应用一层较强的阴影，适合需要明显浮起、突出层级的元素。
    ///
    /// - Example:
    ///   ```swift
    ///   panel.shadowLg()
    ///   ```
    @ViewBuilder
    func shadowLg() -> some View {
        shadow(color: .black.opacity(0.15), radius: 16, x: 0, y: 8)
    }
}
