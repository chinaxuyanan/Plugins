import SwiftUI

// MARK: - 验证码输入框

/// 验证码输入框
///
/// 分格显示验证码：输入自动往后跳、退格自动回上一格，输满 `length` 位时回调。
/// 内部用一个透明（1×1）的真实 `TextField` 承载输入，所以系统键盘、粘贴整段验证码、
/// iOS 短信验证码自动填充（`.oneTimeCode`）都能正常工作；只需要套一层「格子」做展示。
///
/// - Example:
///   ```swift
///   @State private var code = ""
///   OTPField(code: $code, length: 6) { print("输满了：\($0)") }
///   ```
public struct OTPField: View {

    /// 验证码绑定值
    @Binding private var code: String
    /// 位数
    private let length: Int
    /// 每格边长
    private let boxSize: CGFloat
    /// 格间距
    private let spacing: CGFloat
    /// 格子圆角
    private let cornerRadius: CGFloat
    /// 输满回调
    private let onComplete: ((String) -> Void)?

    /// 焦点状态（点击格子即聚焦到隐藏输入框）
    @FocusState private var isFocused: Bool

    /// - Parameters:
    ///   - code: 验证码绑定值（只保留数字，长度不会超过 `length`）
    ///   - length: 位数，默认 `6`
    ///   - boxSize: 每格边长，默认 `48`
    ///   - spacing: 格间距，默认 `10`
    ///   - cornerRadius: 格子圆角，默认 `8`
    ///   - onComplete: 输满 `length` 位时的回调，参数为完整验证码
    public init(code: Binding<String>,
                length: Int = 6,
                boxSize: CGFloat = 48,
                spacing: CGFloat = 10,
                cornerRadius: CGFloat = 8,
                onComplete: ((String) -> Void)? = nil) {
        self._code = code
        self.length = max(1, length)
        self.boxSize = boxSize
        self.spacing = spacing
        self.cornerRadius = cornerRadius
        self.onComplete = onComplete
    }

    public var body: some View {
        ZStack {
            hiddenField
            boxes
        }
    }

    /// 隐藏的真实输入框：只占 1×1 且几乎透明，键盘/粘贴/自动填充都交给它
    private var hiddenField: some View {
        platformField
            .focused($isFocused)
            .tint(.clear)
            .frame(width: 1, height: 1)
            .opacity(0.01)
            .accessibilityHidden(true)
            .didChange(of: code) { newValue in
                let filtered = String(newValue.filter(\.isNumber).prefix(length))
                if filtered != code { code = filtered }
                if filtered.count == length { onComplete?(filtered) }
            }
    }

    /// 平台差异部分单独抽出来，避免在修饰符链里写 `#if`
    private var platformField: some View {
        #if os(iOS)
        return TextField("", text: $code)
            .keyboardType(.numberPad)
            .textContentType(.oneTimeCode)
        #else
        return TextField("", text: $code)
        #endif
    }

    /// 分格展示
    private var boxes: some View {
        HStack(spacing: spacing) {
            ForEach(0..<length, id: \.self) { index in
                box(at: index)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture { isFocused = true }
    }

    /// 第 `index` 个格子
    private func box(at index: Int) -> some View {
        let characters = Array(code)
        let filled = index < characters.count
        let highlight = isFocused && index == min(characters.count, length - 1)
        return RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .strokeBorder(highlight ? Color.accentColor : Color.gray.opacity(0.3),
                          lineWidth: 1.5)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(Color.gray.opacity(0.08))
            )
            .frame(width: boxSize, height: boxSize)
            .overlay(
                Text(filled ? String(characters[index]) : "")
                    .font(.system(size: boxSize * 0.45, weight: .semibold, design: .rounded))
            )
    }
}

// MARK: 中文命名别名

/// 中文名：验证码输入框（等同 `OTPField`）
public typealias 验证码输入框 = OTPField

public extension OTPField {

    /// 验证码输入框（中文参数）
    /// - Parameters:
    ///   - 验证码: 验证码绑定值（只保留数字，长度不超过 `位数`）
    ///   - 位数: 位数，默认 `6`
    ///   - 格子尺寸: 每格边长，默认 `48`
    ///   - 间距: 格间距，默认 `10`
    ///   - 圆角: 格子圆角，默认 `8`
    ///   - 输满回调: 输满 `位数` 位时的回调
    init(验证码: Binding<String>,
         位数: Int = 6,
         格子尺寸: CGFloat = 48,
         间距: CGFloat = 10,
         圆角: CGFloat = 8,
         输满回调: ((String) -> Void)? = nil) {
        self.init(code: 验证码,
                  length: 位数,
                  boxSize: 格子尺寸,
                  spacing: 间距,
                  cornerRadius: 圆角,
                  onComplete: 输满回调)
    }
}
