import SwiftUI

// MARK: - 时间轴条目

/// 时间轴上的一个节点
public struct TimelineItem: Identifiable {

    /// 唯一标识（用于 `ForEach` 与列表刷新）
    public let id: UUID
    /// 标题
    public let title: String
    /// 详情（副标题），默认 `nil`
    public let detail: String?
    /// 圆点内的 SF Symbols 图标名，默认 `nil`（不显示图标，用实心小圆点）
    public let icon: String?
    /// 是否已完成（已完成用主题色，未完成置灰）
    public let isDone: Bool

    /// - Parameters:
    ///   - id: 唯一标识，默认自动生成 `UUID`
    ///   - title: 标题
    ///   - detail: 详情（副标题），默认 `nil`
    ///   - icon: 圆点内的 SF Symbols 图标名，默认 `nil`
    ///   - isDone: 是否已完成，默认 `false`
    public init(id: UUID = UUID(),
                title: String,
                detail: String? = nil,
                icon: String? = nil,
                isDone: Bool = false) {
        self.id = id
        self.title = title
        self.detail = detail
        self.icon = icon
        self.isDone = isDone
    }
}

/// 中文名：时间轴条目（等同 `TimelineItem`）
public typealias 时间轴条目 = TimelineItem

// MARK: - 时间轴

/// 时间轴
///
/// 纵向排列的一串节点，每个节点由「圆点 + 标题 + 可选详情」组成，圆点之间用竖线串联。
/// 已完成节点用主题色（可带图标），未完成节点置灰。适合「物流轨迹 / 审批记录 /
/// 版本变更」这类按时间先后展示的场景。
///
/// - Example:
///   ```swift
///   Timeline(items: [
///       .init(title: "已下单", detail: "09:12", icon: "cart.fill", isDone: true),
///       .init(title: "已发货", detail: "10:30", icon: "shippingbox.fill", isDone: true),
///       .init(title: "运输中", detail: "预计明天送达"),
///   ])
///   ```
public struct Timeline: View {

    /// 节点数组（按时间先后排列）
    private let items: [TimelineItem]
    /// 已完成节点的颜色
    private let tint: Color
    /// 未完成节点的颜色
    private let inactiveColor: Color
    /// 圆点直径
    private let dotSize: CGFloat
    /// 连接线宽度
    private let lineWidth: CGFloat
    /// 是否显示圆点内的图标
    private let showsIcons: Bool
    /// 相邻节点之间的垂直间距
    private let spacing: CGFloat

    /// - Parameters:
    ///   - items: 节点数组（按时间先后排列）
    ///   - tint: 已完成节点的颜色，默认 `.accentColor`
    ///   - inactiveColor: 未完成节点的颜色，默认 `.gray`
    ///   - dotSize: 圆点直径，默认 `24`
    ///   - lineWidth: 连接线宽度，默认 `2`
    ///   - showsIcons: 是否显示圆点内的图标，默认 `true`
    ///   - spacing: 相邻节点之间的垂直间距，默认 `18`
    public init(items: [TimelineItem],
                tint: Color = .accentColor,
                inactiveColor: Color = .gray,
                dotSize: CGFloat = 24,
                lineWidth: CGFloat = 2,
                showsIcons: Bool = true,
                spacing: CGFloat = 18) {
        self.items = items
        self.tint = tint
        self.inactiveColor = inactiveColor
        self.dotSize = dotSize
        self.lineWidth = lineWidth
        self.showsIcons = showsIcons
        self.spacing = spacing
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                TimelineRow(item: item,
                            isLast: index == items.count - 1,
                            tint: tint,
                            inactiveColor: inactiveColor,
                            dotSize: dotSize,
                            lineWidth: lineWidth,
                            showsIcons: showsIcons,
                            spacing: spacing)
            }
        }
    }
}

// MARK: - 单行（内部）

