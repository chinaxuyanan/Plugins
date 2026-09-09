import SwiftUI

// MARK: - 动画与过渡

public extension View {

    /// 为视图绑定动画
    ///
    /// 当 `value` 发生变化时，用指定的动画曲线过渡视图状态变化。
    /// 是系统 `.animation(_:value:)` 的中文文档封装。
    ///
    /// - Parameters:
    ///   - animation: 动画曲线，默认 `.default`。
    ///   - value: 触发动画的状态值（需遵循 `Equatable`）。
    ///
    /// - Example:
    ///   ```swift
    ///   Circle()
    ///       .frame(width: isActive ? 80 : 40)
    ///       .animate(.spring(), value: isActive)
    ///   ```
    @ViewBuilder
    func animate<Value: Equatable>(_ animation: Animation = .default, value: Value) -> some View {
        self.animation(animation, value: value)
    }

    /// 淡入淡出过渡
    ///
    /// 视图插入 / 移除时以透明度变化过渡，等效于 `.transition(.opacity)`。
    ///
    /// - Example:
    ///   ```swift
    ///   if show { detail.fadeTransition() }
    ///   ```
    @ViewBuilder
    func fadeTransition() -> some View {
        transition(.opacity)
    }

    /// 滑动过渡
    ///
    /// 视图插入 / 移除时从指定边缘滑入 / 滑出，等效于 `.transition(.move(edge:))`。
    ///
    /// - Parameter edge: 滑入方向，如 `.trailing`、`.bottom`。
    @ViewBuilder
    func slideTransition(edge: Edge = .trailing) -> some View {
        transition(.move(edge: edge))
    }

    /// 缩放过渡
    ///
    /// 视图插入 / 移除时以缩放动画过渡，等效于 `.transition(.scale(scale:))`。
    ///
    /// - Parameter scale: 起始缩放比例，默认 `0.9`。
    @ViewBuilder
    func scaleTransition(scale: CGFloat = 0.9) -> some View {
        transition(.scale(scale: scale))
    }

    /// 淡入 + 缩放组合过渡
    ///
    /// 同时应用透明度与缩放过渡，适合列表项插入等场景。
    ///
    /// - Parameter scale: 起始缩放比例，默认 `0.9`。
    @ViewBuilder
    func fadeScaleTransition(scale: CGFloat = 0.9) -> some View {
        transition(.opacity.combined(with: .scale(scale: scale)))
    }
}
