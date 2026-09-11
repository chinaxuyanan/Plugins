import SwiftUI

// MARK: - 标签输入框

/// 标签输入框：输入文字后回车（或输入逗号）即变成一个「标签块」，可逐个删除
///
/// 标签块用 `FlowLayout` 自动换行排列，达到数量上限时会给出提示并拒绝新增。
/// 适合「添加关键词」「收件人」「兴趣标签」这类场景。
///
/// - Note: 因为依赖 `FlowLayout`，本组件同样要求 iOS 16 / macOS 13 及以上。
///
/// - Example:
///   ```swift
///   @State private var tags = ["Swift", "SwiftUI"]
///
///   TagInput(tags: $tags, placeholder: "回车添加标签", maxTags: 8)
///   ```
/// 中文名 `标签输入` 与 `TagInput` 等价：`标签输入(标签: $tags, 最大数量: 8)`。
@available(iOS 16.0, macOS 13.0, *)
public struct TagInput: View {

    /// 已选标签
    @Binding private var tags: [String]
    /// 输入框占位文字
    private let placeholder: String
    /// 标签数量上限（`0` 表示不限）
    private let maxTags: Int
    /// 是否允许重复标签
    private let allowsDuplicates: Bool
    /// 标签块的主题色
    private let tagColor: Color
    /// 新增标签回调
    private let onAdd: ((String) -> Void)?
    /// 删除标签回调
    private let onRemove: ((String) -> Void)?
    /// 标签被拒绝（重复 / 超上限）回调
    private let onReject: ((String) -> Void)?

    /// 输入框里的文字
    @State private var input: String = ""

    /// 创建标签输入框
    /// - Parameters:
    ///   - tags: 已选标签（双向绑定）
    ///   - placeholder: 占位文字，默认「输入后回车添加」
    ///   - maxTags: 标签数量上限，默认 `0`（不限）
    ///   - allowsDuplicates: 是否允许重复标签，默认 `false`
    ///   - tagColor: 标签块主题色，默认 `.accentColor`
    ///   - onAdd: 新增标签回调，默认 `nil`
    ///   - onRemove: 删除标签回调，默认 `nil`
    ///   - onReject: 标签被拒绝的回调，默认 `nil`
    public init(tags: Binding<[String]>,
                placeholder: String = "输入后回车添加",
                maxTags: Int = 0,
                allowsDuplicates: Bool = false,
                tagColor: Color = .accentColor,
                onAdd: ((String) -> Void)? = nil,
                onRemove: ((String) -> Void)? = nil,
                onReject: ((String) -> Void)? = nil) {
        self._tags = tags
        self.placeholder = placeholder
        self.maxTags = maxTags
        self.allowsDuplicates = allowsDuplicates
        self.tagColor = tagColor
        self.onAdd = onAdd
        self.onRemove = onRemove
        self.onReject = onReject
    }

    // MARK: - 纯逻辑（可单测）

