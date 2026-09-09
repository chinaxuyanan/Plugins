#if os(iOS)
import SwiftUI
import UIKit

// MARK: - 触觉反馈（仅 iOS）

/// 触觉反馈：封装 UIKit 的振动反馈，见名即用
///
/// 提供冲击、选择、通知三类触感，适用于按钮点击、手势确认、操作结果提示等场景。
/// - `impact`：轻重不等的「点击 / 撞击」感
/// - `selection`：滚轮 / 选择器切换的「咔哒」感
/// - `notification`：成功 / 警告 / 错误的提示感
public enum Haptics {

    /// 冲击强度
    public enum ImpactStyle {
        /// 轻
        case light
        /// 中（默认）
        case medium
        /// 重
        case heavy
        /// 柔和
        case soft
        /// 刚硬
        case rigid
    }

    /// 通知类型
    public enum NotificationType {
        /// 成功
        case success
        /// 警告
        case warning
        /// 错误
        case error
    }

    /// 冲击触感
    /// - Parameter style: 冲击强度，默认 `.medium`
    public static func impact(_ style: ImpactStyle = .medium) {
        UIImpactFeedbackGenerator(style: impactStyle(style)).impactOccurred()
    }

    /// 选择触感（选择器切换的「咔哒」感）
    public static func selection() {
        UISelectionFeedbackGenerator().selectionChanged()
    }

    /// 通知触感
    /// - Parameter type: 成功 / 警告 / 错误，默认 `.success`
    public static func notification(_ type: NotificationType = .success) {
        UINotificationFeedbackGenerator().notificationOccurred(notificationType(type))
    }

    /// 成功触感（等同 `notification(.success)`）
    public static func success() { notification(.success) }

    /// 警告触感（等同 `notification(.warning)`）
    public static func warning() { notification(.warning) }

    /// 错误触感（等同 `notification(.error)`）
    public static func error() { notification(.error) }

    // MARK: 内部映射

    private static func impactStyle(_ style: ImpactStyle) -> UIImpactFeedbackGenerator.FeedbackStyle {
        switch style {
        case .light: return .light
        case .medium: return .medium
        case .heavy: return .heavy
        case .soft: return .soft
        case .rigid: return .rigid
        }
    }

    private static func notificationType(_ type: NotificationType) -> UINotificationFeedbackGenerator.FeedbackType {
        switch type {
        case .success: return .success
        case .warning: return .warning
        case .error: return .error
        }
    }
}

// MARK: - 触觉反馈中文别名

public extension Haptics {
    /// 冲击触感（等同 `impact`）
    /// - Parameter 强度: 冲击强度，默认 `.medium`
    static func 冲击(_ 强度: ImpactStyle = .medium) { impact(强度) }

    /// 选择触感（等同 `selection`）
    static func 选择() { selection() }

    /// 通知触感（等同 `notification`）
    /// - Parameter 类型: 成功 / 警告 / 错误，默认 `.success`
    static func 通知(_ 类型: NotificationType = .success) { notification(类型) }

    /// 成功触感（等同 `success`）
    static func 成功() { success() }

    /// 警告触感（等同 `warning`）
    static func 警告() { warning() }

    /// 错误触感（等同 `error`）
    static func 错误() { error() }
}
#endif
