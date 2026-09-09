import SwiftUI

// MARK: - 输入框

public extension View {

    /// 圆角输入框样式
    ///
    /// 给 `TextField` / `TextEditor` 添加圆角背景和内边距，常见于搜索框、登录框。
    ///
    /// - Parameters:
    ///   - cornerRadius: 圆角半径（单位：pt），默认 `8`。
    ///   - padding: 内边距（单位：pt），默认 `10`。
    ///
    /// - Example:
    ///   ```swift
    ///   TextField("搜索", text: $keyword)
    ///       .inputStyle(cornerRadius: 10)
    ///   ```
    @ViewBuilder
    func inputStyle(cornerRadius: CGFloat = 8, padding: CGFloat = 10) -> some View {
        self.padding(padding)
            .background(Color.cardBackground)
            .clippedToRoundedRect(cornerRadius)
    }
}
