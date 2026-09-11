import SwiftUI
import Combine

// MARK: - 打字机文本

/// 打字机文本
///
/// 逐字显现一段文字，末尾可带一个闪烁的光标；可选循环重播。适合做启动语、
/// 加载提示、AI 回答的流式效果。
///
/// - Example:
///   ```swift
///   TypingText("正在为你生成回答……")
///
///   TypingText("欢迎回来", speed: 0.08, showsCursor: true, loops: false) {
///       print("打完了")
///   }
///   ```
public struct TypingText: View {

    /// 完整文本
    private let text: String
    /// 字体
    private let font: Font
    /// 文字颜色
    private let tint: Color
    /// 光标颜色
    private let cursorColor: Color
    /// 是否显示光标
    private let showsCursor: Bool
    /// 打完一轮后是否从头再来
    private let loops: Bool
    /// 循环重播前的停顿（秒）
    private let loopDelay: TimeInterval
    /// 打完一轮（不循环时）的回调
    private let onFinish: (() -> Void)?
    /// 逐字定时器
    private let timer: Publishers.Autoconnect<Timer.TimerPublisher>
    /// 光标闪烁定时器
    private let cursorTimer: Publishers.Autoconnect<Timer.TimerPublisher>

    /// 当前已显现的字数
    @State private var visibleCount = 0
    /// 光标当前是否可见（闪烁用）
    @State private var isCursorVisible = true
    /// 是否已经回调过 `onFinish`（避免重复触发）
    @State private var didFinish = false
    /// 是否正处于「打完一轮、等待重播」的停顿中
    @State private var isPausing = false

    /// - Parameters:
    ///   - text: 完整文本
    ///   - speed: 每个字的间隔（秒），默认 `0.05`
    ///   - font: 字体，默认 `.body`
    ///   - tint: 文字颜色，默认 `.primary`
    ///   - cursorColor: 光标颜色，默认 `.accentColor`
    ///   - showsCursor: 是否显示光标，默认 `true`
    ///   - loops: 打完一轮后是否循环重播，默认 `false`
    ///   - loopDelay: 循环重播前的停顿（秒），默认 `1.0`
    ///   - cursorBlinkInterval: 光标闪烁间隔（秒），默认 `0.5`
    ///   - onFinish: 打完一轮（不循环时）的回调，默认 `nil`
    public init(_ text: String,
                speed: TimeInterval = 0.05,
                font: Font = .body,
                tint: Color = .primary,
                cursorColor: Color = .accentColor,
                showsCursor: Bool = true,
                loops: Bool = false,
                loopDelay: TimeInterval = 1.0,
                cursorBlinkInterval: TimeInterval = 0.5,
                onFinish: (() -> Void)? = nil) {
        self.text = text
        self.font = font
        self.tint = tint
        self.cursorColor = cursorColor
        self.showsCursor = showsCursor
        self.loops = loops
        self.loopDelay = max(0, loopDelay)
        self.onFinish = onFinish
        self.timer = Timer.publish(every: max(0.01, speed), on: .main, in: .common).autoconnect()
        self.cursorTimer = Timer.publish(every: max(0.1, cursorBlinkInterval), on: .main, in: .common).autoconnect()
    }

    /// 光标是否该出现：还没打完，或者循环模式（打完了也一直闪着）
    private var shouldShowCursor: Bool {
        visibleCount < text.count || loops
    }

    public var body: some View {
        HStack(spacing: 0) {
            Text(String(text.prefix(visibleCount)))
                .font(font)
                .foregroundStyle(tint)

            if showsCursor && shouldShowCursor {
                Text("▍")
                    .font(font)
                    .foregroundStyle(cursorColor)
                    .opacity(isCursorVisible ? 1 : 0)
            }
        }
        .onReceive(timer) { _ in tick() }
        .onReceive(cursorTimer) { _ in isCursorVisible.toggle() }
        .didChange(of: text) { _ in restart() }
    }

    /// 每次定时器触发：多显一个字；打完后按需回调或安排重播
    private func tick() {
        guard !text.isEmpty, !isPausing else { return }
        if visibleCount < text.count {
            visibleCount += 1
            if visibleCount == text.count {
                if loops {
                    scheduleLoop()
                } else if !didFinish {
                    didFinish = true
                    onFinish?()
                }
            }
        }
    }

    /// 打完一轮后停 `loopDelay` 秒再从头来
    private func scheduleLoop() {
        isPausing = true
        DispatchQueue.main.asyncAfter(deadline: .now() + loopDelay) {
            restart()
        }
    }

    /// 回到起点重新打
    private func restart() {
        visibleCount = 0
        didFinish = false
        isPausing = false
    }
}

// MARK: 中文命名别名

/// 中文名：打字机文本（等同 `TypingText`）
public typealias 打字机文本 = TypingText

public extension TypingText {

    /// 打字机文本（中文参数）
    /// - Parameters:
    ///   - 文字: 完整文本
    ///   - 速度: 每个字的间隔（秒），默认 `0.05`
    ///   - 字体: 字体，默认 `.body`
    ///   - 颜色: 文字颜色，默认 `.primary`
    ///   - 光标颜色: 光标颜色，默认 `.accentColor`
    ///   - 显示光标: 是否显示光标，默认 `true`
    ///   - 循环: 打完一轮后是否循环重播，默认 `false`
    ///   - 循环停顿: 循环重播前的停顿（秒），默认 `1.0`
    ///   - 光标闪烁间隔: 光标闪烁间隔（秒），默认 `0.5`
    ///   - 结束: 打完一轮（不循环时）的回调，默认 `nil`
    ///
    /// - Note: 首个参数带 `文字:` 标签——英文 `init` 的首参是无标签的 `String`，
    ///   两个重载若都无标签会报 `ambiguous use of 'init'`。
    init(文字: String,
         速度: TimeInterval = 0.05,
         字体: Font = .body,
         颜色: Color = .primary,
         光标颜色: Color = .accentColor,
         显示光标: Bool = true,
         循环: Bool = false,
         循环停顿: TimeInterval = 1.0,
         光标闪烁间隔: TimeInterval = 0.5,
         结束: (() -> Void)? = nil) {
        self.init(文字,
                  speed: 速度,
                  font: 字体,
                  tint: 颜色,
                  cursorColor: 光标颜色,
                  showsCursor: 显示光标,
                  loops: 循环,
                  loopDelay: 循环停顿,
                  cursorBlinkInterval: 光标闪烁间隔,
                  onFinish: 结束)
    }
}
