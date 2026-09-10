import SwiftUI
import CoreImage
#if canImport(UIKit)
import UIKit
#endif
#if canImport(AppKit)
import AppKit
#endif

// MARK: - 二维码生成

/// 二维码纠错级别（越高容错越强，图案越密）
public enum QRCodeCorrectionLevel: String {
    /// 低（约 7% 纠错）
    case l = "L"
    /// 中（约 15% 纠错）
    case m = "M"
    /// 四分位（约 25% 纠错）
    case q = "Q"
    /// 高（约 30% 纠错）
    case h = "H"
}

/// 中文名：二维码纠错级别（等同 `QRCodeCorrectionLevel`）
public typealias 二维码纠错级别 = QRCodeCorrectionLevel

public extension Image {

    /// 由字符串生成二维码图片
    ///
    /// 基于 Core Image 的 `CIQRCodeGenerator` 生成，跨平台（iOS / macOS）。
    ///
    /// - Parameters:
    ///   - text: 要编码的字符串
    ///   - scale: 每个码点的放大倍数（默认 `10`，控制图片像素尺寸）
    ///   - correctionLevel: 纠错级别，默认 `.m`
    /// - Returns: 二维码图片；字符串为空或编码失败时返回 `nil`
    ///
    /// - Example:
    ///   ```swift
    ///   if let qr = Image.qrCode("https://example.com", scale: 12) {
    ///       qr.interpolation(.none)   // 关闭抗锯齿，保持码点锐利
    ///           .resizable().scaledToFit().frame(width: 160, height: 160)
    ///   }
    ///   ```
    @MainActor
    static func qrCode(_ text: String, scale: CGFloat = 10, correctionLevel: QRCodeCorrectionLevel = .m) -> Image? {
        guard !text.isEmpty, scale > 0 else { return nil }
        guard let filter = CIFilter(name: "CIQRCodeGenerator") else { return nil }
        filter.setValue(Data(text.utf8), forKey: "inputMessage")
        filter.setValue(correctionLevel.rawValue, forKey: "inputCorrectionLevel")
        guard let output = filter.outputImage else { return nil }

        let scaled = output.transformed(by: CGAffineTransform(scaleX: scale, y: scale))
        let context = CIContext()
        guard let cg = context.createCGImage(scaled, from: scaled.extent) else { return nil }

        #if canImport(UIKit)
        return Image(uiImage: UIImage(cgImage: cg))
        #elseif canImport(AppKit)
        return Image(nsImage: NSImage(cgImage: cg, size: NSSize(width: cg.width, height: cg.height)))
        #else
        return nil
        #endif
    }
}

// MARK: 中文命名别名

public extension Image {
    /// 由字符串生成二维码图片（等同 `qrCode`，中文参数）
    /// - Parameters:
    ///   - 文本: 要编码的字符串
    ///   - 缩放: 每个码点的放大倍数，默认 `10`
    ///   - 纠错级别: 纠错级别，默认 `.m`
    @MainActor
    static func 二维码(_ 文本: String, 缩放: CGFloat = 10, 纠错级别: QRCodeCorrectionLevel = .m) -> Image? {
        qrCode(文本, scale: 缩放, correctionLevel: 纠错级别)
    }
}
