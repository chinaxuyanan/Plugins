import SwiftUI

// MARK: - 徽标角标

public extension View {

    /// 角标
    ///
    /// 在视图的某个角落叠加一个小圆角徽标（如未读数量、`NEW` 标签）。
    /// 与 `badgeStyle`（给徽标本身做样式）不同，本方法负责把角标「贴」到任意视图的角落。
    ///
    /// - Parameters:
    ///   - text: 角标文字（如 `"99+"`、`"NEW"`）
    ///   - color: 角标背景色，默认 `.red`
    ///   - textColor: 角标文字颜色，默认 `.white`
    ///   - alignment: 角标贴靠的角落，默认 `.topTrailing`（右上角）
    ///   - offset: 角标相对角落的偏移量，默认略向外移
    ///
    /// - Example:
    ///   ```swift
    ///   Image(systemName: "bell").font(.title)
    ///       .cornerBadge("3")
    ///   ```
    @ViewBuilder
    func cornerBadge(_ text: String,
                     color: Color = .red,
                     textColor: Color = .white,
                     alignment: Alignment = .topTrailing,
                     offset: CGSize = CGSize(width: 6, height: -6)) -> some View {
        self.overlay(alignment: alignment) {
            Text(text)
                .font(.caption2)
                .fontWeight(.semibold)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(color)
                .clippedToRoundedRect(9)
                .foregroundStyle(textColor)
                .offset(x: offset.width, y: offset.height)
        }
    }
}
