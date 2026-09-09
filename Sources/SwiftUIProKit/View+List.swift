import SwiftUI

// MARK: - 列表与滚动

public extension View {

    /// 普通列表样式
    ///
    /// 去除分组背景，列表直接铺满，等效于 `.listStyle(.plain)`。
    @ViewBuilder
    func listStylePlain() -> some View { listStyle(.plain) }

    /// 内嵌列表样式
    ///
    /// 列表以卡片内嵌样式显示，macOS 下尤其常用，等效于 `.listStyle(.inset)`。
    @ViewBuilder
    func listStyleInset() -> some View { listStyle(.inset) }

    /// 隐藏列表行分隔线
    ///
    /// 去掉列表行之间的分隔线，等效于 `.listRowSeparator(.hidden)`。
    @available(macOS 13.0, *)
    @ViewBuilder
    func listRowSeparatorHidden() -> some View { listRowSeparator(.hidden) }

    /// 隐藏滚动条
    ///
    /// 隐藏 ScrollView / List 的滚动指示条，等效于 `.scrollIndicators(.hidden)`。
    @available(iOS 16.0, macOS 13.0, *)
    @ViewBuilder
    func scrollIndicatorsHidden() -> some View { scrollIndicators(.hidden) }
}
