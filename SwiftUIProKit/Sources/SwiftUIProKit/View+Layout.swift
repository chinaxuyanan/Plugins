import SwiftUI

// MARK: - 布局与尺寸

public extension View {

    /// 占满父视图的宽度
    ///
    /// 将视图在水平方向撑满可用空间，垂直方向保持自身尺寸。
    /// 常用于让按钮、分隔线、输入框等内容在父容器中横向铺满。
    ///
    /// - Parameter alignment: 内容在撑满后的对齐方式，默认 `.center`。
    ///
    /// - Example:
    ///   ```swift
    ///   Button("登录") { }
    ///       .fillWidth()
    ///   ```
    @ViewBuilder
    func fillWidth(alignment: Alignment = .center) -> some View {
        frame(maxWidth: .infinity, alignment: alignment)
    }

    /// 占满父视图的高度
    ///
    /// 将视图在垂直方向撑满可用空间，水平方向保持自身尺寸。
    ///
    /// - Parameter alignment: 内容在撑满后的对齐方式，默认 `.center`。
    ///
    /// - Example:
    ///   ```swift
    ///   Divider()
    ///       .fillHeight()
    ///   ```
    @ViewBuilder
    func fillHeight(alignment: Alignment = .center) -> some View {
        frame(maxHeight: .infinity, alignment: alignment)
    }

    /// 同时占满父视图的宽度和高度
    ///
    /// 让视图填满整个父容器，常用于背景层或铺满屏幕的视图。
    ///
    /// - Parameter alignment: 内容在撑满后的对齐方式，默认 `.center`。
    ///
    /// - Example:
    ///   ```swift
    ///   Color.blue
    ///       .fillSpace()
    ///   ```
    @ViewBuilder
    func fillSpace(alignment: Alignment = .center) -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
    }

    /// 固定为正方形尺寸
    ///
    /// 同时设置宽度和高度为相同数值，常用于头像占位、图标等需要正方形的内容。
    ///
    /// - Parameter length: 边长（单位：pt）。
    ///
    /// - Example:
    ///   ```swift
    ///   Image(systemName: "star")
    ///       .size(44)
    ///   ```
    @ViewBuilder
    func size(_ length: CGFloat) -> some View {
        frame(width: length, height: length)
    }

    /// 分别设置水平和垂直内边距
    ///
    /// 与系统 `padding(_:)` 类似，但允许单独控制水平、垂直两个方向的内边距。
    ///
    /// - Parameters:
    ///   - horizontal: 水平方向（左右）内边距，单位 pt。
    ///   - vertical: 垂直方向（上下）内边距，单位 pt。
    ///
    /// - Example:
    ///   ```swift
    ///   Text("你好")
    ///       .padding(horizontal: 16, vertical: 8)
    ///   ```
    @ViewBuilder
    func padding(horizontal: CGFloat, vertical: CGFloat) -> some View {
        padding(.horizontal, horizontal)
            .padding(.vertical, vertical)
    }

    /// 在父容器中居中
    ///
    /// 将视图置于父容器正中央，等效于 `.frame(maxWidth: .infinity, maxHeight: .infinity)`。
    ///
    /// - Example:
    ///   ```swift
    ///   Text("居中")
    ///       .centered()
    ///   ```
    @ViewBuilder
    func centered() -> some View {
        frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
