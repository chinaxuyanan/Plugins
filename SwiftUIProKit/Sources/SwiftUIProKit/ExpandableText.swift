import SwiftUI

// MARK: - 展开收起文本

/// 展开收起文本
///
/// 长文本默认只显示 `lineLimit` 行，确实被截断时在下方追加「展开 / 收起」按钮；
/// 内容没超出时不显示按钮（不会出现「文字完整却挂着展开按钮」的尴尬）。
///
/// 判断是否截断的办法是并排藏两段不可见文本：一段限行、一段不限行，分别量出高度后比对。
/// 所以换字体、调行距、改宽度、转屏之后都会重新判定，不依赖「预估字数」这类近似假设。
///
/// - Example:
///   ```swift
///   ExpandableText("这是一段很长的商品简介……", lineLimit: 3)
///
///   ExpandableText(简介,
///                  lineLimit: 2,
///                  expandTitle: "查看全部",
///                  collapseTitle: "收起内容")
///   ```
public struct ExpandableText: View {

    /// 完整文本
    private let text: String
    /// 收起时最多显示的行数
    private let lineLimit: Int
    /// 字体
    private let font: Font
    /// 文字颜色
    private let tint: Color
    /// 行间距
    private let lineSpacing: CGFloat
    /// 展开按钮文字
    private let expandTitle: String
    /// 收起按钮文字
    private let collapseTitle: String
    /// 按钮文字颜色
    private let buttonTint: Color
    /// 是否显示按钮右侧的箭头图标
    private let showsIcon: Bool

    /// 当前是否展开
    @State private var isExpanded = false
    /// 限行后的隐藏文本高度
    @State private var limitedHeight: CGFloat = 0
    /// 不限行时的隐藏文本高度
    @State private var fullHeight: CGFloat = 0

    /// - Parameters:
    ///   - text: 完整文本
    ///   - lineLimit: 收起时最多显示的行数，默认 `3`（小于 `1` 时按 `1` 处理）
    ///   - font: 字体，默认 `.body`
    ///   - tint: 文字颜色，默认 `.primary`
    ///   - lineSpacing: 行间距，默认 `2`
    ///   - expandTitle: 展开按钮文字，默认「展开」
    ///   - collapseTitle: 收起按钮文字，默认「收起」
    ///   - buttonTint: 按钮文字颜色，默认 `.accentColor`
    ///   - showsIcon: 是否显示按钮右侧的箭头图标，默认 `true`
    public init(_ text: String,
                lineLimit: Int = 3,
                font: Font = .body,
                tint: Color = .primary,
                lineSpacing: CGFloat = 2,
                expandTitle: String = "展开",
                collapseTitle: String = "收起",
                buttonTint: Color = .accentColor,
                showsIcon: Bool = true) {
        self.text = text
        self.lineLimit = max(1, lineLimit)
        self.font = font
        self.tint = tint
        self.lineSpacing = lineSpacing
        self.expandTitle = expandTitle
        self.collapseTitle = collapseTitle
        self.buttonTint = buttonTint
        self.showsIcon = showsIcon
    }

    /// 是否确实被截断（留 0.5 点容差，避免像素舍入把「刚好放得下」误判成截断）
    private var isTruncated: Bool {
        fullHeight > 0 && limitedHeight > 0 && fullHeight > limitedHeight + 0.5
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(text)
                .font(font)
                .foregroundStyle(tint)
                .lineSpacing(lineSpacing)
                .lineLimit(isExpanded ? nil : lineLimit)
                .background(sizeProbe)

            if isTruncated {
                Button(action: toggle) {
                    HStack(spacing: 2) {
                        Text(isExpanded ? collapseTitle : expandTitle)
                        if showsIcon {
                            Image(systemName: "chevron.down")
                                .font(.caption2)
                                .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        }
                    }
                    .font(.footnote)
                    .foregroundStyle(buttonTint)
                }
                .buttonStyle(.plain)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isExpanded)
    }

    /// 隐藏的两段测量文本：都拿与正文相同的宽度，一段限行、一段不限行，
    /// 高度不等就说明限行确实截掉了内容。用 `.hidden()` 所以不参与显示、也不影响布局尺寸。
    private var sizeProbe: some View {
        ZStack {
            Text(text)
                .font(font)
                .lineSpacing(lineSpacing)
                .lineLimit(lineLimit)
                .fixedSize(horizontal: false, vertical: true)
                .hidden()
                .readSize { limitedHeight = $0.height }

            Text(text)
                .font(font)
                .lineSpacing(lineSpacing)
                .fixedSize(horizontal: false, vertical: true)
                .hidden()
                .readSize { fullHeight = $0.height }
        }
    }

    /// 切换展开 / 收起
    private func toggle() {
        isExpanded.toggle()
    }
}

// MARK: 中文命名别名

/// 中文名：展开收起文本（等同 `ExpandableText`）
public typealias 展开文本 = ExpandableText

public extension ExpandableText {

    /// 展开收起文本（中文参数）
    /// - Parameters:
    ///   - 文字: 完整文本
    ///   - 行数: 收起时最多显示的行数，默认 `3`
    ///   - 字体: 字体，默认 `.body`
    ///   - 颜色: 文字颜色，默认 `.primary`
    ///   - 行间距: 行间距，默认 `2`
    ///   - 展开文字: 展开按钮文字，默认「展开」
    ///   - 收起文字: 收起按钮文字，默认「收起」
    ///   - 按钮颜色: 按钮文字颜色，默认 `.accentColor`
    ///   - 显示图标: 是否显示按钮右侧的箭头图标，默认 `true`
    ///
    /// - Note: 首个参数带 `文字:` 标签——英文 `init` 的首参是无标签的 `String`，
    ///   两个重载若都无标签，`展开文本("x")` 会报 `ambiguous use of 'init'`。
    init(文字: String,
         行数: Int = 3,
         字体: Font = .body,
         颜色: Color = .primary,
         行间距: CGFloat = 2,
         展开文字: String = "展开",
         收起文字: String = "收起",
         按钮颜色: Color = .accentColor,
         显示图标: Bool = true) {
        self.init(文字,
                  lineLimit: 行数,
                  font: 字体,
                  tint: 颜色,
                  lineSpacing: 行间距,
                  expandTitle: 展开文字,
                  collapseTitle: 收起文字,
                  buttonTint: 按钮颜色,
                  showsIcon: 显示图标)
    }
}
