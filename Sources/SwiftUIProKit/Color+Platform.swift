import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - 跨平台颜色

public extension Color {

    /// 系统背景色（跨平台）
    ///
    /// 返回适合作为界面背景的系统标准背景色，自动适配深色 / 浅色模式：
    /// - iOS / iPadOS：`UIColor.systemBackground`
    /// - macOS：`NSColor.windowBackgroundColor`
    static var systemBackground: Color {
        #if canImport(UIKit)
        Color(.systemBackground)
        #elseif canImport(AppKit)
        Color(.windowBackgroundColor)
        #else
        .white
        #endif
    }

    /// 卡片背景色（跨平台）
    ///
    /// 返回适合作为卡片（Card）等浮起元素的背景色，自动适配深色 / 浅色模式：
    /// - iOS / iPadOS：`UIColor.systemBackground`
    /// - macOS：`NSColor.controlBackgroundColor`
    static var cardBackground: Color {
        #if canImport(UIKit)
        Color(.systemBackground)
        #elseif canImport(AppKit)
        Color(.controlBackgroundColor)
        #else
        .white
        #endif
    }
}
