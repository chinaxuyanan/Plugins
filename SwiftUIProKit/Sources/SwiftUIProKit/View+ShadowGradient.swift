import SwiftUI

// MARK: - 阴影与渐变
//
// 自定义阴影、发光效果、径向 / 角度渐变背景的语义化封装。

public extension View {

    /// 自定义阴影
    ///
    /// 等效于 `.shadow(color:radius:x:y:)`，比系统默认阴影更灵活。
    ///
    /// - Parameters:
    ///   - color: 阴影颜色
    ///   - radius: 模糊半径
    ///   - x: 水平偏移，默认 `0`
    ///   - y: 垂直偏移，默认 `0`
    ///
    /// - Example:
    ///   ```swift
    ///   card.customShadow(color: .black.opacity(0.2), radius: 10, y: 6)
    ///   ```
    @ViewBuilder
    func customShadow(color: Color, radius: CGFloat, x: CGFloat = 0, y: CGFloat = 0) -> some View {
        shadow(color: color, radius: radius, x: x, y: y)
    }

    /// 发光效果
    ///
    /// 零偏移的阴影，等效于 `.shadow(color:radius:)`，常用于高亮 / 外发光。
    ///
    /// - Parameters:
    ///   - color: 光晕颜色
    ///   - radius: 光晕范围
    ///
    /// - Example:
    ///   ```swift
    ///   Image(systemName: "star.fill").glow(color: .yellow, radius: 8)
    ///   ```
    @ViewBuilder
    func glow(color: Color, radius: CGFloat) -> some View {
        shadow(color: color, radius: radius)
    }

    /// 径向渐变背景
    ///
    /// 等效于 `.background(RadialGradient(...))`，从中心向外渐变。
    ///
    /// - Parameters:
    ///   - colors: 渐变颜色数组
    ///   - center: 渐变中心，默认 `.center`
    ///   - startRadius: 起始半径，默认 `0`
    ///   - endRadius: 结束半径，默认 `150`
    ///
    /// - Example:
    ///   ```swift
    ///   Circle().radialBackgroundGradient([.yellow, .orange])
    ///   ```
    @ViewBuilder
    func radialBackgroundGradient(_ colors: [Color],
                                  center: UnitPoint = .center,
                                  startRadius: CGFloat = 0,
                                  endRadius: CGFloat = 150) -> some View {
        background(RadialGradient(gradient: Gradient(colors: colors),
                                  center: center,
                                  startRadius: startRadius,
                                  endRadius: endRadius))
    }

    /// 角度渐变背景
    ///
    /// 等效于 `.background(AngularGradient(...))`，绕中心环形渐变。
    ///
    /// - Parameters:
    ///   - colors: 渐变颜色数组
    ///   - center: 渐变中心，默认 `.center`
    ///   - angle: 起始角度，默认 `0`
    ///
    /// - Example:
    ///   ```swift
    ///   Circle().angularBackgroundGradient([.red, .orange, .red])
    ///   ```
    @ViewBuilder
    func angularBackgroundGradient(_ colors: [Color],
                                   center: UnitPoint = .center,
                                   angle: Angle = .zero) -> some View {
        background(AngularGradient(gradient: Gradient(colors: colors),
                                   center: center,
                                   angle: angle))
    }
}
