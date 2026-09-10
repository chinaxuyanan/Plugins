import SwiftUI

// MARK: - 渐变描边
//
// 用渐变色给视图镶边（实线 / 虚线）。与 `overlayBorder`（单色描边）、`dashedBorder`（单色虚线）互补。

public extension View {

    /// 渐变描边
    ///
    /// 在视图四周叠加一圈线性渐变描边，比单色描边更有质感。
    ///
    /// - Parameters:
    ///   - colors: 渐变颜色数组（至少 1 个）
    ///   - lineWidth: 线宽，默认 `1`
    ///   - cornerRadius: 圆角半径，默认 `0`（直角）
    ///   - startPoint: 渐变起点，默认 `.topLeading`
    ///   - endPoint: 渐变终点，默认 `.bottomTrailing`
    ///
    /// - Example:
    ///   ```swift
    ///   CardView()
    ///       .gradientBorder([.purple, .blue], lineWidth: 2, cornerRadius: 12)
    ///   ```
    @ViewBuilder
    func gradientBorder(_ colors: [Color],
                        lineWidth: CGFloat = 1,
                        cornerRadius: CGFloat = 0,
                        startPoint: UnitPoint = .topLeading,
                        endPoint: UnitPoint = .bottomTrailing) -> some View {
        overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(LinearGradient(gradient: Gradient(colors: colors),
                                       startPoint: startPoint,
                                       endPoint: endPoint),
                        lineWidth: lineWidth)
        )
    }

    /// 虚线渐变描边
    ///
    /// 与 `gradientBorder` 相同，只是改为虚线。常用于「待定 / 待拖入」等占位区域。
    ///
    /// - Parameters:
    ///   - colors: 渐变颜色数组
    ///   - lineWidth: 线宽，默认 `1`
    ///   - dash: 虚线段长，默认 `6`
    ///   - gap: 虚线间隔，默认 `4`
    ///   - cornerRadius: 圆角半径，默认 `0`
    ///   - startPoint: 渐变起点，默认 `.topLeading`
    ///   - endPoint: 渐变终点，默认 `.bottomTrailing`
    ///
    /// - Example:
    ///   ```swift
    ///   placeholder.gradientDashedBorder([.gray, .blue], cornerRadius: 12)
    ///   ```
    @ViewBuilder
    func gradientDashedBorder(_ colors: [Color],
                              lineWidth: CGFloat = 1,
                              dash: CGFloat = 6,
                              gap: CGFloat = 4,
                              cornerRadius: CGFloat = 0,
                              startPoint: UnitPoint = .topLeading,
                              endPoint: UnitPoint = .bottomTrailing) -> some View {
        overlay(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(LinearGradient(gradient: Gradient(colors: colors),
                                       startPoint: startPoint,
                                       endPoint: endPoint),
                        style: StrokeStyle(lineWidth: lineWidth, dash: [dash, gap]))
        )
    }
}

// MARK: 中文命名别名
//
// 渐变描边 / 虚线渐变描边 的中文别名统一放在 `View+ChineseAlias.swift`。
