import SwiftUI
import Combine

// MARK: - 倒计时视图

/// 倒计时视图：从指定秒数倒数到 0，归零时触发回调
///
/// 大号圆角数字 + 可选圆环进度；支持外部 `Binding` 暂停 / 恢复。
/// 归零后停止倒数并调用 `onFinish`。
///
/// - Example:
///   ```swift
///   @State private var paused = false
///
///   CountdownView(seconds: 60, paused: $paused) {
///       print("倒计时结束")
///   }
///   ```
public struct CountdownView: View {

    /// 倒计时总秒数
    private let totalSeconds: Int
    /// 归零时回调（可选）
    private let onFinish: (() -> Void)?
    /// 数字字号
    private let font: Font
    /// 是否显示圆环进度
    private let showsProgress: Bool
    /// 进度圆环 / 数字颜色
    private let tint: Color
    /// 外部暂停控制（可选；`true` 时暂停倒数）
    private let paused: Binding<Bool>?
    /// 每秒触发的定时器
    private let timer: Publishers.Autoconnect<Timer.TimerPublisher>

    /// 剩余秒数
    @State private var remaining: Int

    /// - Parameters:
    ///   - seconds: 倒计时总秒数（会取 `max(0, seconds)`）
    ///   - font: 数字字号，默认大号圆角字
    ///   - showsProgress: 是否显示圆环进度，默认 `true`
    ///   - tint: 进度 / 数字颜色，默认 `.accentColor`
    ///   - paused: 外部暂停控制（可选）
    ///   - onFinish: 归零时回调（可选）
    public init(seconds: Int,
                font: Font = .system(size: 40, weight: .bold, design: .rounded),
                showsProgress: Bool = true,
                tint: Color = .accentColor,
                paused: Binding<Bool>? = nil,
                onFinish: (() -> Void)? = nil) {
        self.totalSeconds = max(0, seconds)
        self.font = font
        self.showsProgress = showsProgress
        self.tint = tint
        self.paused = paused
        self.onFinish = onFinish
        self.timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        self._remaining = State(initialValue: max(0, seconds))
    }

    public var body: some View {
        Group {
            if showsProgress {
                ZStack {
                    ring
                    Text(display)
                        .font(font)
                        .monospacedDigit()
                        .foregroundStyle(tint)
                }
            } else {
                Text(display)
                    .font(font)
                    .monospacedDigit()
                    .foregroundStyle(tint)
            }
        }
        .onReceive(timer) { _ in
            tick()
        }
    }

    /// 圆环进度（剩余比例随倒数逐渐缩短）
    private var ring: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.2), lineWidth: 6)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(tint, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: remaining)
        }
        .padding(6)
        .frame(width: 120, height: 120)
    }

    /// 剩余比例（`0.0` ~ `1.0`）
    private var progress: Double {
        guard totalSeconds > 0 else { return 0 }
        return min(1, max(0, Double(remaining) / Double(totalSeconds)))
    }

    /// 格式化显示（`MM:SS` 或 `HH:MM:SS`）
    private var display: String {
        let h = remaining / 3600
        let m = (remaining % 3600) / 60
        let s = remaining % 60
        if h > 0 { return String(format: "%02d:%02d:%02d", h, m, s) }
        return String(format: "%02d:%02d", m, s)
    }

    /// 每秒倒计时：暂停或已归零时不递减
    private func tick() {
        guard remaining > 0 else { return }
        if let paused = paused, paused.wrappedValue { return }
        remaining -= 1
        if remaining == 0 {
            onFinish?()
        }
    }
}

// MARK: 中文命名别名

/// 中文名：倒计时视图（等同 `CountdownView`）
public typealias 倒计时视图 = CountdownView

public extension CountdownView {
    /// 倒计时视图（中文参数）
    /// - Parameters:
    ///   - 秒数: 倒计时总秒数
    ///   - 字体: 数字字号
    ///   - 显示进度: 是否显示圆环进度，默认 `true`
    ///   - 颜色: 进度 / 数字颜色，默认 `.accentColor`
    ///   - 暂停: 外部暂停控制（可选）
    ///   - 结束: 归零时回调（可选）
    init(秒数: Int,
         字体: Font = .system(size: 40, weight: .bold, design: .rounded),
         显示进度: Bool = true,
         颜色: Color = .accentColor,
         暂停: Binding<Bool>? = nil,
         结束: (() -> Void)? = nil) {
        self.init(seconds: 秒数, font: 字体, showsProgress: 显示进度,
                  tint: 颜色, paused: 暂停, onFinish: 结束)
    }
}
