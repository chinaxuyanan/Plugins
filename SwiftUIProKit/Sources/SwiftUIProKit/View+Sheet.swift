import SwiftUI

// MARK: - 弹窗

public extension View {

    /// 弹出底部面板
    ///
    /// 以模态方式弹出底部面板，等效于 `.sheet(isPresented:onDismiss:content:)`。
    ///
    /// - Parameters:
    ///   - isPresented: 控制是否显示的绑定值
    ///   - onDismiss: 面板关闭时执行的操作，可为空
    ///   - content: 面板内容
    ///
    /// - Example:
    ///   ```swift
    ///   Button("设置") { showSettings = true }
    ///       .presentSheet(isPresented: $showSettings) { SettingsView() }
    ///   ```
    @ViewBuilder
    func presentSheet<Content: View>(isPresented: Binding<Bool>,
                                     onDismiss: (() -> Void)? = nil,
                                     @ViewBuilder content: @escaping () -> Content) -> some View {
        sheet(isPresented: isPresented, onDismiss: onDismiss, content: content)
    }

    /// 弹出确认提示框
    ///
    /// 弹出带「确定 / 取消」按钮的确认对话框，是系统 `.alert` 的常用封装，
    /// 省去手写 actions / message 的样板代码。
    ///
    /// - Parameters:
    ///   - title: 标题文字
    ///   - message: 提示内容，可为空
    ///   - isPresented: 控制是否显示的绑定值
    ///   - confirmTitle: 确定按钮文字，默认「确定」
    ///   - onConfirm: 点击确定后执行的操作，可为空
    ///
    /// - Example:
    ///   ```swift
    ///   .confirmAlert(title: "确认删除？", message: "删除后不可恢复",
    ///                 isPresented: $showConfirm) { delete() }
    ///   ```
    @ViewBuilder
    func confirmAlert(title: String,
                      message: String? = nil,
                      isPresented: Binding<Bool>,
                      confirmTitle: String = "确定",
                      onConfirm: (() -> Void)? = nil) -> some View {
        alert(Text(title), isPresented: isPresented) {
            if onConfirm != nil {
                Button {
                    onConfirm?()
                } label: {
                    Text(confirmTitle)
                }
            }
            Button("取消", role: .cancel) { }
        } message: {
            if let message = message {
                Text(message)
            }
        }
    }
}
