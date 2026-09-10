import SwiftUI

// MARK: - 刷新与搜索

public extension View {

    /// 下拉刷新（等同 `.refreshable`）
    ///
    /// 需要配合可滚动容器（`List` / `ScrollView`）使用。
    /// - Parameter action: 下拉触发的异步刷新操作（`@Sendable`，与 `refreshable(action:)` 契约一致）
    func pullToRefresh(_ action: @escaping @Sendable () async -> Void) -> some View {
        refreshable(action: action)
    }

    /// 搜索框（等同 `.searchable`）
    ///
    /// 在导航栏下方挂一个搜索框，绑定搜索文本。
    /// - Parameters:
    ///   - text: 搜索文本的绑定值
    ///   - placement: 搜索框位置，默认 `.automatic`
    ///   - prompt: 搜索框占位提示文字
    @ViewBuilder
    func searchableText(_ text: Binding<String>,
                        placement: SearchFieldPlacement = .automatic,
                        prompt: String? = nil) -> some View {
        if let prompt = prompt {
            searchable(text: text, placement: placement, prompt: Text(prompt))
        } else {
            searchable(text: text, placement: placement)
        }
    }
}
