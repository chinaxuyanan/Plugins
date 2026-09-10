import SwiftUI

// MARK: - 选择器

public extension View {

    /// 分段选择器样式
    ///
    /// Picker 以分段控件显示，等效于 `.pickerStyle(.segmented)`。
    @ViewBuilder
    func pickerStyleSegmented() -> some View { pickerStyle(.segmented) }

    /// 菜单选择器样式
    ///
    /// Picker 以下拉菜单显示，等效于 `.pickerStyle(.menu)`。
    @ViewBuilder
    func pickerStyleMenu() -> some View { pickerStyle(.menu) }

    /// 行内选择器样式
    ///
    /// Picker 以行内控件显示，等效于 `.pickerStyle(.inline)`。
    @available(iOS 16.0, macOS 13.0, *)
    @ViewBuilder
    func pickerStyleInline() -> some View { pickerStyle(.inline) }
}
