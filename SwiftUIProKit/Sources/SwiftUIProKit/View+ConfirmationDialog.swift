import SwiftUI

// MARK: - 确认弹窗

public extension View {

    /// 确认弹窗
    ///
    /// 以 `confirmationDialog` 形式弹出「确认 / 取消」询问，点击确认后执行动作。
    /// 把「标题 + 确认按钮 + 取消按钮 + 回调」打包成一行调用，避免每次手写一堆 Button。
    ///
    /// - Parameters:
    ///   - title: 弹窗标题
    ///   - isPresented: 是否显示（`Binding`）
    ///   - message: 说明文字，默认 `nil`
    ///   - confirmTitle: 确认按钮文字，默认「确定」
    ///   - role: 确认按钮角色（如 `.destructive` 标红），默认 `nil`
    ///   - action: 点击确认后执行
    ///
    /// - Example:
    ///   ```swift
    ///   @State private var showConfirm = false
    ///
    ///   Button("删除") { showConfirm = true }
    ///       .confirm("确认删除？",
    ///                isPresented: $showConfirm,
    ///                message: "删除后不可恢复",
    ///                confirmTitle: "删除",
    ///                role: .destructive) {
    ///           // 执行删除
    ///       }
    ///   ```
    func confirm(_ title: String,
                 isPresented: Binding<Bool>,
                 message: String? = nil,
                 confirmTitle: String = "确定",
                 role: ButtonRole? = nil,
                 action: @escaping () -> Void) -> some View {
        confirmationDialog(title, isPresented: isPresented, titleVisibility: .visible) {
            Button(confirmTitle, role: role, action: action)
            Button("取消", role: .cancel) {}
        } message: {
            if let message = message {
                Text(message)
            }
        }
    }
}
