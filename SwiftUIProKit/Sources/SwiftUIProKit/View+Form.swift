import SwiftUI

// MARK: - 表单与分组（分组卡片 / 表单样式）

/// 分组卡片：带标题的 GroupBox 卡片，适合「设置页」式的分组信息展示
///
/// - Parameters:
///   - title: 分组标题
///   - content: 分组内容
///
/// - Example:
///   ```swift
///   GroupCard("账号") {
///       Text("用户名：yanan")
///       Text("邮箱：yanan@example.com")
///   }
///   ```
public struct GroupCard<Content: View>: View {
    private let title: String
    private let content: Content

    public init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    public var body: some View {
        GroupBox {
            content
        } label: {
            Text(title).font(.headline)
        }
    }
}

// MARK: 中文名与中文构造器

/// 中文名：分组卡片（等同 `GroupCard`）
public typealias 分组卡片<Content: View> = GroupCard<Content>

public extension GroupCard {
    /// 分组卡片（中文参数）
    /// - Parameters:
    ///   - 标题: 分组标题
    ///   - 内容: 分组内容
    init(标题: String, @ViewBuilder 内容: () -> Content) {
        self.init(标题, content: 内容)
    }
}

// MARK: 表单样式

public extension View {
    /// 表单样式（等同 `.formStyle`，iOS 16+ / macOS 13+）
    ///
    /// 用于 `Form` 的整体样式，如 `.grouped`（分组卡片外观）。
    /// - Parameter style: 表单样式
    @available(iOS 16.0, macOS 13.0, *)
    @ViewBuilder
    func formStyleCustom(_ style: some FormStyle) -> some View {
        formStyle(style)
    }
}
