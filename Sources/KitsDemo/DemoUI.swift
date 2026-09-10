import SwiftUI
import AppKit
import Foundation

/// 统一卡片容器：标题 + 内容，带浅底与描边，供各分区复用
struct Card<Content: View>: View {
    let title: String
    let content: Content

    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title).font(.headline)
            content
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(nsColor: .controlBackgroundColor))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.secondary.opacity(0.2))
        )
    }
}

/// 字节 / 秒 的人类可读格式（`nil` 表示首次采样、尚无速率）
func bytesPerSecondText(_ value: Double?) -> String {
    guard let v = value else { return "—（首次采样）" }
    let units = ["B/s", "KB/s", "MB/s", "GB/s", "TB/s"]
    var x = v
    var i = 0
    while x >= 1024 && i < units.count - 1 {
        x /= 1024
        i += 1
    }
    return String(format: "%.1f %@", x, units[i])
}

/// 字节数的人类可读格式
func bytesText(_ value: UInt64) -> String {
    let units = ["B", "KB", "MB", "GB", "TB"]
    var x = Double(value)
    var i = 0
    while x >= 1024 && i < units.count - 1 {
        x /= 1024
        i += 1
    }
    return String(format: "%.1f %@", x, units[i])
}
