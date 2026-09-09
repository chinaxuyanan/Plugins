import SwiftUI

// MARK: - 网格（等宽列 / 自适应列 / Grid 容器）

/// 等宽网格：把内容排成指定列数的网格，每列等宽
///
/// 内部用 `LazyVGrid` + 等宽（flexible）列实现，传个列数即可，不必纠结 `GridItem` 怎么写。
/// - Parameters:
///   - columns: 列数
///   - spacing: 列间距与行间距，默认 `8`
///   - alignment: 每列内容对齐，默认 `.center`
///   - content: 网格内容
///
/// - Example:
///   ```swift
///   EqualColumnGrid(columns: 3) {
///       ForEach(0..<9, id: \.self) { Text("\($0)") }
///   }
///   ```
public struct EqualColumnGrid<Content: View>: View {
    private let columns: [GridItem]
    private let alignment: HorizontalAlignment
    private let spacing: CGFloat
    private let content: Content

    public init(columns: Int,
                spacing: CGFloat = 8,
                alignment: HorizontalAlignment = .center,
                @ViewBuilder content: () -> Content) {
        self.columns = Array(repeating: GridItem(.flexible(), spacing: spacing), count: max(1, columns))
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        LazyVGrid(columns: columns, alignment: alignment, spacing: spacing) { content }
    }
}

/// 自适应网格：按最小宽度自动算列数
///
/// 内部用 `LazyVGrid` + 自适应（adaptive）列实现，传个最小宽度即可自动换列、自动适配屏幕宽度。
/// - Parameters:
///   - minimumWidth: 每列最小宽度
///   - spacing: 列间距与行间距，默认 `8`
///   - alignment: 每列内容对齐，默认 `.center`
///   - content: 网格内容
///
/// - Example:
///   ```swift
///   AdaptiveGrid(minimumWidth: 80) {
///       ForEach(items, id: \.self) { Text($0) }
///   }
///   ```
public struct AdaptiveGrid<Content: View>: View {
    private let columns: [GridItem]
    private let alignment: HorizontalAlignment
    private let spacing: CGFloat
    private let content: Content

    public init(minimumWidth: CGFloat,
                spacing: CGFloat = 8,
                alignment: HorizontalAlignment = .center,
                @ViewBuilder content: () -> Content) {
        self.columns = [GridItem(.adaptive(minimum: minimumWidth), spacing: spacing)]
        self.alignment = alignment
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        LazyVGrid(columns: columns, alignment: alignment, spacing: spacing) { content }
    }
}

// MARK: 中文名与中文构造器

/// 中文名：等宽网格（等同 `EqualColumnGrid`）
public typealias 等宽网格<Content: View> = EqualColumnGrid<Content>

/// 中文名：自适应网格（等同 `AdaptiveGrid`）
public typealias 自适应网格<Content: View> = AdaptiveGrid<Content>

public extension EqualColumnGrid {
    /// 等宽网格（中文参数）
    /// - Parameters:
    ///   - 列数: 网格列数
    ///   - 间距: 列间距与行间距，默认 `8`
    ///   - 对齐: 每列内容对齐，默认 `.center`
    ///   - 内容: 网格内容
    init(列数: Int, 间距: CGFloat = 8, 对齐: HorizontalAlignment = .center, @ViewBuilder 内容: () -> Content) {
        self.init(columns: 列数, spacing: 间距, alignment: 对齐, content: 内容)
    }
}

public extension AdaptiveGrid {
    /// 自适应网格（中文参数）
    /// - Parameters:
    ///   - 最小宽度: 每列最小宽度
    ///   - 间距: 列间距与行间距，默认 `8`
    ///   - 对齐: 每列内容对齐，默认 `.center`
    ///   - 内容: 网格内容
    init(最小宽度: CGFloat, 间距: CGFloat = 8, 对齐: HorizontalAlignment = .center, @ViewBuilder 内容: () -> Content) {
        self.init(minimumWidth: 最小宽度, spacing: 间距, alignment: 对齐, content: 内容)
    }
}

// MARK: Grid 容器中文别名（iOS 16+ / macOS 13+）

/// 中文名：网格（等同 `Grid`，声明式行列网格容器）
@available(iOS 16.0, macOS 13.0, *)
public typealias 网格 = Grid

/// 中文名：网格行（等同 `GridRow`）
@available(iOS 16.0, macOS 13.0, *)
public typealias 网格行 = GridRow
