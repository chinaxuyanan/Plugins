import SwiftUI

// MARK: - 滚动数字
//
// 数字变化时平滑地从旧值「滚」到新值（基于 `Animatable` 逐帧插值），适合计数 / 金额 / 分数展示。

/// 滚动数字：数值变化时平滑过渡到新值
///
/// 基于 `Animatable` 协议逐帧插值，数值改变时自动播放滚动动画；
/// 配合 `.animation` 或 `withAnimation` 效果更明显。
///
/// - Example:
///   ```swift
///   AnimatedNumber(value: 1280, suffix: " 元")
///
///   // 数据变化时自动滚动
///   AnimatedNumber(value: score, tint: .orange, decimals: 1)
///   ```
public struct AnimatedNumber: View {

    /// 目标数值
    private let value: Double
    /// 字号
    private let font: Font
    /// 文字颜色
    private let tint: Color
    /// 小数位数
    private let decimals: Int
    /// 前缀（如 `"¥"`）
    private let prefix: String
    /// 后缀（如 `" 元"`）
    private let suffix: String

    /// - Parameters:
    ///   - value: 目标数值
    ///   - font: 字号，默认大号加粗圆角字
    ///   - tint: 文字颜色，默认 `.primary`
    ///   - decimals: 小数位数，默认 `0`
    ///   - prefix: 前缀文字，默认空
    ///   - suffix: 后缀文字，默认空
    public init(value: Double,
                font: Font = .system(size: 28, weight: .bold, design: .rounded),
                tint: Color = .primary,
                decimals: Int = 0,
                prefix: String = "",
                suffix: String = "") {
        self.value = value
        self.font = font
        self.tint = tint
        self.decimals = max(0, decimals)
        self.prefix = prefix
        self.suffix = suffix
    }

    public var body: some View {
        AnimatedNumberText(value: value,
                           decimals: decimals,
                           prefix: prefix,
                           suffix: suffix,
                           font: font,
                           tint: tint)
            .animation(.easeOut(duration: 0.6), value: value)
    }
}

/// 内部实现：持有可变 `value`，SwiftUI 通过 `animatableData` 在动画过程中逐帧改写它。
private struct AnimatedNumberText: View, Animatable {

    var value: Double
    let decimals: Int
    let prefix: String
    let suffix: String
    let font: Font
    let tint: Color

    var animatableData: Double {
        get { value }
        set { value = newValue }
    }

    var body: some View {
        Text(prefix + formatted + suffix)
            .font(font)
            .monospacedDigit()
            .foregroundStyle(tint)
    }

    /// 按小数位数格式化（`decimals = 0` 时显示整数）
    private var formatted: String {
        String(format: "%.\(decimals)f", value)
    }
}

// MARK: 中文命名别名

/// 中文名：滚动数字（等同 `AnimatedNumber`）
public typealias 滚动数字 = AnimatedNumber

public extension AnimatedNumber {
    /// 滚动数字（中文参数）
    /// - Parameters:
    ///   - 数值: 目标数值
    ///   - 字体: 字号
    ///   - 颜色: 文字颜色，默认 `.primary`
    ///   - 小数位: 小数位数，默认 `0`
    ///   - 前缀: 前缀文字，默认空
    ///   - 后缀: 后缀文字，默认空
    init(数值: Double,
         字体: Font = .system(size: 28, weight: .bold, design: .rounded),
         颜色: Color = .primary,
         小数位: Int = 0,
         前缀: String = "",
         后缀: String = "") {
        self.init(value: 数值, font: 字体, tint: 颜色, decimals: 小数位,
                  prefix: 前缀, suffix: 后缀)
    }
}
