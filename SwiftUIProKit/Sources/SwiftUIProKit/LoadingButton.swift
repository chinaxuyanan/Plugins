import SwiftUI

// MARK: - 加载按钮

/// 加载按钮：带加载状态的自定义按钮
///
/// 加载中时在文字旁显示 `ProgressView` 转圈并自动禁用，避免重复提交；
/// 非加载态可显示可选图标。适合登录、提交、保存、发送等耗时操作。
///
/// - Example:
///   ```swift
///   @State private var submitting = false
///
///   LoadingButton("提交", isLoading: submitting) {
///       submitting = true
///       performSubmit { submitting = false }
///   }
///   .filledButtonStyle()
///   ```
public struct LoadingButton: View {

    /// 按钮文字
    private let title: String
    /// 是否加载中（`true` 时转圈并禁用）
    private let isLoading: Bool
    /// 非加载态显示的 SF Symbol 图标名（可选）
    private let icon: String?
    /// 点击时执行的操作（加载中不会触发）
    private let action: () -> Void

    /// - Parameters:
    ///   - title: 按钮文字
    ///   - isLoading: 是否加载中（`true` 时转圈并禁用），默认 `false`
    ///   - icon: 非加载态显示的 SF Symbol 图标名（可选）
    ///   - action: 点击时执行的操作
    public init(_ title: String,
                isLoading: Bool = false,
                icon: String? = nil,
                action: @escaping () -> Void) {
        self.title = title
        self.isLoading = isLoading
        self.icon = icon
        self.action = action
    }

    public var body: some View {
        Button {
            if !isLoading { action() }
        } label: {
            HStack(spacing: 8) {
                if isLoading {
                    ProgressView()
                        .controlSize(.small)
                } else if let icon = icon {
                    Image(systemName: icon)
                }
                Text(title)
            }
        }
        .disabled(isLoading)
    }
}

// MARK: 中文命名别名

/// 中文名：加载按钮（等同 `LoadingButton`）
public typealias 加载按钮 = LoadingButton

public extension LoadingButton {
    /// 加载按钮（中文参数）
    /// - Parameters:
    ///   - 标题: 按钮文字
    ///   - 加载中: 是否加载中（`true` 时转圈并禁用），默认 `false`
    ///   - 图标: 非加载态显示的 SF Symbol 图标名（可选）
    ///   - 动作: 点击时执行的操作
    ///
    /// - Note: 首个参数带 `标题:` 标签——英文 `init` 的首参是无标签 `String`，
    ///   两个重载若都无标签，`加载按钮("x") { }` 会报 `ambiguous use of 'init'`。
    init(标题: String, 加载中: Bool = false, 图标: String? = nil, 动作: @escaping () -> Void) {
        self.init(标题, isLoading: 加载中, icon: 图标, action: 动作)
    }
}
