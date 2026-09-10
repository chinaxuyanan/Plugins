import SwiftUI

// MARK: - 流式布局（标签自动换行）

/// 流式布局：让子视图像标签一样自动换行排列
///
/// 基于 iOS 16 / macOS 13 的 `Layout` 协议实现，用于标签云、筛选条件、关键词列表等
/// 「子视图数量不定、宽度不一、需要自动换行」的场景。
///
/// 快速开始：
/// ```swift
/// FlowLayout(spacing: 8, lineSpacing: 8) {
///     ForEach(tags, id: \.self) { tag in
///         Text(tag).padding(.horizontal, 12).padding(.vertical, 6)
///             .background(.gray.opacity(0.2), in: Capsule())
///     }
/// }
/// ```
/// 中文名 `流式布局` 与 `FlowLayout` 等价，可用 `流式布局(间距: 行间距:) { ... }`。
@available(iOS 16.0, macOS 13.0, *)
public struct FlowLayout: Layout {

    /// 同行相邻子视图的间距（默认 `8`）
    public var spacing: CGFloat
    /// 行与行之间的间距（默认 `8`）
    public var lineSpacing: CGFloat

    /// 创建流式布局
    /// - Parameters:
    ///   - spacing: 同行相邻子视图的间距，默认 `8`
    ///   - lineSpacing: 行与行之间的间距，默认 `8`
    public init(spacing: CGFloat = 8, lineSpacing: CGFloat = 8) {
        self.spacing = spacing
        self.lineSpacing = lineSpacing
    }

    public func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var totalWidth: CGFloat = 0
        var totalHeight: CGFloat = 0
        var lineWidth: CGFloat = 0
        var lineHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if lineWidth + size.width > maxWidth, lineWidth > 0 {
                totalWidth = max(totalWidth, lineWidth)
                totalHeight += lineHeight + lineSpacing
                lineWidth = size.width
                lineHeight = size.height
            } else {
                lineWidth += (lineWidth > 0 ? spacing : 0) + size.width
                lineHeight = max(lineHeight, size.height)
            }
        }
        totalWidth = max(totalWidth, lineWidth)
        totalHeight += lineHeight
        return CGSize(width: proposal.width ?? totalWidth, height: proposal.height ?? totalHeight)
    }

    public func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var lineHeight: CGFloat = 0
        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > bounds.maxX, x > bounds.minX {
                x = bounds.minX
                y += lineHeight + lineSpacing
                lineHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), anchor: .topLeading, proposal: ProposedViewSize(size))
            lineHeight = max(lineHeight, size.height)
            x += size.width + spacing
        }
    }
}

/// 中文命名别名（等同 `FlowLayout`）
@available(iOS 16.0, macOS 13.0, *)
public typealias 流式布局 = FlowLayout

@available(iOS 16.0, macOS 13.0, *)
public extension FlowLayout {
    /// 中文参数初始化（等同 `init(spacing:lineSpacing:)`）
    ///
    /// 首参 `间距` 无默认值：这样 `FlowLayout()`（以及 `FlowLayout() { ... }`）才不会与
    /// 英文 `init(spacing:lineSpacing:)`（参数全有默认值）产生「歧义调用」。
    /// 只想改行间距时可写 `流式布局(间距: 8, 行间距: 20)`。
    ///
    /// - Parameters:
    ///   - 间距: 同行相邻子视图的间距，默认 `8`
    ///   - 行间距: 行与行之间的间距，默认 `8`
    init(间距: CGFloat, 行间距: CGFloat = 8) {
        self.init(spacing: 间距, lineSpacing: 行间距)
    }
}
