import SwiftUI

// MARK: - 骨架屏（骨架占位 + 扫光）

public extension View {

    /// 骨架占位：加载时把内容灰化成占位形状（等同 `.redacted(reason: .placeholder)`）
    ///
    /// 适合配合 `shimmer` 使用：`view.skeleton().shimmer()` 得到带扫光动画的骨架屏。
    /// - Parameter active: 是否进入骨架占位状态，默认 `true`
    func skeleton(_ active: Bool = true) -> some View {
        redacted(reason: active ? .placeholder : [])
    }

    /// 扫光效果：在内容上叠加一条左右循环扫过的高光带
    ///
    /// 单独使用可在任意视图上做「扫光」，配合 `skeleton` 使用即为常见骨架屏动画。
    /// - Parameters:
    ///   - isActive: 是否播放扫光动画，默认 `true`
    ///   - baseColor: 渐变两端的基色，默认 `Color.gray.opacity(0.25)`
    ///   - highlightColor: 扫光带的高亮色，默认 `Color.white.opacity(0.6)`
    ///   - duration: 单次扫光动画时长（秒），默认 `1.2`
    func shimmer(isActive: Bool = true,
                 baseColor: Color = Color.gray.opacity(0.25),
                 highlightColor: Color = Color.white.opacity(0.6),
                 duration: Double = 1.2) -> some View {
        modifier(ShimmerModifier(isActive: isActive, baseColor: baseColor,
                                 highlightColor: highlightColor, duration: duration))
    }
}

/// 扫光效果内部实现
private struct ShimmerModifier: ViewModifier {
    var isActive: Bool
    var baseColor: Color
    var highlightColor: Color
    var duration: Double

    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content.overlay(
            ZStack {
                if isActive {
                    GeometryReader { proxy in
                        let width = proxy.size.width
                        LinearGradient(
                            gradient: Gradient(colors: [baseColor, highlightColor, baseColor]),
                            startPoint: .leading, endPoint: .trailing
                        )
                        .frame(width: width * 0.6)
                        .offset(x: phase * (width * 1.6))
                    }
                }
            }
            .mask(content)
            .onAppear {
                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                    phase = 1
                }
            }
        )
    }
}
