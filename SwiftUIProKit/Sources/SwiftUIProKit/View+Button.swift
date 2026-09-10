import SwiftUI

// MARK: - 按钮样式

public extension View {

    /// 填充按钮样式
    ///
    /// 一键应用圆角填充按钮外观：彩色背景、内边距，按压时变淡 + 轻微缩放反馈。
    /// 适合主按钮、胶囊按钮等场景。
    ///
    /// - Parameters:
    ///   - background: 背景色，默认 `.accentColor`。
    ///   - foreground: 文字颜色，默认 `.white`。
    ///   - cornerRadius: 圆角半径（单位：pt），默认 `10`。
    ///
    /// - Example:
    ///   ```swift
    ///   Button("登录") { }.filledButtonStyle()
    ///   ```
    func filledButtonStyle(background: Color = .accentColor,
                           foreground: Color = .white,
                           cornerRadius: CGFloat = 10) -> some View {
        buttonStyle(FilledButtonStyle(background: background,
                                      foreground: foreground,
                                      cornerRadius: cornerRadius))
    }
}

/// 填充按钮样式实现
public struct FilledButtonStyle: ButtonStyle {
    /// 背景色
    public var background: Color
    /// 文字颜色
    public var foreground: Color
    /// 圆角半径
    public var cornerRadius: CGFloat

    public init(background: Color = .accentColor,
                foreground: Color = .white,
                cornerRadius: CGFloat = 10) {
        self.background = background
        self.foreground = foreground
        self.cornerRadius = cornerRadius
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(foreground)
            .padding(.horizontal, 20)
            .padding(.vertical, 10)
            .background(background.opacity(configuration.isPressed ? 0.7 : 1))
            .clippedToRoundedRect(cornerRadius)
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
