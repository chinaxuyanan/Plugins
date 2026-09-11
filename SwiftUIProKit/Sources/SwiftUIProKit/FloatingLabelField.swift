import SwiftUI

// MARK: - 浮动标签输入框

/// 浮动标签输入框（Material 风格）
///
/// 空且未聚焦时，标签当作占位文字居中显示；一旦聚焦或已有内容，
/// 标签就缩小滑到输入框左上角，给输入内容腾出位置。
///
/// - Example:
///   ```swift
///   FloatingLabelField(label: "手机号", text: $phone, helperText: "11 位数字")
///
///   FloatingLabelField(label: "密码", text: $password, isSecure: true,
///                      errorText: password.isEmpty ? "密码不能为空" : nil)
///   ```
/// 中文名 `浮动标签输入框` 与 `FloatingLabelField` 等价。
public struct FloatingLabelField: View {

    /// 标签文字
    private let label: String
    /// 输入内容绑定
    private let text: Binding<String>
    /// 是否密码输入（换成 `SecureField`）
    private let isSecure: Bool
    /// 输入框高度
    private let height: CGFloat
    /// 圆角
    private let cornerRadius: CGFloat
    /// 聚焦时的强调色
    private let tint: Color
    /// 说明文字（无错误时显示，可为空）
    private let helperText: String?
    /// 错误文字（不为空时显示为红色，并覆盖说明文字）
    private let errorText: String?
    /// 是否在出现时自动聚焦
    private let autoFocus: Bool

    /// 当前是否已聚焦
    @FocusState private var isFocused: Bool

    /// 用标签与绑定值创建浮动标签输入框
    /// - Parameters:
    ///   - label: 标签文字
    ///   - text: 输入内容绑定
    ///   - isSecure: 是否密码输入，默认 `false`
    ///   - height: 输入框高度，默认 `54`
    ///   - cornerRadius: 圆角，默认 `10`
    ///   - tint: 聚焦强调色，默认 `.accentColor`
    ///   - helperText: 说明文字，默认空
    ///   - errorText: 错误文字，默认空
    ///   - autoFocus: 是否出现时自动聚焦，默认 `false`
    public init(label: String,
                text: Binding<String>,
                isSecure: Bool = false,
                height: CGFloat = 54,
                cornerRadius: CGFloat = 10,
                tint: Color = .accentColor,
                helperText: String? = nil,
                errorText: String? = nil,
                autoFocus: Bool = false) {
        self.label = label
        self.text = text
        self.isSecure = isSecure
        self.height = height
        self.cornerRadius = cornerRadius
        self.tint = tint
        self.helperText = helperText
        self.errorText = errorText
        self.autoFocus = autoFocus
    }

    // MARK: 纯逻辑

    /// 标签是否应该上浮（聚焦中或已有内容时上浮）
    /// - Parameters:
    ///   - text: 当前输入内容
    ///   - isFocused: 是否聚焦
    public static func shouldFloat(text: String, isFocused: Bool) -> Bool {
        isFocused || !text.isEmpty
    }

    // MARK: 视图

    public var body: some View {
        let floating = Self.shouldFloat(text: text.wrappedValue, isFocused: isFocused)
        VStack(alignment: .leading, spacing: 4) {
            fieldBox(floating: floating)
            if let message = errorText ?? helperText {
                Text(message)
                    .font(.caption2)
                    .foregroundStyle(errorText != nil ? Color.red : Color.secondary)
                    .padding(.leading, 2)
            }
        }
        .animation(.easeOut(duration: 0.18), value: floating)
        .onAppear {
            if autoFocus { isFocused = true }
        }
    }

    private func fieldBox(floating: Bool) -> some View {
        ZStack(alignment: .topLeading) {
            // 上浮后的左上角小标签
            Text(label)
                .font(.caption2)
                .foregroundStyle(labelColor)
                .padding(.leading, 14)
                .padding(.top, 8)
                .opacity(floating ? 1 : 0)
                .offset(y: floating ? 0 : 6)
            // 未上浮时的居中占位标签
            Text(label)
                .font(.body)
                .foregroundStyle(Color.secondary)
                .padding(.leading, 14)
                .frame(height: height, alignment: .leading)
                .opacity(floating ? 0 : 1)
            // 输入区（上浮时整体下移一点，给标签让位）
            inputControl
                .padding(.horizontal, 14)
                .frame(height: height, alignment: .leading)
                .offset(y: floating ? 9 : 0)
        }
        .frame(height: height)
        .background(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(Color.secondary.opacity(0.06)))
        .overlay(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .stroke(borderColor, lineWidth: borderWidth))
        .contentShape(Rectangle())
        .onTapGesture { isFocused = true }
    }

    @ViewBuilder
    private var inputControl: some View {
        Group {
            if isSecure {
                SecureField("", text: text)
            } else {
                TextField("", text: text)
            }
        }
        .textFieldStyle(.plain)
        .font(.body)
        .focused($isFocused)
    }

    private var labelColor: Color {
        errorText != nil ? .red : (isFocused ? tint : .secondary)
    }

    private var borderColor: Color {
        if errorText != nil { return .red }
        return isFocused ? tint : Color.secondary.opacity(0.35)
    }

    private var borderWidth: CGFloat {
        (isFocused || errorText != nil) ? 1.6 : 1
    }
}

// MARK: 中文命名别名

/// 中文名：浮动标签输入框（等同 `FloatingLabelField`）
public typealias 浮动标签输入框 = FloatingLabelField

public extension FloatingLabelField {

    /// 浮动标签输入框（中文参数）
    ///
    /// 首参 `标签` 无默认值，与其他重载凭标签区分，不会歧义。
    init(标签: String,
         文本: Binding<String>,
         密码输入: Bool = false,
         高度: CGFloat = 54,
         圆角: CGFloat = 10,
         强调色: Color = .accentColor,
         说明文字: String? = nil,
         错误文字: String? = nil,
         自动聚焦: Bool = false) {
        self.init(label: 标签,
                  text: 文本,
                  isSecure: 密码输入,
                  height: 高度,
                  cornerRadius: 圆角,
                  tint: 强调色,
                  helperText: 说明文字,
                  errorText: 错误文字,
                  autoFocus: 自动聚焦)
    }

    /// 标签是否应该上浮（等同 `shouldFloat(text:isFocused:)`）
    static func 是否上浮(文本: String, 聚焦中: Bool) -> Bool {
        shouldFloat(text: 文本, isFocused: 聚焦中)
    }
}
