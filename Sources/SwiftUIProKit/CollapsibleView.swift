import SwiftUI

// MARK: - 可折叠面板

/// 可折叠面板：点击标题展开 / 收起内容
///
/// 展开状态由外部 `Binding` 控制，因此可自由组合成「手风琴」——
/// 多个面板共用一个 `selected` 索引，一次只展开一个。
///
/// - Example:
///   ```swift
///   // 单个折叠面板
///   @State private var open = false
///   CollapsibleView("更多设置", isExpanded: $open) {
///       Text("这里是被折叠的内容")
///   }
///
///   // 手风琴（一次只开一个）
///   @State private var selected: Int?
///   ForEach(Array(items.enumerated()), id: \.offset) { index, item in
///       CollapsibleView(item.title,
///                       isExpanded: Binding(
///                           get: { selected == index },
///                           set: { if $0 { selected = index } }
///                       )) {
///           Text(item.detail)
///       }
///   }
///   ```
public struct CollapsibleView: View {

    /// 标题
    private let title: String
    /// 标题前图标（SF Symbol，可选）
    private let icon: String?
    /// 展开状态绑定
    @Binding private var isExpanded: Bool
    /// 折叠的内容（类型擦除）
    private let content: AnyView

    /// - Parameters:
    ///   - title: 面板标题
    ///   - icon: 标题前 SF Symbol 图标名（可选）
    ///   - isExpanded: 展开状态绑定
    ///   - content: 展开后显示的内容
    public init<Content: View>(_ title: String,
                               icon: String? = nil,
                               isExpanded: Binding<Bool>,
                               @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self._isExpanded = isExpanded
        self.content = AnyView(content())
    }

    public var body: some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 8) {
                    if let icon = icon {
                        Image(systemName: icon)
                            .foregroundStyle(.secondary)
                    }
                    Text(title)
                        .font(.headline)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                }
                .padding(.vertical, 10)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)

            if isExpanded {
                content
                    .transition(.opacity)
            }
        }
    }
}

// MARK: 中文命名别名

/// 中文名：可折叠面板（等同 `CollapsibleView`）
public typealias 可折叠面板 = CollapsibleView

public extension CollapsibleView {
    /// 可折叠面板（中文参数）
    /// - Parameters:
    ///   - 标题: 面板标题
    ///   - 图标: 标题前 SF Symbol 图标名（可选）
    ///   - 展开: 展开状态绑定
    ///   - 内容: 展开后显示的内容
    init<Content: View>(_ 标题: String,
                        图标: String? = nil,
                        展开: Binding<Bool>,
                        @ViewBuilder 内容: () -> Content) {
        self.init(标题, icon: 图标, isExpanded: 展开, content: 内容)
    }
}
