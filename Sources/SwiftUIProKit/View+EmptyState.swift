import SwiftUI

// MARK: - 空状态视图

/// 空状态视图：列表 / 页面无数据时的占位提示
///
/// 居中展示一个图标 + 标题 + 描述，可选带一个操作按钮（如「去添加」「刷新」）。
/// 适合放在 `List`、`ScrollView` 或页面空白处，配合 `if items.isEmpty` 使用。
///
/// - Example:
///   ```swift
///   if items.isEmpty {
///       EmptyStateView(icon: "tray",
///                      title: "暂无数据",
///                      message: "下拉刷新或点击下方按钮重试",
///                      actionTitle: "刷新") {
///           loadData()
///       }
///   }
///   ```
public struct EmptyStateView: View {

    /// 图标（SF Symbol 名称）
    public let icon: String
    /// 标题
    public let title: String
    /// 描述文字（可选）
    public let message: String?
    /// 操作按钮文字（可选，为空则不显示按钮）
    public let actionTitle: String?
    /// 操作按钮回调（可选）
    public let action: (() -> Void)?

    /// - Parameters:
    ///   - icon: SF Symbol 图标名，默认 `"tray"`
    ///   - title: 标题
    ///   - message: 描述文字（可选）
    ///   - actionTitle: 操作按钮文字（可选，传了才显示按钮）
    ///   - action: 点击按钮执行的操作（可选）
    public init(icon: String = "tray",
                title: String,
                message: String? = nil,
                actionTitle: String? = nil,
                action: (() -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }

    public var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text(title)
                .font(.headline)
            if let message = message {
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle, action: action)
                    .filledButtonStyle()
            }
        }
        .padding(32)
        .frame(maxWidth: .infinity)
    }
}

// MARK: 中文命名别名

/// 中文名：空状态视图（等同 `EmptyStateView`）
public typealias 空状态视图 = EmptyStateView

public extension EmptyStateView {
    /// 空状态视图（中文参数）
    /// - Parameters:
    ///   - 图标: SF Symbol 图标名，默认 `"tray"`
    ///   - 标题: 标题
    ///   - 描述: 描述文字（可选）
    ///   - 操作文字: 操作按钮文字（可选，传了才显示按钮）
    ///   - 操作: 点击按钮执行的操作（可选）
    init(图标: String = "tray", 标题: String, 描述: String? = nil, 操作文字: String? = nil, 操作: (() -> Void)? = nil) {
        self.init(icon: 图标, title: 标题, message: 描述, actionTitle: 操作文字, action: 操作)
    }
}
