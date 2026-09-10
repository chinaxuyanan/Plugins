import SwiftUI

// MARK: - 文字渐变

public extension View {

    /// 文字渐变
    ///
    /// 给任意视图（通常是 `Text` 或 SF Symbol 图标）套上一层线性渐变色。
    /// 实现原理是「渐变叠加 + 以原视图为蒙版」，因此对文字、图标、形状都有效。
    ///
    /// - Parameters:
    ///   - colors: 渐变颜色数组（至少两个颜色）
    ///   - startPoint: 渐变起点，默认 `.leading`
    ///   - endPoint: 渐变终点，默认 `.trailing`
    ///
    /// - Example:
    ///   ```swift
    ///   Text("渐变标题").font(.largeTitle).bold()
    ///       .textGradient([.blue, .purple])
    ///   ```
    @ViewBuilder
    func textGradient(_ colors: [Color],
                      startPoint: UnitPoint = .leading,
                      endPoint: UnitPoint = .trailing) -> some View {
        self.overlay(
            LinearGradient(gradient: Gradient(colors: colors),
                           startPoint: startPoint, endPoint: endPoint)
        )
        .mask(self)
    }
}