    /// 把一段输入拆成若干候选标签
    ///
    /// 支持半角逗号、全角逗号、顿号三种分隔符（中文用户常见），并去掉每段首尾空白与空串——
    /// 所以 `"a, b，，c、"` 会得到 `["a", "b", "c"]`。
    public static func parse(_ raw: String) -> [String] {
        raw.components(separatedBy: CharacterSet(charactersIn: ",，、"))
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    /// 把候选标签并入已有标签，并报告哪些被采纳、哪些被拒绝
    ///
    /// 拒绝的两种情况：已达数量上限、重复且不允许重复。被拒绝的候选**不会**占位，
    /// 后续候选仍有机会被采纳。
    ///
    /// - Parameters:
    ///   - candidates: 候选标签（一般来自 `parse(_:)`）
    ///   - tags: 已有标签
    ///   - maxTags: 数量上限，`0` 表示不限
    ///   - allowsDuplicates: 是否允许重复
    /// - Returns: `tags` 为合并结果，`added` 为被采纳的，`rejected` 为被拒绝的
    public static func applied(_ candidates: [String],
                               to tags: [String],
                               maxTags: Int,
                               allowsDuplicates: Bool) -> (tags: [String], added: [String], rejected: [String]) {
        var result = tags
        var added: [String] = []
        var rejected: [String] = []
        for candidate in candidates {
            if maxTags > 0, result.count >= maxTags {
                rejected.append(candidate)
                continue
            }
            if !allowsDuplicates, result.contains(candidate) {
                rejected.append(candidate)
                continue
            }
            result.append(candidate)
            added.append(candidate)
        }
        return (result, added, rejected)
    }

    /// 是否已达到数量上限
    public var isFull: Bool {
        maxTags > 0 && tags.count >= maxTags
    }

    // MARK: - 视图

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if !tags.isEmpty {
                FlowLayout(spacing: 6, lineSpacing: 6) {
                    ForEach(Array(tags.enumerated()), id: \.offset) { index, tag in
                        chip(tag, at: index)
                    }
                }
            }
            inputRow
            if isFull {
                Text("最多 \(maxTags) 个标签")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.secondary.opacity(0.08))
        )
    }

    /// 一个标签块（文字 + 删除按钮）
    private func chip(_ tag: String, at index: Int) -> some View {
        HStack(spacing: 4) {
            Text(tag)
                .font(.callout)
            Button {
                remove(at: index)
            } label: {
                Image(systemName: "xmark")
                    .font(.caption2.weight(.bold))
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(Capsule().fill(tagColor.opacity(0.15)))
        .foregroundStyle(tagColor)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("标签 \(tag)")
        .accessibilityHint("双击删除")
    }

    /// 输入行：文本框 + 有内容时显示的清空按钮
    private var inputRow: some View {
        HStack(spacing: 6) {
            TextField(placeholder, text: $input)
                .textFieldStyle(.plain)
                .font(.callout)
                .disabled(isFull)
                .onSubmit(commit)
            if !input.isEmpty {
                Button {
                    input = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("清空输入")
            }
        }
    }

    // MARK: - 交互

    /// 把输入框里的内容转成标签（回车或提交时调用）
    private func commit() {
        let candidates = Self.parse(input)
        input = ""
        guard !candidates.isEmpty else { return }
        let outcome = Self.applied(candidates,
                                   to: tags,
                                   maxTags: maxTags,
                                   allowsDuplicates: allowsDuplicates)
        tags = outcome.tags
        outcome.added.forEach { onAdd?($0) }
        outcome.rejected.forEach { onReject?($0) }
    }

    private func remove(at index: Int) {
        guard tags.indices.contains(index) else { return }
        let removed = tags.remove(at: index)
        onRemove?(removed)
    }
}

// MARK: 中文命名别名

/// 中文名：标签输入（等同 `TagInput`）
@available(iOS 16.0, macOS 13.0, *)
public typealias 标签输入 = TagInput

@available(iOS 16.0, macOS 13.0, *)
public extension TagInput {

    /// 标签输入框（中文参数）
    ///
    /// 首参 `标签` 无默认值，不会与英文 `init(tags:…)`（除 tags 外全有默认值）产生歧义。
    ///
    /// - Parameters:
    ///   - 标签: 已选标签（双向绑定）
    ///   - 占位: 占位文字，默认「输入后回车添加」
    ///   - 最大数量: 标签数量上限，默认 `0`（不限）
    ///   - 允许重复: 是否允许重复标签，默认 `false`
    ///   - 标签颜色: 标签块主题色，默认 `.accentColor`
    ///   - 添加: 新增标签回调
    ///   - 移除: 删除标签回调
    ///   - 拒绝: 标签被拒绝的回调
    init(标签: Binding<[String]>,
         占位: String = "输入后回车添加",
         最大数量: Int = 0,
         允许重复: Bool = false,
         标签颜色: Color = .accentColor,
         添加: ((String) -> Void)? = nil,
         移除: ((String) -> Void)? = nil,
         拒绝: ((String) -> Void)? = nil) {
        self.init(tags: 标签,
                  placeholder: 占位,
                  maxTags: 最大数量,
                  allowsDuplicates: 允许重复,
                  tagColor: 标签颜色,
                  onAdd: 添加,
                  onRemove: 移除,
                  onReject: 拒绝)
    }

    /// 拆分输入（等同 `parse(_:)`）
    static func 拆分(_ 原文: String) -> [String] {
        parse(原文)
    }

    /// 合并标签（等同 `applied(_:to:maxTags:allowsDuplicates:)`）
    static func 合并(_ 候选: [String],
                   已有: [String],
                   最大数量: Int = 0,
                   允许重复: Bool = false) -> (tags: [String], added: [String], rejected: [String]) {
        applied(候选, to: 已有, maxTags: 最大数量, allowsDuplicates: 允许重复)
    }
}
