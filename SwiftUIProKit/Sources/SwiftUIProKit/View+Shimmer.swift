import SwiftUI

// MARK: - 微光扫光效果

public extension View {

    /// 微光扫光效果
    ///
    /// 在视图表面叠加一道循环移动的高光，营造「内容加载 / 强调」的闪烁质感。
    /// 与骨架屏不同，本方法作用于任意视图本身（按钮、卡片、文字均可）。
    ///
    /// - Parameters:
    ///   - active: 是否播放扫光动画，默认 `true`
    ///   - tint: 高光颜色，默认白色半透明
    ///
    /// - Example:
    ///   ```swift
    ///   RoundedRectangle(cornerRadius: 8).fill(.gray)
    ///       .frame(width: 200, height: 40)
    ///       .shimmer()
    ///   ```
    func shimmer(active: Bool = true, tint: Color = .white.opacity(0.6)) -> some View {
        modifier(ShimmerModifier(active: active, tint: tint))
    }
}

/// 微光扫光实现
private struct ShimmerModifier: ViewModifier {

    let active: Bool
    let tint: Color

    /// 扫光相位：`false` 在左侧、`true` 在右侧，切换时驱动动画循环
    @State private var move = false

    func body(content: Content) -> some View {
        content.overlay(
            GeometryReader { geo in
                if active {
                    LinearGradient(
                        colors: [.clear, tint, .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geo.size.width * 0.7)
                    .offset(x: move ? geo.size.width : -geo.size.width)
                    .animation(.linear(duration: 1.4).repeatForever(autoreverses: false), value: move)
                    .onAppear { move = true }
                }
            }
            .clipped()
        )
    }
}
