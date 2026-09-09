import SwiftUI

// MARK: - 形状与裁剪
//
// 圆形、胶囊、部分圆角、虚线边框、蒙版等形状相关属性的语义化封装。

/// 圆角位置集合
///
/// 用于指定哪些角需要圆角，支持任意组合。
public struct RectCorner: OptionSet {
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }

    public static let topLeft     = RectCorner(rawValue: 1 << 0)
    public static let topRight    = RectCorner(rawValue: 1 << 1)
    public static let bottomLeft  = RectCorner(rawValue: 1 << 2)
    public static let bottomRight = RectCorner(rawValue: 1 << 3)

    public static let allCorners: RectCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
    public static let top: RectCorner = [.topLeft, .topRight]
    public static let bottom: RectCorner = [.bottomLeft, .bottomRight]
}

/// 指定角圆角形状
///
/// 只对指定位置的角做圆角处理，用于「只圆上面两个角」这类需求。
public struct RoundedCorner: Shape {
    var radius: CGFloat
    var corners: RectCorner

    public init(radius: CGFloat = 8, corners: RectCorner = .allCorners) {
        self.radius = radius
        self.corners = corners
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let r = min(radius, min(rect.width, rect.height) / 2)
        let tl = corners.contains(.topLeft) ? r : 0
        let tr = corners.contains(.topRight) ? r : 0
        let bl = corners.contains(.bottomLeft) ? r : 0
        let br = corners.contains(.bottomRight) ? r : 0

        path.move(to: CGPoint(x: rect.minX + tl, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - tr, y: rect.minY))
        if tr > 0 {
            path.addArc(center: CGPoint(x: rect.maxX - tr, y: rect.minY + tr), radius: tr,
                        startAngle: .degrees(-90), endAngle: .degrees(0), clockwise: false)
        }
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - br))
        if br > 0 {
            path.addArc(center: CGPoint(x: rect.maxX - br, y: rect.maxY - br), radius: br,
                        startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        }
        path.addLine(to: CGPoint(x: rect.minX + bl, y: rect.maxY))
        if bl > 0 {
            path.addArc(center: CGPoint(x: rect.minX + bl, y: rect.maxY - bl), radius: bl,
                        startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        }
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + tl))
        if tl > 0 {
            path.addArc(center: CGPoint(x: rect.minX + tl, y: rect.minY + tl), radius: tl,
                        startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        }
        path.closeSubpath()
        return path
    }
}

public extension View {

    /// 圆形裁剪
    ///
    /// 把视图裁成圆形，等效于 `.clipShape(Circle())`。
    ///
    /// - Example:
    ///   ```swift
    ///   Image("avatar").circleClip()
    ///   ```
    @ViewBuilder
    func circleClip() -> some View {
        clipShape(Circle())
    }

    /// 胶囊形裁剪
    ///
    /// 把视图裁成胶囊形，等效于 `.clipShape(Capsule())`。
    @ViewBuilder
    func capsuleClip() -> some View {
        clipShape(Capsule())
    }

    /// 指定角的圆角裁剪
    ///
    /// 只对指定位置做圆角，等效于 `.clipShape(RoundedCorner(...))`。
    ///
    /// - Parameters:
    ///   - radius: 圆角半径
    ///   - corners: 要圆角的位置，默认 `.allCorners`
    ///
    /// - Example:
    ///   ```swift
    ///   Text("只圆上面").roundedCorners(12, corners: .top)
    ///   ```
    @ViewBuilder
    func roundedCorners(_ radius: CGFloat, corners: RectCorner = .allCorners) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }

    /// 圆形描边
    ///
    /// 沿视图边界画一个圆形边框，等效于 `.overlay(Circle().stroke(...))`。
    ///
    /// - Parameters:
    ///   - color: 边框颜色
    ///   - lineWidth: 线宽，默认 `1`
    @ViewBuilder
    func circleStroke(color: Color, lineWidth: CGFloat = 1) -> some View {
        overlay(Circle().stroke(color, lineWidth: lineWidth))
    }

    /// 胶囊形描边
    ///
    /// 沿视图边界画一个胶囊形边框，等效于 `.overlay(Capsule().stroke(...))`。
    ///
    /// - Parameters:
    ///   - color: 边框颜色
    ///   - lineWidth: 线宽，默认 `1`
    @ViewBuilder
    func capsuleStroke(color: Color, lineWidth: CGFloat = 1) -> some View {
        overlay(Capsule().stroke(color, lineWidth: lineWidth))
    }

    /// 虚线边框
    ///
    /// 沿视图边界画一个圆角虚线边框。
    ///
    /// - Parameters:
    ///   - color: 边框颜色
    ///   - lineWidth: 线宽，默认 `1`
    ///   - dashLength: 每段虚线的长度，默认 `6`
    ///   - cornerRadius: 边框圆角半径，默认 `0`
    ///
    /// - Example:
    ///   ```swift
    ///   RoundedRectangle(cornerRadius: 12)
    ///       .dashedBorder(color: .gray)
    ///   ```
    @ViewBuilder
    func dashedBorder(color: Color, lineWidth: CGFloat = 1, dashLength: CGFloat = 6, cornerRadius: CGFloat = 0) -> some View {
        overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, dash: [dashLength]))
        )
    }

    /// 蒙版裁剪
    ///
    /// 用任意形状裁剪视图，等效于 `.mask(shape)`。
    ///
    /// - Parameter shape: 用作蒙版的形状
    ///
    /// - Example:
    ///   ```swift
    ///   Image("photo").maskWith(Circle())
    ///   ```
    @ViewBuilder
    func maskWith<S: Shape>(_ shape: S) -> some View {
        mask(shape)
    }
}
