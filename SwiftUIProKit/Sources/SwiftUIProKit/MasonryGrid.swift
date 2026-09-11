import SwiftUI

// MARK: - 瀑布流布局（不等高多列）

/// 瀑布流布局：把子视图按「谁矮往谁那儿放」填进多列，各列高度不必对齐
///
/// 与 `FlowLayout`（流式布局）的区别：`FlowLayout` 是**先行后列**、每行等高（tag 云那种），
/// 本布局是**先列后行**、列内堆叠不等高（小红书 / Pinterest 那种）。
/// 「谁矮往谁那儿放」保证各列高度尽量接近，不会出现一列拖到底、另一列空一半。
///
/// 基于 iOS 16 / macOS 13 的 `Layout` 协议实现。
///
/// - Example:
///   ```swift
///   ScrollView {
///       MasonryGrid(columns: 2, spacing: 10, lineSpacing: 10) {
///           ForEach(items) { item in
///               CardView(item)          // 高度随内容不同
///           }
///       }
///   }
///   ```
/// 中文名 `瀑布流` 与 `MasonryGrid` 等价：`瀑布流(列数: 2, 间距: 10) { ... }`。
@available(iOS 16.0, macOS 13.0, *)
public struct MasonryGrid: Layout {

    /// 列数（小于 1 时按 1 处理）
    public var columns: Int
    /// 列与列之间的横向间距（默认 `8`）
    public var spacing: CGFloat
    /// 同一列内上下两个子视图之间的纵向间距（默认 `8`）
    public var lineSpacing: CGFloat

    /// 创建瀑布流布局
    /// - Parameters:
    ///   - columns: 列数（小于 1 时按 1 处理），默认 `2`
    ///   - spacing: 列与列之间的横向间距，默认 `8`
    ///   - lineSpacing: 同列内上下间距，默认 `8`
    public init(columns: Int = 2, spacing: CGFloat = 8, lineSpacing: CGFloat = 8) {
        self.columns = columns
        self.spacing = spacing
        self.lineSpacing = lineSpacing
    }

    // MARK: - 核心逻辑（可单测）

    /// 在「当前最矮的列」里挑一列放下一项，返回列号
    ///
    /// 传入各列当前累计高度。并列最矮时取**最靠左**的一列——这条规则让相同输入永远得到
    /// 相同的摆放结果，不会因为字典 / 集合的遍历顺序不同而抖动。
    ///
    /// - Parameter heights: 各列当前累计高度
    /// - Returns: 应放入的列号；空数组返回 `0`
    public static func shortestColumnIndex(in heights: [CGFloat]) -> Int {
        guard !heights.isEmpty else { return 0 }
        var bestIndex = 0
        var bestHeight = heights[0]
        for (index, height) in heights.enumerated() where height < bestHeight {
            bestIndex = index
            bestHeight = height
        }
        return bestIndex
    }

    // MARK: - Layout

    public func sizeThatFits(proposal: ProposedViewSize,
                             subviews: Subviews,
                             cache: inout ()) -> CGSize {
        guard !subviews.isEmpty else { return .zero }
        let width = proposal.width ?? intrinsicWidth(subviews: subviews)
        return arrangement(totalWidth: width, subviews: subviews).size
    }

    public func placeSubviews(in bounds: CGRect,
                              proposal: ProposedViewSize,
                              subviews: Subviews,
                              cache: inout ()) {
        guard !subviews.isEmpty else { return }
        let width = proposal.width ?? bounds.width
        for item in arrangement(totalWidth: width, subviews: subviews).placements {
            subviews[item.index].place(
                at: CGPoint(x: bounds.minX + item.origin.x, y: bounds.minY + item.origin.y),
                anchor: .topLeading,
                proposal: ProposedViewSize(item.size)
            )
        }
    }

    // MARK: - 内部计算

    /// 一次摆放的结果
    private struct Placement {
        /// 子视图在 `Subviews` 里的下标
        let index: Int
        /// 该子视图被分到的尺寸
        let size: CGSize
        /// 相对容器左上角的坐标
        let origin: CGPoint
    }

    /// 没有拿到确定宽度时，用「最宽子视图 × 列数」估一个总宽
    ///
    /// `sizeThatFits` 的 proposal 宽度可能是 `nil`（父视图不给约束），此时若不兜底，
    /// 列宽会算成 `infinity`，子视图全部塌成 0 高。
    private func intrinsicWidth(subviews: Subviews) -> CGFloat {
        let count = max(1, columns)
        let widest = subviews.map { $0.sizeThatFits(.unspecified).width }.max() ?? 0
        return widest * CGFloat(count) + spacing * CGFloat(count - 1)
    }

    /// 把子视图依次放进各列，返回每项的位置与整体尺寸
    private func arrangement(totalWidth: CGFloat,
                             subviews: Subviews) -> (placements: [Placement], size: CGSize) {
        let count = max(1, columns)
        let columnWidth = max(0, (totalWidth - spacing * CGFloat(count - 1)) / CGFloat(count))
        var heights = [CGFloat](repeating: 0, count: count)
        var placements: [Placement] = []
        placements.reserveCapacity(subviews.count)

        for (index, subview) in subviews.enumerated() {
            // 只约束宽度，高度交给子视图自己定——这正是「不等高」的来源
            let size = subview.sizeThatFits(ProposedViewSize(width: columnWidth, height: nil))
            let column = Self.shortestColumnIndex(in: heights)
            let y = heights[column]
            placements.append(Placement(index: index,
                                        size: size,
                                        origin: CGPoint(x: CGFloat(column) * (columnWidth + spacing),
                                                        y: y)))
            heights[column] = y + size.height + lineSpacing
        }

        // 收尾时每列都多算了一个 lineSpacing，取最高列减掉它才是真实内容高度
        let contentHeight = heights.map { max(0, $0 - lineSpacing) }.max() ?? 0
        return (placements, CGSize(width: totalWidth, height: contentHeight))
    }
}

// MARK: 中文命名别名

/// 中文名：瀑布流（等同 `MasonryGrid`）
@available(iOS 16.0, macOS 13.0, *)
public typealias 瀑布流 = MasonryGrid

@available(iOS 16.0, macOS 13.0, *)
public extension MasonryGrid {

    /// 瀑布流（中文参数）
    ///
    /// 首参 `列数` 无默认值：这样 `MasonryGrid()` 不会与英文 `init(columns:spacing:lineSpacing:)`
    /// （参数全有默认值）产生「歧义调用」。
    ///
    /// - Parameters:
    ///   - 列数: 列数（小于 1 时按 1 处理）
    ///   - 间距: 列与列之间的横向间距，默认 `8`
    ///   - 行间距: 同列内上下间距，默认 `8`
    init(列数: Int, 间距: CGFloat = 8, 行间距: CGFloat = 8) {
        self.init(columns: 列数, spacing: 间距, lineSpacing: 行间距)
    }

    /// 挑最矮的列（等同 `shortestColumnIndex(in:)`）
    static func 最矮列(高度: [CGFloat]) -> Int {
        shortestColumnIndex(in: 高度)
    }
}