/// 时间轴的单行：左列「圆点 + 连接线」，右侧「标题 + 详情」
///
/// 连接线高度 = 右侧内容高度 + 行间距 - 圆点直径——用 `readSize` 量出内容实际高度后
/// 再补足，这样标题换行、有无详情都能让竖线刚好贯穿到下一个圆点，不留断口。
private struct TimelineRow: View {

    let item: TimelineItem
    let isLast: Bool
    let tint: Color
    let inactiveColor: Color
    let dotSize: CGFloat
    let lineWidth: CGFloat
    let showsIcons: Bool
    let spacing: CGFloat

    /// 右侧内容的实测高度（由 `readSize` 写入）
    @State private var contentHeight: CGFloat = 0

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(spacing: 0) {
                dot
                if !isLast {
                    Rectangle()
                        .fill(lineColor)
                        .frame(width: lineWidth)
                        .frame(height: connectorHeight)
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.subheadline)
                    .fontWeight(item.isDone ? .semibold : .regular)
                    .foregroundStyle(item.isDone ? Color.primary : Color.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                if let detail = item.detail {
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .readSize { contentHeight = $0.height }
            .padding(.bottom, isLast ? 0 : spacing)
            Spacer(minLength: 0)
        }
    }

    /// 连接线高度：内容高度 + 行间距 - 圆点直径，至少留 `8`
    private var connectorHeight: CGFloat {
        max(contentHeight + spacing - dotSize, 8)
    }

    /// 已完成用主题色，未完成置灰
    private var lineColor: Color {
        item.isDone ? tint : inactiveColor.opacity(0.35)
    }

    /// 圆点：有图标时画成带图标的实心圆，否则画一个较小的实心点
    private var dot: some View {
        ZStack {
            if showsIcons, let icon = item.icon {
                Circle().fill(item.isDone ? tint : inactiveColor.opacity(0.35))
                Image(systemName: icon)
                    .font(.system(size: dotSize * 0.45, weight: .semibold))
                    .foregroundStyle(.white)
            } else {
                Circle()
                    .fill(item.isDone ? tint : inactiveColor.opacity(0.35))
                    .frame(width: dotSize * 0.5, height: dotSize * 0.5)
            }
        }
        .frame(width: dotSize, height: dotSize)
    }
}

// MARK: 中文命名别名

/// 中文名：时间轴（等同 `Timeline`）
public typealias 时间轴 = Timeline

public extension TimelineItem {

    /// 时间轴条目（中文参数）
    /// - Parameters:
    ///   - 标题: 标题
    ///   - 详情: 详情（副标题），默认 `nil`
    ///   - 图标: 圆点内的 SF Symbols 图标名，默认 `nil`
    ///   - 已完成: 是否已完成，默认 `false`
    init(标题: String,
         详情: String? = nil,
         图标: String? = nil,
         已完成: Bool = false) {
        self.init(title: 标题, detail: 详情, icon: 图标, isDone: 已完成)
    }
}

public extension Timeline {

    /// 时间轴（中文参数）
    /// - Parameters:
    ///   - 节点: 节点数组（按时间先后排列）
    ///   - 颜色: 已完成节点的颜色，默认 `.accentColor`
    ///   - 未完成颜色: 未完成节点的颜色，默认 `.gray`
    ///   - 圆点尺寸: 圆点直径，默认 `24`
    ///   - 线宽: 连接线宽度，默认 `2`
    ///   - 显示图标: 是否显示圆点内的图标，默认 `true`
    ///   - 间距: 相邻节点之间的垂直间距，默认 `18`
    init(节点: [TimelineItem],
         颜色: Color = .accentColor,
         未完成颜色: Color = .gray,
         圆点尺寸: CGFloat = 24,
         线宽: CGFloat = 2,
         显示图标: Bool = true,
         间距: CGFloat = 18) {
        self.init(items: 节点,
                  tint: 颜色,
                  inactiveColor: 未完成颜色,
                  dotSize: 圆点尺寸,
                  lineWidth: 线宽,
                  showsIcons: 显示图标,
                  spacing: 间距)
    }
}
