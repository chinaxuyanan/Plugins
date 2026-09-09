import SwiftUI

// MARK: - 文字与字体

public extension View {

    /// 设置文字颜色
    ///
    /// 设置视图（通常是 `Text`）的前景色，即文字颜色。
    ///
    /// - Parameter color: 文字颜色。
    ///
    /// - Example:
    ///   ```swift
    ///   Text("标题").textColor(.red)
    ///   ```
    @ViewBuilder
    func textColor(_ color: Color) -> some View {
        foregroundStyle(color)
    }

    /// 设置文字对齐方式
    ///
    /// 设置多行文字在各自行内的水平对齐方式。
    ///
    /// - Parameter alignment: 对齐方式，可选 `.leading`（左对齐）、`.center`（居中）、`.trailing`（右对齐）。
    ///
    /// - Example:
    ///   ```swift
    ///   Text("多行\n文字").textAlignment(.center)
    ///   ```
    @ViewBuilder
    func textAlignment(_ alignment: TextAlignment) -> some View {
        multilineTextAlignment(alignment)
    }

    /// 限制文字最大行数
    ///
    /// 超过指定行数的文字会被截断（默认以省略号结尾）。
    ///
    /// - Parameter count: 最大显示行数。
    ///
    /// - Example:
    ///   ```swift
    ///   Text(longText).maxLines(2)
    ///   ```
    @ViewBuilder
    func maxLines(_ count: Int) -> some View {
        lineLimit(count)
    }

    /// 设置行间距
    ///
    /// 调整多行文字行与行之间的间距。
    ///
    /// - Parameter spacing: 行间距（单位：pt）。
    ///
    /// - Example:
    ///   ```swift
    ///   Text(paragraph).textLineSpacing(6)
    ///   ```
    @ViewBuilder
    func textLineSpacing(_ spacing: CGFloat) -> some View {
        lineSpacing(spacing)
    }

    /// 设置文字加粗
    ///
    /// 将文字设置为粗体，等效于 `.fontWeight(.bold)`。
    ///
    /// - Example:
    ///   ```swift
    ///   Text("重点").boldText()
    ///   ```
    @available(macOS 13.0, *)
    func boldText() -> some View {
        fontWeight(.bold)
    }

    /// 一站式文字样式
    ///
    /// 一次调用完成字体、颜色、字重、对齐、行间距等常用文字样式设置。
    ///
    /// - Parameters:
    ///   - font: 字体，例如 `.title`、`.headline`、`.body`。
    ///   - color: 文字颜色，默认 `.primary`。
    ///   - weight: 字重，默认 `.regular`。
    ///   - alignment: 对齐方式，默认 `.leading`。
    ///   - spacing: 行间距，默认 `0`。
    ///
    /// - Example:
    ///   ```swift
    ///   Text("标题")
    ///       .textStyle(font: .title, color: .blue, weight: .bold)
    ///   ```
    @available(macOS 13.0, *)
    func textStyle(font: Font,
                   color: Color = .primary,
                   weight: Font.Weight = .regular,
                   alignment: TextAlignment = .leading,
                   spacing: CGFloat = 0) -> some View {
        self.font(font)
            .fontWeight(weight)
            .foregroundStyle(color)
            .multilineTextAlignment(alignment)
            .lineSpacing(spacing)
    }
}
