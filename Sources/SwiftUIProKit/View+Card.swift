import SwiftUI

// MARK: - 复合样式

public extension View {

    /// 卡片样式
    ///
    /// 一键应用常见的卡片外观：圆角背景、内边距和轻阴影。
    ///
    /// - Parameters:
    ///   - cornerRadius: 圆角半径（单位：pt），默认 `16`。
    ///   - padding: 卡片内边距，默认 `16`。
    ///   - shadowLevel: 阴影强度，`1`（轻）、`2`（中）、`3`（强），默认 `2`。
    ///
    /// - Example:
    ///   ```swift
    ///   VStack(alignment: .leading) {
    ///       Text("标题").font(.headline)
    ///       Text("内容")
    ///   }
    ///   .cardStyle()
    ///   ```
    @ViewBuilder
    func cardStyle(cornerRadius: CGFloat = 16,
                   padding: CGFloat = 16,
                   shadowLevel: Int = 2) -> some View {
        self.padding(padding)
            .background(Color.cardBackground)
            .clippedToRoundedRect(cornerRadius)
            .applyShadow(level: shadowLevel)
    }

    /// 徽标样式
    ///
    /// 一键应用徽标（Badge）外观：小圆角胶囊背景 + 内边距，常用于标签、数量提示等。
    ///
    /// - Parameters:
    ///   - color: 徽标背景色，默认 `.red`。
    ///   - textColor: 徽标文字颜色，默认 `.white`。
    ///
    /// - Example:
    ///   ```swift
    ///   Text("99+").badgeStyle(color: .red)
    ///   ```
    @ViewBuilder
    func badgeStyle(color: Color = .red, textColor: Color = .white) -> some View {
        padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color)
            .clippedToRoundedRect(9)
            .foregroundStyle(textColor)
    }
}

private extension View {

    /// 根据级别应用预设阴影
    @ViewBuilder
    func applyShadow(level: Int) -> some View {
        switch level {
        case 1: shadowSm()
        case 3: shadowLg()
        default: shadowMd()
        }
    }
}
