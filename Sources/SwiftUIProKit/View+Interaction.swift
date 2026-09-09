import SwiftUI

// MARK: - 交互、手势与动画

public extension View {

    /// 轻点手势
    ///
    /// 为视图添加点击（Tap）手势，是 `onTapGesture` 的中文文档封装。
    ///
    /// - Parameter action: 点击后执行的操作。
    ///
    /// - Example:
    ///   ```swift
    ///   Text("点我").onTap { print("被点击") }
    ///   ```
    @ViewBuilder
    func onTap(perform action: @escaping () -> Void) -> some View {
        onTapGesture(perform: action)
    }

    /// 设置视图不透明度
    ///
    /// 调整视图整体的透明度。
    ///
    /// - Parameter value: 不透明度，`0`（完全透明）到 `1`（完全不透明）。
    ///
    /// - Example:
    ///   ```swift
    ///   Text("半透明").viewOpacity(0.5)
    ///   ```
    @ViewBuilder
    func viewOpacity(_ value: Double) -> some View {
        opacity(value)
    }

    /// 条件隐藏
    ///
    /// 当条件为 `true` 时隐藏视图（不占位），否则正常显示。
    ///
    /// - Parameter isHidden: 是否隐藏。
    ///
    /// - Example:
    ///   ```swift
    ///   Text("错误提示").hiddenIf(error == nil)
    ///   ```
    @ViewBuilder
    func hiddenIf(_ isHidden: Bool) -> some View {
        if isHidden {
            self.hidden()
        } else {
            self
        }
    }

    /// 条件执行（通用链式辅助）
    ///
    /// 根据条件对视图应用不同的变换，常用于「有数据时显示 X，否则显示 Y」的场景。
    ///
    /// - Parameters:
    ///   - condition: 判断条件。
    ///   - transform: 条件为 `true` 时应用的变换。
    ///
    /// - Example:
    ///   ```swift
    ///   Text("状态").if(isLoading) { $0.viewOpacity(0.3) }
    ///   ```
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }

    /// 值存在时执行变换
    ///
    /// 当可选值非 `nil` 时，用解包后的值对视图应用变换；为 `nil` 时原样返回。
    /// 适合「有可选数据时套用某种修饰符」的场景，避免先 `if let` 再写两遍视图。
    ///
    /// - Parameters:
    ///   - value: 待判断的可选值。
    ///   - transform: 值非 `nil` 时应用的变换，闭包参数为解包后的值。
    ///
    /// - Example:
    ///   ```swift
    ///   Text("用户").ifLet(userName) { view, name in
    ///       view.textColor(.primary) + Text(name) // 有名字时额外显示
    ///   }
    ///   ```
    @ViewBuilder
    func ifLet<Value, Content: View>(_ value: Value?, transform: (Self, Value) -> Content) -> some View {
        if let value = value {
            transform(self, value)
        } else {
            self
        }
    }

    /// 按压反馈（缩放动画）
    ///
    /// 让视图在按压时轻微缩小、松开时回弹，提供按下按钮的直观反馈。
    ///
    /// - Parameter scale: 按压时的缩放比例，默认 `0.95`。
    ///
    /// - Example:
    ///   ```swift
    ///   Button("确认") { }.pressable()
    ///   ```
    func pressable(scale: CGFloat = 0.95) -> some View {
        modifier(PressableModifier(scale: scale))
    }

    /// 按压反馈按钮样式
    ///
    /// 将按压缩放的反馈应用到 `Button` 上。相比 `pressable`（手势版），
    /// 本方法基于 `ButtonStyle` 实现，在 ScrollView 等可滚动容器里更稳定，
    /// 也不会和按钮自身的点击手势冲突。
    ///
    /// - Parameter scale: 按压时的缩放比例，默认 `0.95`。
    ///
    /// - Example:
    ///   ```swift
    ///   Button("确认") { }.pressableButtonStyle()
    ///   ```
    func pressableButtonStyle(scale: CGFloat = 0.95) -> some View {
        buttonStyle(PressableButtonStyle(scale: scale))
    }
}

/// 按压缩放反馈的底层实现
struct PressableModifier: ViewModifier {
    var scale: CGFloat

    @GestureState private var isPressed = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isPressed ? scale : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .updating($isPressed) { _, state, _ in
                        state = true
                    }
            )
    }
}

/// 按压缩放反馈的按钮样式实现
public struct PressableButtonStyle: ButtonStyle {
    /// 按压时的缩放比例
    public var scale: CGFloat

    public init(scale: CGFloat = 0.95) {
        self.scale = scale
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
