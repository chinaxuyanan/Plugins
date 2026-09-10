import SwiftUI

// MARK: - Toast 轻提示

/// Toast 轻提示的显示位置
public enum ToastPosition {
    /// 顶部
    case top
    /// 底部
    case bottom
}

public extension View {

    /// 轻提示（Toast）
    ///
    /// 当 `message` 绑定值非空时，在视图顶部或底部浮出一条轻提示，自动消失后把绑定值清空。
    ///
    /// - Parameters:
    ///   - message: 提示文字的绑定值；置为非空即弹出，自动消失后自动置回 `nil`
    ///   - position: 显示位置（顶部 / 底部），默认 `.bottom`
    ///   - duration: 展示时长（秒），默认 `2`
    ///   - icon: 可选 SF Symbol 图标名（如 `"checkmark.circle.fill"`），默认 `nil`
    ///
    /// - Example:
    ///   ```swift
    ///   @State private var toast: String?
    ///
    ///   VStack { ... }
    ///       .toast($toast, position: .top, icon: "checkmark.circle.fill")
    ///
    ///   toast = "保存成功"   // 顶部弹出，2 秒后自动消失
    ///   ```
    @ViewBuilder
    func toast(_ message: Binding<String?>,
               position: ToastPosition = .bottom,
               duration: TimeInterval = 2,
               icon: String? = nil) -> some View {
        modifier(ToastModifier(message: message, position: position,
                               duration: duration, icon: icon))
    }
}

/// 轻提示内部实现
private struct ToastModifier: ViewModifier {
    @Binding var message: String?
    let position: ToastPosition
    let duration: TimeInterval
    let icon: String?

    func body(content: Content) -> some View {
        content
            .overlay(alignment: position == .top ? .top : .bottom) {
                if let current = message {
                    toastBar(current)
                        .transition(.move(edge: position == .top ? .top : .bottom)
                                        .combined(with: .opacity))
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.8), value: message)
            .task(id: message) {
                guard message != nil else { return }
                try? await Task.sleep(nanoseconds: UInt64(duration * 1_000_000_000))
                await MainActor.run { message = nil }
            }
    }

    /// 轻提示浮条本体
    private func toastBar(_ text: String) -> some View {
        HStack(spacing: 8) {
            if let icon = icon {
                Image(systemName: icon)
            }
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.regularMaterial, in: Capsule())
        .shadow(radius: 8)
        .padding(.vertical, 24)
    }
}

// MARK: 中文命名别名

/// 中文名：轻提示位置（等同 `ToastPosition`）
public typealias 轻提示位置 = ToastPosition
