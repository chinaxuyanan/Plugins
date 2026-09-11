import SwiftUI

// MARK: - 图片对比滑块

/// 图片对比滑块（拖动分割线比较前后两张图）
///
/// 两张内容叠在一起，上层按比例从左侧裁切；拖动中间的圆形把手（或直接点击某处）
/// 即可改变分割位置。常用来做「修图前后 / 新旧版本」对比。
///
/// - Note: 传入的内容会先做**等比填充**（`scaledToFill`）再裁切，
///   所以最省事的用法是直接传 `Image`（见 `init(beforeImage:afterImage:)`）；
///   传自定义视图时也建议让它自己填满容器。
///
/// - Example:
///   ```swift
///   BeforeAfterSlider(beforeImage: 原图, afterImage: 修图后)
///       .frame(height: 260)
///
///   BeforeAfterSlider(before: { 左视图 }, after: { 右视图 }, initialRatio: 0.3)
///       .frame(height: 240)
///   ```
/// 中文名 `图片对比滑块` 与 `BeforeAfterSlider` 等价。
public struct BeforeAfterSlider<Before: View, After: View>: View {

    /// 左侧（前）内容
    private let before: Before
    /// 右侧（后）内容
    private let after: After
    /// 外部绑定的分割比例（`0...1`，可为空）
    private let ratioBinding: Binding<CGFloat>?
    /// 把手直径
    private let handleSize: CGFloat
    /// 容器圆角
    private let cornerRadius: CGFloat
    /// 是否显示「前 / 后」标签
    private let showsLabels: Bool
    /// 左侧标签文字
    private let beforeLabel: String
    /// 右侧标签文字
    private let afterLabel: String

    /// 内部维护的分割比例（未绑定外部时使用）
    @State private var internalRatio: CGFloat

    /// 创建图片对比滑块
    /// - Parameters:
    ///   - before: 左侧（前）内容
    ///   - after: 右侧（后）内容
    ///   - ratio: 外部绑定的分割比例，默认 `nil`（内部自管）
    ///   - initialRatio: 初始分割比例，默认 `0.5`
    ///   - handleSize: 把手直径，默认 `34`
    ///   - cornerRadius: 容器圆角，默认 `12`
    ///   - showsLabels: 是否显示前后标签，默认 `true`
    ///   - beforeLabel: 左侧标签文字，默认「前」
    ///   - afterLabel: 右侧标签文字，默认「后」
    public init(@ViewBuilder before: () -> Before,
                @ViewBuilder after: () -> After,
                ratio: Binding<CGFloat>? = nil,
                initialRatio: CGFloat = 0.5,
                handleSize: CGFloat = 34,
                cornerRadius: CGFloat = 12,
                showsLabels: Bool = true,
                beforeLabel: String = "前",
                afterLabel: String = "后") {
        self.before = before()
        self.after = after()
        self.ratioBinding = ratio
        self.handleSize = handleSize
        self.cornerRadius = cornerRadius
        self.showsLabels = showsLabels
        self.beforeLabel = beforeLabel
        self.afterLabel = afterLabel
        _internalRatio = State(initialValue: Self.clampRatio(initialRatio))
    }

    // MARK: 纯逻辑

    /// 把比例夹到 `0...1`
    /// - Parameter value: 原始比例
    public static func clampRatio(_ value: CGFloat) -> CGFloat {
        guard value.isFinite else { return 0.5 }
        return min(1, max(0, value))
    }

    /// 根据横坐标算出分割比例
    /// - Parameters:
    ///   - x: 横坐标（相对容器左边缘）
    ///   - width: 容器宽度
    public static func ratio(x: CGFloat, width: CGFloat) -> CGFloat {
        guard width > 0 else { return 0.5 }
        return clampRatio(x / width)
    }

    // MARK: 视图

