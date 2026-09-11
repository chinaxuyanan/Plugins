import SwiftUI

// MARK: - 关键词高亮文本

/// 关键词高亮文本
///
/// 把文本中命中指定关键词的片段着色（可加底色、可加粗），多个关键词一次处理，
/// 默认不区分大小写。配合搜索栏做「搜索结果命中词标黄」最合适。
///
/// - Example:
///   ```swift
///   HighlightedText("SwiftUI 的中文封装库", highlights: ["封装", "中文"])
///
///   HighlightedText(内容,
///                   highlights: 搜索词列表,
///                   highlightColor: .orange,
///                   highlightBackground: .yellow.opacity(0.3))
///   ```
public struct HighlightedText: View {

    /// 完整文本
    private let text: String
    /// 要高亮的关键词（空字符串会被忽略）
    private let highlights: [String]
    /// 命中片段的前景色
    private let highlightColor: Color
    /// 命中片段的底色（`nil` 表示不加底色）
    private let highlightBackground: Color?
    /// 命中片段是否加粗
    private let isBold: Bool
    /// 整体字体（`nil` 表示沿用环境字体）
    private let font: Font?
    /// 未命中部分的文字颜色
    private let tint: Color
    /// 是否区分大小写
    private let caseSensitive: Bool

    /// - Parameters:
    ///   - text: 完整文本
    ///   - highlights: 要高亮的关键词数组
    ///   - highlightColor: 命中片段颜色，默认 `.accentColor`
    ///   - highlightBackground: 命中片段底色，默认 `nil`（不加底色）
    ///   - isBold: 命中片段是否加粗，默认 `true`
    ///   - font: 整体字体，默认 `nil`（沿用环境字体）
    ///   - tint: 未命中部分的颜色，默认 `.primary`
    ///   - caseSensitive: 是否区分大小写，默认 `false`
    public init(_ text: String,
                highlights: [String],
                highlightColor: Color = .accentColor,
                highlightBackground: Color? = nil,
                isBold: Bool = true,
                font: Font? = nil,
                tint: Color = .primary,
                caseSensitive: Bool = false) {
        self.text = text
        self.highlights = highlights
        self.highlightColor = highlightColor
        self.highlightBackground = highlightBackground
        self.isBold = isBold
        self.font = font
        self.tint = tint
        self.caseSensitive = caseSensitive
    }

    /// 命中区间（纯逻辑，供测试或外部复用）
    ///
    /// 逐个关键词扫描全文，同一关键词出现多次会全部命中；空关键词与空文本直接跳过。
    /// 结果按起始位置从小到大排序。
    ///
    /// - Parameters:
    ///   - highlights: 关键词数组
    ///   - text: 待扫描的文本
    ///   - caseSensitive: 是否区分大小写，默认 `false`
    /// - Returns: 命中区间数组
    public static func ranges(of highlights: [String],
                              in text: String,
                              caseSensitive: Bool = false) -> [Range<String.Index>] {
        guard !text.isEmpty else { return [] }
        let options: String.CompareOptions = caseSensitive ? [] : [.caseInsensitive]
        var result: [Range<String.Index>] = []
        for keyword in highlights where !keyword.isEmpty {
            var searchStart = text.startIndex
            while searchStart < text.endIndex,
                  let range = text.range(of: keyword, options: options, range: searchStart..<text.endIndex) {
                result.append(range)
                searchStart = range.upperBound
            }
        }
        return result.sorted { $0.lowerBound < $1.lowerBound }
    }

    /// 组装好的富文本
    private var attributed: AttributedString {
        var attr = AttributedString(text)
        for range in Self.ranges(of: highlights, in: text, caseSensitive: caseSensitive) {
            guard let lower = AttributedString.Index(range.lowerBound, within: attr),
                  let upper = AttributedString.Index(range.upperBound, within: attr) else { continue }
            let attrRange = lower..<upper
            attr[attrRange].foregroundColor = highlightColor
            if let background = highlightBackground {
                attr[attrRange].backgroundColor = background
            }
            if isBold {
                // `.stronglyEmphasized` 是 Foundation 的样式意图，Text 渲染时会自动加粗，
                // 不必知道当前字号就能生效（比拼一个具体 Font 更稳）。
                attr[attrRange].inlinePresentationIntent = .stronglyEmphasized
            }
        }
        return attr
    }

    public var body: some View {
        Text(attributed)
            .font(font)
            .foregroundStyle(tint)
    }
}

// MARK: 中文命名别名

/// 中文名：关键词高亮文本（等同 `HighlightedText`）
public typealias 高亮文本 = HighlightedText

public extension HighlightedText {

    /// 关键词高亮文本（中文参数）
    /// - Parameters:
    ///   - 文字: 完整文本
    ///   - 关键词: 要高亮的关键词数组
    ///   - 高亮颜色: 命中片段颜色，默认 `.accentColor`
    ///   - 高亮底色: 命中片段底色，默认 `nil`
    ///   - 加粗: 命中片段是否加粗，默认 `true`
    ///   - 字体: 整体字体，默认 `nil`
    ///   - 颜色: 未命中部分的颜色，默认 `.primary`
    ///   - 区分大小写: 是否区分大小写，默认 `false`
    ///
    /// - Note: 首个参数带 `文字:` 标签——英文 `init` 的首参是无标签的 `String`，
    ///   两个重载若都无标签会报 `ambiguous use of 'init'`。
    init(文字: String,
         关键词: [String],
         高亮颜色: Color = .accentColor,
         高亮底色: Color? = nil,
         加粗: Bool = true,
         字体: Font? = nil,
         颜色: Color = .primary,
         区分大小写: Bool = false) {
        self.init(文字,
                  highlights: 关键词,
                  highlightColor: 高亮颜色,
                  highlightBackground: 高亮底色,
                  isBold: 加粗,
                  font: 字体,
                  tint: 颜色,
                  caseSensitive: 区分大小写)
    }

    /// 命中区间（等同 `ranges(of:in:caseSensitive:)`）
    static func 命中区间(关键词: [String], 文字: String, 区分大小写: Bool = false) -> [Range<String.Index>] {
        ranges(of: 关键词, in: 文字, caseSensitive: 区分大小写)
    }
}
