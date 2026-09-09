import SwiftUI

// MARK: - 弹窗进阶（多按钮 / 动作菜单 / 气泡 / 右键菜单）

public extension View {

    /// 多按钮弹窗：自定义任意按钮组合的 `alert`
    ///
    /// 原生 `.alert` 的多按钮写法较长，这里把「标题 + 说明 + 任意按钮组」收成一个语义化方法。
    /// - Parameters:
    ///   - title: 弹窗标题
    ///   - message: 弹窗说明文字（可选）
    ///   - isPresented: 是否显示
    ///   - actions: 按钮组（可用 `Button`，配合 `role: .cancel` / `.destructive`）
    ///
    /// - Example:
    ///   ```swift
    ///   .multiAlert("删除记录", message: "删除后不可恢复", isPresented: $show) {
    ///       Button("删除", role: .destructive) { delete() }
    ///       Button("取消", role: .cancel) { }
    ///   }
    ///   ```
    func multiAlert<Actions: View>(_ title: String,
                                   message: String? = nil,
                                   isPresented: Binding<Bool>,
                                   @ViewBuilder actions: @escaping () -> Actions) -> some View {
        alert(title, isPresented: isPresented) {
            actions()
        } message: {
            if let message = message { Text(message) }
        }
    }

    /// 破坏性操作确认弹窗（红色删除按钮）
    ///
    /// 适合「删除 / 清空 / 退出登录」这类不可逆操作，把破坏性按钮染红、取消置灰。
    /// - Parameters:
    ///   - title: 弹窗标题
    ///   - message: 说明文字（可选）
    ///   - isPresented: 是否显示
    ///   - destructiveTitle: 破坏性按钮文字，默认「删除」
    ///   - onDestructive: 点击破坏性按钮执行的操作
    ///   - cancelTitle: 取消按钮文字，默认「取消」
    func destructiveAlert(_ title: String,
                          message: String? = nil,
                          isPresented: Binding<Bool>,
                          destructiveTitle: String = "删除",
                          onDestructive: @escaping () -> Void,
                          cancelTitle: String = "取消") -> some View {
        alert(title, isPresented: isPresented) {
            Button(destructiveTitle, role: .destructive, action: onDestructive)
            Button(cancelTitle, role: .cancel) { }
        } message: {
            if let message = message { Text(message) }
        }
    }

    /// 动作菜单（等同 `.confirmationDialog`）
    ///
    /// iPhone 上是底部弹出的动作菜单，iPad / macOS 上锚定到触发点。
    /// - Parameters:
    ///   - title: 菜单标题
    ///   - isPresented: 是否显示
    ///   - titleVisibility: 标题可见性，默认 `.automatic`
    ///   - actions: 动作按钮组
    func actionDialog<Actions: View>(_ title: String,
                                     isPresented: Binding<Bool>,
                                     titleVisibility: Visibility = .automatic,
                                     @ViewBuilder actions: @escaping () -> Actions) -> some View {
        confirmationDialog(title, isPresented: isPresented, titleVisibility: titleVisibility) {
            actions()
        }
    }

    /// 气泡弹窗（等同 `.popover`）
    ///
    /// 在 iPad / macOS 上以气泡形式弹出，锚定到当前视图。
    /// - Parameters:
    ///   - isPresented: 是否显示
    ///   - arrowEdge: 气泡箭头方向，默认 `.top`
    ///   - content: 气泡内容
    func showPopover<Content: View>(isPresented: Binding<Bool>,
                                    arrowEdge: Edge = .top,
                                    @ViewBuilder content: @escaping () -> Content) -> some View {
        popover(isPresented: isPresented, arrowEdge: arrowEdge) { content() }
    }

    /// 右键 / 长按菜单（等同 `.contextMenu`）
    ///
    /// macOS 上右键、iOS 上长按触发。
    /// - Parameter menuItems: 菜单项
    func contextualMenu<MenuItems: View>(@ViewBuilder menuItems: @escaping () -> MenuItems) -> some View {
        contextMenu { menuItems() }
    }
}
