import SwiftUI

// MARK: - 跑马灯文字

/// 跑马灯滚动方向
public enum MarqueeDirection {
    /// 从右向左（公告栏最常见的滚动方向）
    case rightToLeft
    /// 从左向右
    case leftToRight
}

/// 中文名：跑马灯滚动方向（等同 `MarqueeDirection`）
public typealias 跑马灯方向 = MarqueeDirection

/// 跑马灯文字
///
/// 文字宽度超出容器时自动水平循环滚动，未超出时静态显示（不会「空转」）。
/// 通过 `readSize` 测量文字与容器的真实尺寸，所以换字体 / 换文案 / 转屏都能自适应。
///
/// - Example:
///   ```swift
///   MarqueeText("这是一条很长的公告，会从右向左循环滚动……")
///   MarqueeText("从右往左飘", speed: 60, gap: 32, direction: .rightToLeft)
///   ```
public struct MarqueeText: View {

    /// 文字内容
    private let text: String
    /// 字体
    private let font: Font
    /// 文字颜色
    private let tint: Color
    /// 滚动速度（点 / 秒）
    private let speed: CGFloat
    /// 两份文字之间的间隔
    private let gap: CGFloat
    /// 滚动方向
    private let direction: MarqueeDirection
    /// 是否启用滚动（`false` 时只静态显示，可用于暂停）
    private let isActive: Bool

    /// 文字实测宽度 / 高度
    @State private var textWidth: CGFloat = 0
    @State private var textHeight: CGFloat = 0
    /// 容器实测宽度
    @State private var containerWidth: CGFloat = 0
    /// 动画开关：尺寸测量完成后置为 `true` 触发滚动
    @State private var animate = false

    /// - Parameters:
    ///   - text: 文字内容
    ///   - font: 字体，默认 `.body`
    ///   - tint: 文字颜色，默认 `.primary`
    ///   - speed: 滚动速度（点 / 秒），默认 `40`
    ///   - gap: 两份文字之间的间隔，默认 `48`
    ///   - direction: 滚动方向，默认 `.rightToLeft`
    ///   - isActive: 是否启用滚动，默认 `true`
    public init(_ text: String,
                font: Font = .body,
                tint: Color = .primary,
                speed: CGFloat = 40,
                gap: CGFloat = 48,
                direction: MarqueeDirection = .rightToLeft,
                isActive: Bool = true) {
        self.text = text
        self.font = font
        self.tint = tint
        self.speed = max(1, speed)
        self.gap = max(0, gap)
        self.direction = direction
        self.isActive = isActive
    }

    /// 是否需要滚动：启用 + 两份尺寸都测到了 + 文字确实超宽
    private var needsScroll: Bool {
        isActive && textWidth > 0 && containerWidth > 0 && textWidth > containerWidth
    }

    /// 单次滚动的距离（一份文字 + 一个间隔）
    private var scrollDistance: CGFloat {
        textWidth + gap
    }

    /// 偏移量：靠「复制一份文字」实现无缝循环——滚动到一份文字的宽度时，
    /// 第二份正好落到第一份原来的位置，所以循环回起点看不出跳变。
    private var offsetX: CGFloat {
        guard needsScroll else { return 0 }
        switch direction {
        case .rightToLeft:
            return animate ? -scrollDistance : 0
        case .leftToRight:
            return animate ? 0 : -scrollDistance
        }
    }

    public var body: some View {
        ZStack(alignment: .leading) {
            // 用一条透明横线量出容器宽度（ZStack 因它而撑满可用宽度）
            Color.clear
                .frame(height: 1)
                .readSize { containerWidth = $0.width }

            HStack(spacing: gap) {
                measuredText
                if needsScroll {
                    measuredText
                }
            }
            .offset(x: offsetX)
            .animation(needsScroll
                       ? .linear(duration: Double(scrollDistance / speed)).repeatForever(autoreverses: false)
                       : .default,
                       value: animate)
        }
        .frame(height: textHeight > 0 ? textHeight : nil)
        .clipped()
        .didChange(of: needsScroll) { animate = $0 }
    }

    /// 文字本体（顺便量出宽度，供判断是否超宽）
    private var measuredText: some View {
        Text(text)
            .font(font)
            .foregroundStyle(tint)
            .lineLimit(1)
            .fixedSize(horizontal: true, vertical: false)
            .readSize { size in
                textWidth = size.width
                textHeight = size.height
            }
    }
}

// MARK: 中文命名别名

/// 中文名：跑马灯（等同 `MarqueeText`）
public typealias 跑马灯 = MarqueeText

public extension MarqueeText {

    /// 跑马灯（中文参数）
    /// - Parameters:
    ///   - 文字: 文字内容
    ///   - 字体: 字体，默认 `.body`
    ///   - 颜色: 文字颜色，默认 `.primary`
    ///   - 速度: 滚动速度（点 / 秒），默认 `40`
    ///   - 间隔: 两份文字之间的间隔，默认 `48`
    ///   - 方向: 滚动方向，默认 `.rightToLeft`
    ///   - 启用: 是否启用滚动，默认 `true`
    ///
    /// - Note: 首个参数带 `文字:` 标签（而非省略标签）——英文 `init` 的
    ///   首参是无标签的 `String`，两个重载若都无标签，`跑马灯("x")` 会因
    ///   无法区分而报 `ambiguous use of 'init'`。带上标签即可各归其位。
    init(文字: String,
         字体: Font = .body,
         颜色: Color = .primary,
         速度: CGFloat = 40,
         间隔: CGFloat = 48,
         方向: MarqueeDirection = .rightToLeft,
         启用: Bool = true) {
        self.init(文字,
                  font: 字体,
                  tint: 颜色,
                  speed: 速度,
                  gap: 间隔,
                  direction: 方向,
                  isActive: 启用)
    }
}