    public var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            let ratio = currentRatio
            ZStack(alignment: .leading) {
                filled(after)
                filled(before)
                    .mask(alignment: .leading) {
                        Rectangle().frame(width: max(0, width * ratio))
                    }
                divider(height: height)
                    .position(x: width * ratio, y: height / 2)
            }
            .frame(width: width, height: height)
            .overlay(alignment: .top) { labelRow }
            .contentShape(Rectangle())
            .gesture(dragGesture(width: width))
        }
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }

    /// 让内容等比填满容器再裁切
    private func filled<V: View>(_ view: V) -> some View {
        view
            .scaledToFill()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .clipped()
    }

    private func divider(height: CGFloat) -> some View {
        ZStack {
            Rectangle()
                .fill(Color.white)
                .frame(width: 2.5)
            Circle()
                .fill(Color.white)
                .frame(width: handleSize, height: handleSize)
                .shadow(color: Color.black.opacity(0.25), radius: 3)
                .overlay(
                    HStack(spacing: 3) {
                        Image(systemName: "chevron.left")
                        Image(systemName: "chevron.right")
                    }
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color.secondary)
                )
        }
        .frame(height: height)
    }

    @ViewBuilder
    private var labelRow: some View {
        if showsLabels {
            HStack {
                labelPill(beforeLabel)
                Spacer(minLength: 0)
                labelPill(afterLabel)
            }
            .padding(10)
        }
    }

    private func labelPill(_ text: String) -> some View {
        Text(text)
            .font(.caption2)
            .foregroundStyle(Color.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(Capsule().fill(Color.black.opacity(0.45)))
    }

    // MARK: 拖动

    private func dragGesture(width: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                setRatio(Self.ratio(x: value.location.x, width: width))
            }
    }

    private var currentRatio: CGFloat {
        Self.clampRatio(ratioBinding?.wrappedValue ?? internalRatio)
    }

    private func setRatio(_ value: CGFloat) {
        if let ratioBinding = ratioBinding {
            ratioBinding.wrappedValue = value
        } else {
            internalRatio = value
        }
    }
}

// MARK: 图片便捷初始化

public extension BeforeAfterSlider where Before == Image, After == Image {

    /// 用两张 `Image` 创建对比滑块（自动等比填充）
    init(beforeImage: Image,
         afterImage: Image,
         ratio: Binding<CGFloat>? = nil,
         initialRatio: CGFloat = 0.5,
         handleSize: CGFloat = 34,
         cornerRadius: CGFloat = 12,
         showsLabels: Bool = true,
         beforeLabel: String = "前",
         afterLabel: String = "后") {
        self.init(before: { beforeImage },
                  after: { afterImage },
                  ratio: ratio,
                  initialRatio: initialRatio,
                  handleSize: handleSize,
                  cornerRadius: cornerRadius,
                  showsLabels: showsLabels,
                  beforeLabel: beforeLabel,
                  afterLabel: afterLabel)
    }

    /// 用两张图片创建对比滑块（中文参数）
    init(前图: Image,
         后图: Image,
         比例: Binding<CGFloat>? = nil,
         初始比例: CGFloat = 0.5,
         把手大小: CGFloat = 34,
         圆角: CGFloat = 12,
         显示标签: Bool = true,
         前标签: String = "前",
         后标签: String = "后") {
        self.init(beforeImage: 前图,
                  afterImage: 后图,
                  ratio: 比例,
                  initialRatio: 初始比例,
                  handleSize: 把手大小,
                  cornerRadius: 圆角,
                  showsLabels: 显示标签,
                  beforeLabel: 前标签,
                  afterLabel: 后标签)
    }
}

// MARK: 中文命名别名

/// 中文名：图片对比滑块（等同 `BeforeAfterSlider`）
public typealias 图片对比滑块 = BeforeAfterSlider

public extension BeforeAfterSlider {

    /// 图片对比滑块（中文参数，自定义视图）
    ///
    /// 首参 `前` 无默认值，与英文重载凭标签区分，不会歧义。
    init(@ViewBuilder 前: () -> Before,
         @ViewBuilder 后: () -> After,
         比例: Binding<CGFloat>? = nil,
         初始比例: CGFloat = 0.5,
         把手大小: CGFloat = 34,
         圆角: CGFloat = 12,
         显示标签: Bool = true,
         前标签: String = "前",
         后标签: String = "后") {
        self.init(before: 前,
                  after: 后,
                  ratio: 比例,
                  initialRatio: 初始比例,
                  handleSize: 把手大小,
                  cornerRadius: 圆角,
                  showsLabels: 显示标签,
                  beforeLabel: 前标签,
                  afterLabel: 后标签)
    }

    /// 把比例夹到 `0...1`（等同 `clampRatio(_:)`）
    static func 限定比例(_ 值: CGFloat) -> CGFloat {
        clampRatio(值)
    }

    /// 根据横坐标算分割比例（等同 `ratio(x:width:)`）
    static func 计算比例(横坐标: CGFloat, 宽度: CGFloat) -> CGFloat {
        ratio(x: 横坐标, width: 宽度)
    }
}
