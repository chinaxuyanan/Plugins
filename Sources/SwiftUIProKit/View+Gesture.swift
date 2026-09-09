import SwiftUI

// MARK: - 手势

public extension View {

    /// 双击手势
    ///
    /// 检测在视图上的快速连点两次。
    ///
    /// - Parameter action: 双击后执行的操作。
    ///
    /// - Example:
    ///   ```swift
    ///   Image("photo").onDoubleTap { zoomIn() }
    ///   ```
    @ViewBuilder
    func onDoubleTap(perform action: @escaping () -> Void) -> some View {
        onTapGesture(count: 2, perform: action)
    }

    /// 长按手势
    ///
    /// 按住超过指定时长后触发。
    ///
    /// - Parameters:
    ///   - minimumDuration: 需要按住的最短时长（秒），默认 `0.5`。
    ///   - action: 触发后执行的操作。
    ///
    /// - Example:
    ///   ```swift
    ///   row.onLongPress { showContextMenu() }
    ///   ```
    @ViewBuilder
    func onLongPress(minimumDuration: Double = 0.5,
                     perform action: @escaping () -> Void) -> some View {
        onLongPressGesture(minimumDuration: minimumDuration, perform: action)
    }

    /// 滑动手势
    ///
    /// 检测上下左右四个方向的轻扫，按需传入对应方向的回调。
    /// 注意：本方法会附加一个拖拽手势，可能与 ScrollView 的滚动手势冲突，
    /// 请避免直接加在可滚动内容上。
    ///
    /// - Parameters:
    ///   - up: 上滑回调。
    ///   - down: 下滑回调。
    ///   - left: 左滑回调。
    ///   - right: 右滑回调。
    ///
    /// - Example:
    ///   ```swift
    ///   card.onSwipe(left: { dismiss() })
    ///   ```
    @ViewBuilder
    func onSwipe(up: (() -> Void)? = nil,
                 down: (() -> Void)? = nil,
                 left: (() -> Void)? = nil,
                 right: (() -> Void)? = nil) -> some View {
        gesture(
            DragGesture(minimumDistance: 20, coordinateSpace: .local)
                .onEnded { value in
                    let t = value.translation
                    if abs(t.width) > abs(t.height) {
                        if t.width < 0 { left?() } else { right?() }
                    } else {
                        if t.height < 0 { up?() } else { down?() }
                    }
                }
        )
    }
}
