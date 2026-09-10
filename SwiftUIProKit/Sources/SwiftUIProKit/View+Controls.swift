import SwiftUI

// MARK: - 控件样式

public extension View {

    /// 开关样式（switch）
    ///
    /// 使用系统标准开关样式，等效于 `.toggleStyle(.switch)`。
    ///
    /// - Example:
    ///   ```swift
    ///   Toggle("开关", isOn: $isOn)
    ///       .toggleStyleSwitch()
    ///   ```
    @ViewBuilder
    func toggleStyleSwitch() -> some View {
        toggleStyle(.switch)
    }

    /// 开关样式（button）
    ///
    /// 使用按钮外观的开关，等效于 `.toggleStyle(.button)`。
    ///
    /// - Example:
    ///   ```swift
    ///   Toggle("开关", isOn: $isOn)
    ///       .toggleStyleButton()
    ///   ```
    @ViewBuilder
    func toggleStyleButton() -> some View {
        toggleStyle(.button)
    }

    /// 开关样式（checkbox，仅 macOS）
    ///
    /// 使用复选框样式的开关，仅 macOS 可用，其他平台无操作。
    @ViewBuilder
    func toggleStyleCheckbox() -> some View {
        #if os(macOS)
        toggleStyle(.checkbox)
        #else
        self
        #endif
    }

    /// 控件主题色
    ///
    /// 给开关、滑块、步进器、进度条等控件统一设置主题色，等效于 `.tint(color)`。
    ///
    /// - Parameter color: 主题色
    ///
    /// - Example:
    ///   ```swift
    ///   Toggle("开关", isOn: $isOn)
    ///       .controlTint(.purple)
    ///   ```
    @ViewBuilder
    func controlTint(_ color: Color) -> some View {
        tint(color)
    }

    /// 菜单按钮样式
    ///
    /// 使用按钮外观的菜单，等效于 `.menuStyle(.button)`。需 iOS 16 / macOS 13+。
    ///
    /// - Example:
    ///   ```swift
    ///   Menu("操作") { ... }
    ///       .menuStyleButton()
    ///   ```
    @available(iOS 16.0, macOS 13.0, *)
    @ViewBuilder
    func menuStyleButton() -> some View {
        menuStyle(.button)
    }
}
