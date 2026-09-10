import SwiftUI

// MARK: - 水印
//
// 在内容之上平铺一层半透明的倾斜文字水印（如「机密」「仅供内部使用」）。

public extension View {

    /// 平铺水印
    ///
    /// 在视图之上叠加一层倾斜、重复的半透明文字，用作「机密 / 草稿 / 内部资料」等标记。
    /// 水印不参与点击（`allowsHitTesting(false)`），也不改变原视图的布局。
    ///
    /// - Parameters:
    ///   - text: 水印文字（如 `"机密"`）
    ///   - color: 水印颜色，默认浅灰半透明
    ///   - font: 水印字体，默认 `.caption`
    ///   - spacing: 平铺间距（点），默认 `80`
    ///   - angle: 倾斜角度，默认 `-30°`
    ///
    /// - Example:
    ///   ```swift
    ///   documentView.watermark("内部资料")
    ///   ```
    @ViewBuilder
    func watermark(_ text: String,
                   color: Color = .secondary.opacity(0.15),
                   font: Font = .caption,
                   spacing: CGFloat = 80,
                   angle: Angle = .degrees(-30)) -> some View {
        overlay(
            GeometryReader { geo in
                let step = max(1, spacing)
                let cols = Int(geo.size.width / step) + 2
                let rows = Int(geo.size.height / step) + 2
                ZStack {
                    ForEach(0..<rows, id: \.self) { row in
                        ForEach(0..<cols, id: \.self) { col in
                            Text(text)
                                .font(font)
                                .foregroundStyle(color)
                                .fixedSize()
                                .position(x: CGFloat(col) * step,
                                          y: CGFloat(row) * step)
                        }
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
                .rotationEffect(angle)
            }
            .clipped()
            .allowsHitTesting(false)
        )
    }
}

// MARK: 中文命名别名
//
// 水印 的中文别名统一放在 `View+ChineseAlias.swift`。
