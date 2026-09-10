import SwiftUI

// MARK: - 搜索栏

/// 搜索栏
///
/// 一个带放大镜图标、一键清空、可选「取消」按钮的搜索输入框。
/// 除了「每次输入都回调」的 `onDebounce`，还内置了**防抖**：连续输入时只会在
/// 停顿 `debounceInterval` 秒后回调一次，适合直接接搜索接口的场景
/// （避免每敲一个字就发一次请求）。
///
/// - Note: 防抖用 `Task` + `Task.sleep` 实现，新输入到来时取消上一个任务；
///   传 `debounceInterval: 0` 则退化为「即时回调」，不再防抖。
///
/// - Example:
///   ```swift
///   @State private var 关键词 = ""
///
///   SearchBar(text: $关键词, placeholder: "搜索商品") {
///       搜索(关键词)
///   } onDebounce: { 新值 in
///       实时搜索(新值)
///   }
///   ```
public struct SearchBar: View {

    /// 输入内容绑定
    @Binding private var text: String
    /// 占位文字
    private let placeholder: String
    /// 是否显示「取消」按钮（仅在聚焦或有内容时出现）
    private let showsCancel: Bool
    /// 「取消」按钮标题
    private let cancelTitle: String
    /// 防抖间隔（秒），`0` 表示不防抖
    private let debounceInterval: TimeInterval
    /// 主题色（取消按钮与光标）
    private let tint: Color
    /// 按下键盘「搜索」键时回调
    private let onSubmit: (() -> Void)?
    /// 防抖后回调，参数为最新输入
    private let onDebounce: ((String) -> Void)?

    /// 是否聚焦
    @FocusState private var isFocused: Bool
    /// 当前防抖任务（新输入到来时取消）
    @State private var debounceTask: Task<Void, Never>?

    /// - Parameters:
    ///   - text: 输入内容绑定
    ///   - placeholder: 占位文字，默认 `"搜索"`
    ///   - showsCancel: 是否显示「取消」按钮，默认 `true`
    ///   - cancelTitle: 「取消」按钮标题，默认 `"取消"`
    ///   - debounceInterval: 防抖间隔（秒），默认 `0.3`；传 `0` 表示即时回调
    ///   - tint: 主题色（取消按钮），默认 `.accentColor`
    ///   - onSubmit: 按下键盘「搜索」键时回调，默认 `nil`
    ///   - onDebounce: 防抖后回调（参数为最新输入），默认 `nil`
    public init(text: Binding<String>,
                placeholder: String = "搜索",
                showsCancel: Bool = true,
                cancelTitle: String = "取消",
                debounceInterval: TimeInterval = 0.3,
                tint: Color = .accentColor,
                onSubmit: (() -> Void)? = nil,
                onDebounce: ((String) -> Void)? = nil) {
        self._text = text
        self.placeholder = placeholder
        self.showsCancel = showsCancel
        self.cancelTitle = cancelTitle
        self.debounceInterval = debounceInterval
        self.tint = tint
        self.onSubmit = onSubmit
        self.onDebounce = onDebounce
    }

    public var body: some View {
        HStack(spacing: 8) {
            field
            if showsCancel && (isFocused || !text.isEmpty) {
                Button(cancelTitle, action: cancel)
                    .buttonStyle(.plain)
                    .foregroundStyle(tint)
            }
        }
        .didChange(of: text) { newValue in
            scheduleDebounce(newValue)
        }
        .onDisappear {
            debounceTask?.cancel()
        }
    }

    // MARK: 输入框

    private var field: some View {
        HStack(spacing: 6) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField(placeholder, text: $text)
                .textFieldStyle(.plain)
                .focused($isFocused)
                .submitLabel(.search)
                .autocorrectionDisabled(true)
                .onSubmit { onSubmit?() }

            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("清空")
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.cardBackground)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(isFocused ? tint.opacity(0.6) : Color.gray.opacity(0.25),
                              lineWidth: 1)
        )
        .onTapGesture { isFocused = true }
    }

    // MARK: 行为

    /// 点「取消」：清空内容并收起键盘
    private func cancel() {
        debounceTask?.cancel()
        text = ""
        isFocused = false
    }

    /// 排布防抖：取消上一个任务，间隔后再回调一次
    private func scheduleDebounce(_ value: String) {
        guard let onDebounce = onDebounce else { return }
        debounceTask?.cancel()

        guard debounceInterval > 0 else {
            onDebounce(value)
            return
        }

        debounceTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: UInt64(debounceInterval * 1_000_000_000))
            guard !Task.isCancelled else { return }
            onDebounce(value)
        }
    }
}

// MARK: 中文命名别名

/// 中文名：搜索栏（等同 `SearchBar`）
public typealias 搜索栏 = SearchBar

public extension SearchBar {

    /// 搜索栏（中文参数）
    /// - Parameters:
    ///   - 文本: 输入内容绑定
    ///   - 占位: 占位文字，默认 `"搜索"`
    ///   - 显示取消: 是否显示「取消」按钮，默认 `true`
    ///   - 取消标题: 「取消」按钮标题，默认 `"取消"`
    ///   - 防抖间隔: 防抖间隔（秒），默认 `0.3`；传 `0` 表示即时回调
    ///   - 主题色: 主题色（取消按钮），默认 `.accentColor`
    ///   - 提交: 按下键盘「搜索」键时回调，默认 `nil`
    ///   - 防抖回调: 防抖后回调（参数为最新输入），默认 `nil`
    init(文本: Binding<String>,
         占位: String = "搜索",
         显示取消: Bool = true,
         取消标题: String = "取消",
         防抖间隔: TimeInterval = 0.3,
         主题色: Color = .accentColor,
         提交: (() -> Void)? = nil,
         防抖回调: ((String) -> Void)? = nil) {
        self.init(text: 文本,
                  placeholder: 占位,
                  showsCancel: 显示取消,
                  cancelTitle: 取消标题,
                  debounceInterval: 防抖间隔,
                  tint: 主题色,
                  onSubmit: 提交,
                  onDebounce: 防抖回调)
    }
}
