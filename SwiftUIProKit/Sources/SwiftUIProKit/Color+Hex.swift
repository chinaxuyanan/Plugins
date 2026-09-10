import SwiftUI
import Foundation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

// MARK: - 颜色工具

public extension Color {

    /// 用十六进制整数创建颜色
    ///
    /// 传入 `0xRRGGBB` 格式的整数即可得到对应颜色，避免手写 RGB 小数。
    ///
    /// - Parameters:
    ///   - hex: 十六进制颜色值，如 `0xFF5733`
    ///   - alpha: 不透明度，默认 `1`
    ///
    /// - Example:
    ///   ```swift
    ///   Color(hex: 0xFF5733)
    ///   ```
    init(hex: UInt32, alpha: Double = 1) {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        self.init(red: r, green: g, blue: b, opacity: alpha)
    }

    /// 用十六进制字符串创建颜色
    ///
    /// 支持 `"#RRGGBB"`、`"RRGGBB"`、`"#RRGGBBAA"`、`"RRGGBBAA"` 四种格式。
    /// 解析失败时返回黑色。
    ///
    /// - Parameter hexString: 十六进制字符串，如 `"#FF5733"`
    ///
    /// - Example:
    ///   ```swift
    ///   Color(hexString: "#FF5733")
    ///   ```
    init(hexString: String) {
        var s = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        if s.hasPrefix("#") { s.removeFirst() }
        guard s.count == 6 || s.count == 8, let value = UInt64(s, radix: 16) else {
            self.init(red: 0, green: 0, blue: 0, opacity: 1)
            return
        }
        if s.count == 8 {
            self.init(red: Double((value >> 24) & 0xFF) / 255.0,
                      green: Double((value >> 16) & 0xFF) / 255.0,
                      blue: Double((value >> 8) & 0xFF) / 255.0,
                      opacity: Double(value & 0xFF) / 255.0)
        } else {
            self.init(hex: UInt32(value))
        }
    }

    /// 随机颜色
    ///
    /// 返回一个随机 RGB 颜色，适合占位、标签配色等场景。
    ///
    /// - Example:
    ///   ```swift
    ///   Rectangle().fill(Color.random())
    ///   ```
    static func random() -> Color {
        Color(red: .random(in: 0...1),
              green: .random(in: 0...1),
              blue: .random(in: 0...1))
    }

    /// 当前颜色的十六进制字符串（形如 `#FF5733`）
    ///
    /// 把颜色转回十六进制字符串，方便存储、展示或复用。
    /// 无法解析颜色分量时返回空字符串。
    ///
    /// - Example:
    ///   ```swift
    ///   let hex = Color.blue.hexString // "#007AFF"
    ///   ```
    var hexString: String {
        #if canImport(UIKit)
        let uiColor = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) else { return "" }
        #elseif canImport(AppKit)
        guard let rgb = NSColor(self).usingColorSpace(.sRGB) else { return "" }
        let r = rgb.redComponent, g = rgb.greenComponent, b = rgb.blueComponent
        #else
        return ""
        #endif
        func two(_ v: CGFloat) -> String {
            String(Int(v * 255), radix: 16).uppercased().padding(toLength: 2, withPad: "0", startingAt: 0)
        }
        return "#" + two(r) + two(g) + two(b)
    }
}
