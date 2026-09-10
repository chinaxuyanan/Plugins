import SwiftUI

// MARK: - 布局强化
//
// 尺寸、等比缩放、安全区、网格列等布局相关属性的语义化封装。

public extension View {

    /// 设置视图宽高
    ///
    /// 等效于 `.frame(width:height:alignment:)`。
    ///
    /// - Parameters:
    ///   - width: 宽度，`nil` 表示自适应
    ///   - height: 高度，`nil` 表示自适应
    ///   - alignment: 内容对齐方式，默认 `.center`
    ///
    /// - Example:
    ///   ```swift
    ///   Text("内容").frameSize(width: 120, height: 44)
    ///   ```
    @ViewBuilder
    func frameSize(width: CGFloat? = nil, height: CGFloat? = nil, alignment: Alignment = .center) -> some View {
        frame(width: width, height: height, alignment: alignment)
    }

    /// 设置最大宽度
    ///
    /// 等效于 `.frame(maxWidth:alignment:)`，常用于让视图占满可用宽度。
    ///
    /// - Parameters:
    ///   - maxWidth: 最大宽度，默认 `.infinity`
    ///   - alignment: 内容对齐方式，默认 `.center`
    ///
    /// - Example:
    ///   ```swift
    ///   Button("确认") { }.frameMaxWidth()
    ///   ```
    @ViewBuilder
    func frameMaxWidth(_ maxWidth: CGFloat = .infinity, alignment: Alignment = .center) -> some View {
        frame(maxWidth: maxWidth, alignment: alignment)
    }

    /// 设置最大高度
    ///
    /// 等效于 `.frame(maxHeight:alignment:)`，常用于让视图占满可用高度。
    ///
    /// - Parameters:
    ///   - maxHeight: 最大高度，默认 `.infinity`
    ///   - alignment: 内容对齐方式，默认 `.center`
    @ViewBuilder
    func frameMaxHeight(_ maxHeight: CGFloat = .infinity, alignment: Alignment = .center) -> some View {
        frame(maxHeight: maxHeight, alignment: alignment)
    }

    /// 等比缩放
    ///
    /// 保持宽高比缩放视图，等效于 `.aspectRatio(_:contentMode:)`。
    ///
    /// - Parameters:
    ///   - ratio: 宽高比，如 `16 / 9`
    ///   - contentMode: `.fit` 完整显示 / `.fill` 填满裁切，默认 `.fit`
    ///
    /// - Example:
    ///   ```swift
    ///   Image("cover").scaledAspect(16 / 9, contentMode: .fill)
    ///   ```
    @ViewBuilder
    func scaledAspect(_ ratio: CGFloat, contentMode: ContentMode = .fit) -> some View {
        aspectRatio(ratio, contentMode: contentMode)
    }

    /// 忽略安全区
    ///
    /// 让视图延伸到安全区之外，等效于 `.ignoresSafeArea(.all, edges:)`。
    ///
    /// - Parameter edges: 要忽略的安全区边缘，默认 `.all`
    @ViewBuilder
    func ignoreSafeArea(edges: Edge.Set = .all) -> some View {
        ignoresSafeArea(.all, edges: edges)
    }

    /// 在安全区边缘插入内容
    ///
    /// 等效于 `.safeAreaInset(edge:content:)`，常用于在列表底部放固定按钮。
    ///
    /// - Parameters:
    ///   - edge: 插入位置（上 / 下 / 左 / 右）
    ///   - content: 插入的内容
    ///
    /// - Example:
    ///   ```swift
    ///   List { ... }
    ///       .safeAreaContent(edge: .bottom) {
    ///           Button("确认") { }
    ///       }
    ///   ```
    @ViewBuilder
    func safeAreaContent<Content: View>(edge: Edge, @ViewBuilder content: @escaping () -> Content) -> some View {
        switch edge {
        case .top: safeAreaInset(edge: .top, content: content)
        case .bottom: safeAreaInset(edge: .bottom, content: content)
        case .leading: safeAreaInset(edge: .leading, content: content)
        case .trailing: safeAreaInset(edge: .trailing, content: content)
        }
    }

    /// 固定为内容自身尺寸
    ///
    /// 等效于 `.fixedSize(horizontal:vertical:)`，让视图不跟随父容器拉伸。
    ///
    /// - Parameters:
    ///   - horizontal: 水平方向固定，默认 `true`
    ///   - vertical: 垂直方向固定，默认 `true`
    @ViewBuilder
    func fixedToContent(horizontal: Bool = true, vertical: Bool = true) -> some View {
        fixedSize(horizontal: horizontal, vertical: vertical)
    }

    /// 裁剪超出边界的部分
    ///
    /// 等效于 `.clipped()`。
    @ViewBuilder
    func clippedContent() -> some View {
        clipped()
    }
}

// MARK: - 网格列定义

public extension GridItem {

    /// 弹性列（等同 `.flexible`，占据剩余空间）
    ///
    /// - Parameters:
    ///   - minimum: 最小宽度，默认 `10`
    ///   - maximum: 最大宽度，默认 `.infinity`
    static func flexible(minimum: CGFloat = 10, maximum: CGFloat = .infinity) -> GridItem {
        GridItem(.flexible(minimum: minimum, maximum: maximum))
    }

    /// 自适应列（等同 `.adaptive`，按可用宽度自动排多个）
    ///
    /// - Parameters:
    ///   - minimum: 每列最小宽度
    ///   - maximum: 每列最大宽度，默认 `.infinity`
    static func adaptive(minimum: CGFloat, maximum: CGFloat = .infinity) -> GridItem {
        GridItem(.adaptive(minimum: minimum, maximum: maximum))
    }

    /// 固定宽度列（等同 `.fixed`）
    ///
    /// - Parameter size: 固定宽度
    static func fixed(_ size: CGFloat) -> GridItem {
        GridItem(.fixed(size))
    }

    /// 弹性列（等同 `flexible(minimum:maximum:)`）
    ///
    /// - Parameters:
    ///   - 最小: 最小宽度，默认 `10`
    ///   - 最大: 最大宽度，默认 `.infinity`
    static func 弹性(最小: CGFloat = 10, 最大: CGFloat = .infinity) -> GridItem {
        flexible(minimum: 最小, maximum: 最大)
    }

    /// 自适应列（等同 `adaptive(minimum:maximum:)`）
    ///
    /// - Parameters:
    ///   - 最小: 每列最小宽度
    ///   - 最大: 每列最大宽度，默认 `.infinity`
    static func 自适应(最小: CGFloat, 最大: CGFloat = .infinity) -> GridItem {
        adaptive(minimum: 最小, maximum: 最大)
    }

    /// 固定宽度列（等同 `fixed(_:)`）
    ///
    /// - Parameter 尺寸: 固定宽度
    static func 固定(_ 尺寸: CGFloat) -> GridItem {
        fixed(尺寸)
    }
}
