import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

// MARK: - 键盘与焦点

public extension View {

    /// 点击空白处收起键盘
    ///
    /// 给视图加一层点击手势，点击时让输入框失焦、收起键盘。仅 iOS 生效，macOS 下无操作。
    ///
    /// - Example:
    ///   ```swift
    ///   Form { ... }
    ///       .dismissKeyboardOnTap()
    ///   ```
    @ViewBuilder
    func dismissKeyboardOnTap() -> some View {
        #if canImport(UIKit)
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                            to: nil, from: nil, for: nil)
        }
        #else
        self
        #endif
    }

    /// 键盘工具栏「完成」按钮
    ///
    /// 给输入框在键盘上方加一个「完成」按钮，点击即收起键盘。仅 iOS 生效。
    ///
    /// - Parameter title: 按钮文字，默认「完成」
    ///
    /// - Example:
    ///   ```swift
    ///   TextField("输入", text: $text)
    ///       .keyboardToolbarDone()
    ///   ```
    @ViewBuilder
    func keyboardToolbarDone(title: String = "完成") -> some View {
        #if canImport(UIKit)
        toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(title) {
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                                    to: nil, from: nil, for: nil)
                }
            }
        }
        #else
        self
        #endif
    }

    /// TextEditor 占位文字
    ///
    /// 系统 `TextEditor` 没有自带占位，本方法在文本为空时叠加显示灰色提示文字。
    ///
    /// - Parameters:
    ///   - text: 占位文字内容
    ///   - isEmpty: 内容是否为空（传绑定文本是否为空）
    ///
    /// - Example:
    ///   ```swift
    ///   TextEditor(text: $notes)
    ///       .textEditorPlaceholder("写点什么...", isEmpty: notes.isEmpty)
    ///   ```
    @ViewBuilder
    func textEditorPlaceholder(_ text: String, isEmpty: Bool) -> some View {
        overlay(alignment: .topLeading) {
            if isEmpty {
                Text(text)
                    .foregroundStyle(.tertiary)
                    .padding(.top, 8)
                    .padding(.leading, 5)
            }
        }
    }
}
