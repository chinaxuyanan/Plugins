import SwiftUI

// MARK: - 环形进度
//
// 用一个圆环展示 `0.0` ~ `1.0` 的比例，中心可选显示百分比文字。
// 与 `progressStyleCircular`（把系统 ProgressView 改成转圈样式）不同，本组件展示的是「确定进度」。

/// 环形进度视图：用圆环展示 `0.0` ~ `1.0` 的比例，中心可选百分比
///
/// - Example:
///   ```swift
///   RingProgress(value: 0.65, tint: .green, lineWidth: 10, size: 96)
///   ```
public struct RingProgress: View {

    /// 进度值（`0.0` ~ `1.0`，超出范围会被钳制）
    private let value: Double
    /// 进度颜色
    private let tint: Color
    /// 轨道颜色
    private let trackColor: Color
    /// 圆环线宽
    private let lineWidth: CGFloat
    /// 圆环直径
    private let size: CGFloat
    /// 是否在中心显示百分比文字
    private let showsLabel: Bool
    /// 中心文字字体
    private let labelFont: Font

    /// - Parameters:
    ///   - value: 进度值（`0.0` ~ `1.0`，会被钳制到该范围）
    ///   - tint: 进度颜色，默认 `.accentColor`
    ///   - trackColor: 轨道颜色，默认灰色半透明
    ///   - lineWidth: 圆环线宽，默认 `8`
    ///   - size: 圆环直径，默认 `80`
    ///   - showsLabel: 是否在中心显示百分比文字，默认 `true`
    ///   - labelFont: 中心文字字体，默认小号半粗圆角字
    public init(value: Double,
                tint: Color = .accentColor,
                trackColor: Color = Color.secondary.opacity(0.2),
                lineWidth: CGFloat = 8,
                size: CGFloat = 80,
                showsLabel: Bool = true,
                labelFont: Font = .system(size: 14, weight: .semibold, design: .rounded)) {
        self.value = value
        self.tint = tint
        self.trackColor = trackColor
        self.lineWidth = lineWidth
        self.size = size
        self.showsLabel = showsLabel
        self.labelFont = labelFont
    }

    /// 钳制到 `0.0` ~ `1.0` 的进度值（供内部渲染与测试使用）
    var normalizedValue: Double {
        min(1, max(0, value))
    }

    public var body: some View {
        ZStack {
            Circle()
                .stroke(trackColor, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
            Circle()
                .trim(from: 0, to: normalizedValue)
                .stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            if showsLabel {
                Text("\(Int((normalizedValue * 100).rounded()))%")
                    .font(labelFont)
                    .monospacedDigit()
                    .foregroundStyle(tint)
            }
        }
        .frame(width: size, height: size)
        .animation(.easeInOut(duration: 0.3), value: normalizedValue)
    }
}

// MARK: 中文命名别名

/// 中文名：环形进度（等同 `RingProgress`）
public typealias 环形进度 = RingProgress

public extension RingProgress {
    /// 环形进度（中文参数）
    /// - Parameters:
    ///   - 进度: 进度值（`0.0` ~ `1.0`，会被钳制）
    ///   - 颜色: 进度颜色，默认 `.accentColor`
    ///   - 轨道颜色: 轨道颜色，默认灰色半透明
    ///   - 线宽: 圆环线宽，默认 `8`
    ///   - 尺寸: 圆环直径，默认 `80`
    ///   - 显示百分比: 是否在中心显示百分比文字，默认 `true`
    ///   - 字体: 中心文字字体
    init(进度: Double,
         颜色: Color = .accentColor,
         轨道颜色: Color = Color.secondary.opacity(0.2),
         线宽: CGFloat = 8,
         尺寸: CGFloat = 80,
         显示百分比: Bool = true,
         字体: Font = .system(size: 14, weight: .semibold, design: .rounded)) {
        self.init(value: 进度, tint: 颜色, trackColor: 轨道颜色, lineWidth: 线宽,
                  size: 尺寸, showsLabel: 显示百分比, labelFont: 字体)
    }
}
