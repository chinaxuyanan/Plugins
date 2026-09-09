import SwiftUI

// MARK: - 图片

public extension Image {

    /// 自适应缩放图片（保持比例）
    ///
    /// 等效于 `.resizable().scaledToFit()`：图片按原始宽高比缩放，完整显示在容器内。
    ///
    /// - Example:
    ///   ```swift
    ///   Image("photo").fitImage()
    ///   ```
    @ViewBuilder
    func fitImage() -> some View {
        resizable().scaledToFit()
    }

    /// 填充缩放图片（保持比例、裁切）
    ///
    /// 等效于 `.resizable().scaledToFill()`：图片按原始宽高比缩放并填满容器，超出部分裁切。
    ///
    /// - Example:
    ///   ```swift
    ///   Image("photo").fillImage()
    ///   ```
    @ViewBuilder
    func fillImage() -> some View {
        resizable().scaledToFill()
    }

    /// 圆形图片
    ///
    /// 将图片缩放并裁切成圆形，常用于头像、圆形图标。
    ///
    /// - Parameter size: 圆形直径（单位：pt）。
    ///
    /// - Example:
    ///   ```swift
    ///   Image("avatar").circleImage(size: 64)
    ///   ```
    @ViewBuilder
    func circleImage(size: CGFloat) -> some View {
        resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size, height: size)
            .clipShape(Circle())
    }

    /// 圆角图片
    ///
    /// 将图片缩放并裁切成指定圆角，适合封面、缩略图等。
    ///
    /// - Parameters:
    ///   - cornerRadius: 圆角半径（单位：pt）。
    ///   - size: 可选，指定图片的宽高（单位：pt），不传则保持容器尺寸。
    ///
    /// - Example:
    ///   ```swift
    ///   Image("cover").roundedImage(cornerRadius: 12, size: 80)
    ///   ```
    @ViewBuilder
    func roundedImage(cornerRadius: CGFloat, size: CGFloat? = nil) -> some View {
        resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}
