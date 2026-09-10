import SwiftUI

// MARK: - 导航与标题

public extension View {

    /// 内联标题
    ///
    /// 导航栏标题以小字内联显示，等效于 `.toolbarTitleDisplayMode(.inline)`。
    @available(macOS 14.0, *)
    @ViewBuilder
    func inlineTitle() -> some View { toolbarTitleDisplayMode(.inline) }

    /// 大标题
    ///
    /// 导航栏标题以大标题显示，等效于 `.toolbarTitleDisplayMode(.large)`。
    /// 注意：`large` 是 iOS 专有样式，macOS 上本方法无效果（原样返回视图）。
    @ViewBuilder
    func largeTitle() -> some View {
        #if os(iOS)
        toolbarTitleDisplayMode(.large)
        #else
        self
        #endif
    }

    /// 隐藏导航栏 / 窗口工具栏
    ///
    /// 隐藏当前页面的导航栏（iOS）或窗口工具栏（macOS），
    /// 等效于 `.toolbar(.hidden, for: .navigationBar)`（macOS 为 `.windowToolbar`）。
    @available(iOS 16.0, macOS 13.0, *)
    @ViewBuilder
    func hideNavigationBar() -> some View {
        #if os(iOS)
        toolbar(.hidden, for: .navigationBar)
        #else
        toolbar(.hidden, for: .windowToolbar)
        #endif
    }

    /// 设置导航栏 / 窗口工具栏背景色
    ///
    /// 给导航栏（iOS）或窗口工具栏（macOS）设置背景颜色，
    /// 等效于 `.toolbarBackground(_:for:)`。
    ///
    /// - Parameter color: 背景颜色
    @available(iOS 16.0, macOS 13.0, *)
    @ViewBuilder
    func navigationBarBackground(_ color: Color) -> some View {
        #if os(iOS)
        toolbarBackground(color, for: .navigationBar)
        #else
        toolbarBackground(color, for: .windowToolbar)
        #endif
    }
}
