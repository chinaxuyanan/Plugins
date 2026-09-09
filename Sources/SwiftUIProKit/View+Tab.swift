import SwiftUI

// MARK: - 标签页

public extension View {

    /// 自动标签页样式
    ///
    /// 使用系统默认的标签栏样式，等效于 `.tabViewStyle(.automatic)`。
    ///
    /// - Example:
    ///   ```swift
    ///   TabView { ... }
    ///       .tabViewStyleAutomatic()
    ///   ```
    @ViewBuilder
    func tabViewStyleAutomatic() -> some View {
        tabViewStyle(.automatic)
    }

    #if os(iOS)
    /// 分页标签页样式
    ///
    /// 使用可左右滑动的分页样式，等效于 `.tabViewStyle(.page(indexDisplayMode:))`。
    /// 仅 iOS 可用（`PageTabViewStyle` 为 iOS 专有）。
    ///
    /// - Parameter indexDisplayMode: 页码指示器显示方式，默认 `.automatic`
    ///
    /// - Example:
    ///   ```swift
    ///   TabView { ... }
    ///       .tabViewStylePage(indexDisplayMode: .always)
    ///   ```
    @ViewBuilder
    func tabViewStylePage(indexDisplayMode: PageTabViewStyle.IndexDisplayMode = .automatic) -> some View {
        tabViewStyle(.page(indexDisplayMode: indexDisplayMode))
    }
    #endif

    /// 标签项（图标 + 文字）
    ///
    /// 给 TabView 的每个子视图快速加一个「图标 + 文字」的标签，
    /// 等效于 `.tabItem { Label(title, systemImage: systemImage) }`。
    ///
    /// - Parameters:
    ///   - title: 标签文字
    ///   - systemImage: SF Symbol 图标名
    ///
    /// - Example:
    ///   ```swift
    ///   HomeView().tabItemLabel(title: "首页", systemImage: "house")
    ///   ```
    @ViewBuilder
    func tabItemLabel(title: String, systemImage: String) -> some View {
        tabItem {
            Label(title, systemImage: systemImage)
        }
    }
}
