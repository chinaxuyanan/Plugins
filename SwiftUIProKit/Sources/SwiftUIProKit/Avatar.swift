import SwiftUI

// MARK: - 头像

/// 头像右下角的在线状态小圆点
public enum AvatarStatus {
    /// 在线（绿色）
    case online
    /// 离线（灰色）
    case offline
    /// 忙碌（红色）
    case busy
    /// 离开（橙色）
    case away

    /// 小圆点的颜色
    var color: Color {
        switch self {
        case .online: return .green
        case .offline: return .gray
        case .busy: return .red
        case .away: return .orange
        }
    }
}

/// 中文名：头像状态（等同 `AvatarStatus`）
public typealias 头像状态 = AvatarStatus

/// 头像
///
/// 圆形头像，三种内容来源：文字（根据姓名自动取首字生成占位）、本地图片、远程图片。
/// 可选描边与右下角的在线状态小圆点。文字占位时底色由姓名稳定派生，
/// 同一个名字每次渲染颜色一致。
///
/// - Example:
///   ```swift
///   Avatar("张三")
///   Avatar("Alice", size: 56, status: .online)
///   Avatar(image: Image("logo"), showsBorder: true)
///   Avatar(url: URL(string: "https://example.com/a.png"))
///   ```
public struct Avatar: View {

    /// 内容来源
    private enum Source {
        /// 文字（姓名），用于生成首字占位
        case initials(String)
        /// 本地图片
        case image(Image)
        /// 远程图片
        case url(URL?)
    }

    private let source: Source
    private let size: CGFloat
    private let tint: Color?
    private let showsBorder: Bool
    private let borderColor: Color
    private let status: AvatarStatus?

    /// - Parameters:
    ///   - name: 姓名，自动取首字（中文取前两字、英文取首字母）生成占位
    ///   - size: 直径，默认 `44`
    ///   - tint: 文字占位的底色；传 `nil` 时按姓名稳定派生，默认 `nil`
    ///   - showsBorder: 是否显示描边，默认 `false`
    ///   - borderColor: 描边颜色，默认 `.white`
    ///   - status: 右下角在线状态小圆点，默认 `nil`（不显示）
    public init(_ name: String,
                size: CGFloat = 44,
                tint: Color? = nil,
                showsBorder: Bool = false,
                borderColor: Color = .white,
                status: AvatarStatus? = nil) {
        self.init(source: .initials(name), size: size, tint: tint,
                  showsBorder: showsBorder, borderColor: borderColor, status: status)
    }

    /// 本地图片头像
    /// - Parameters:
    ///   - image: 图片
    ///   - size: 直径，默认 `44`
    ///   - showsBorder: 是否显示描边，默认 `false`
    ///   - borderColor: 描边颜色，默认 `.white`
    ///   - status: 右下角在线状态小圆点，默认 `nil`
    public init(image: Image,
                size: CGFloat = 44,
                showsBorder: Bool = false,
                borderColor: Color = .white,
                status: AvatarStatus? = nil) {
        self.init(source: .image(image), size: size, tint: nil,
                  showsBorder: showsBorder, borderColor: borderColor, status: status)
    }

    /// 远程图片头像（内部用 `RemoteImage`，加载中显示占位、失败可点击重试）
    /// - Parameters:
    ///   - url: 图片地址；传 `nil` 时显示占位
    ///   - size: 直径，默认 `44`
    ///   - showsBorder: 是否显示描边，默认 `false`
    ///   - borderColor: 描边颜色，默认 `.white`
    ///   - status: 右下角在线状态小圆点，默认 `nil`
    public init(url: URL?,
                size: CGFloat = 44,
                showsBorder: Bool = false,
                borderColor: Color = .white,
                status: AvatarStatus? = nil) {
        self.init(source: .url(url), size: size, tint: nil,
                  showsBorder: showsBorder, borderColor: borderColor, status: status)
    }

    private init(source: Source,
                 size: CGFloat,
                 tint: Color?,
                 showsBorder: Bool,
                 borderColor: Color,
                 status: AvatarStatus?) {
        self.source = source
        self.size = max(16, size)
        self.tint = tint
        self.showsBorder = showsBorder
        self.borderColor = borderColor
        self.status = status
    }

    public var body: some View {
        content
            .frame(width: size, height: size)
            .clipShape(Circle())
            .overlay {
                if showsBorder {
                    Circle().strokeBorder(borderColor, lineWidth: max(1, size * 0.05))
                }
            }
            .overlay(alignment: .bottomTrailing) {
                if let status = status {
                    Circle()
                        .fill(status.color)
                        .frame(width: size * 0.28, height: size * 0.28)
                        .overlay {
                            Circle().strokeBorder(Color.systemBackground, lineWidth: max(1, size * 0.04))
                        }
                }
            }
    }

    // MARK: 内容

    @ViewBuilder
    private var content: some View {
        switch source {
        case .initials(let name):
            ZStack {
                backgroundColor(for: name)
                Text(Self.initials(from: name))
                    .font(.system(size: size * 0.4, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding(.horizontal, size * 0.12)
            }
        case .image(let image):
            image.resizable().scaledToFill()
        case .url(let url):
            RemoteImage(url: url,
                        size: CGSize(width: size, height: size),
                        contentMode: .fill,
                        showsRetry: false)
        }
    }

    // MARK: 首字与配色

    /// 文字占位可选的底色（按姓名稳定挑选其中一个）
    private static let palette: [Color] = [.blue, .green, .orange, .purple, .pink, .teal, .indigo, .red]

    /// 取姓名首字：拉丁字母取首字母大写，中日韩等取前两字
    static func initials(from name: String) -> String {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return "?" }

        // 英文姓名（含空格）→ 取前两个单词的首字母
        let words = trimmed.split(separator: " ")
        if words.count >= 2, let first = words.first?.first, let second = words[1].first {
            return "\(first)\(second)".uppercased()
        }
        // 纯 ASCII → 首字母；否则（中文等）取前两字
        let isASCII = trimmed.allSatisfy { $0.isASCII }
        return isASCII ? String(trimmed.prefix(1)).uppercased() : String(trimmed.prefix(2))
    }

    /// 文字占位底色：显式 `tint` 优先，否则按姓名派生（同名同色）
    private func backgroundColor(for name: String) -> Color {
        if let tint = tint { return tint }
        let sum = name.unicodeScalars.reduce(0) { $0 &+ Int($1.value) }
        return Self.palette[abs(sum) % Self.palette.count]
    }
}

// MARK: - 头像组

/// 头像组
///
/// 把多个头像重叠排成一串，超出 `maxVisible` 的部分折叠成「+N」气泡，
/// 常用于「参与人 / 点赞人」列表。头像之间用 `separatorColor` 描边分隔。
///
/// - Note: 每个头像的直径由它自己（`Avatar(size:)`）决定，本视图的 `size`
///   只用于「+N」气泡，建议两者保持一致。
///
/// - Example:
///   ```swift
///   AvatarGroup(avatars: [Avatar("张三", size: 32), Avatar("李四", size: 32)], size: 32)
///   ```
public struct AvatarGroup: View {

    private let avatars: [Avatar]
    private let size: CGFloat
    private let overlap: CGFloat
    private let maxVisible: Int
    private let separatorColor: Color
    private let overflowTint: Color

    /// - Parameters:
    ///   - avatars: 头像数组（顺序即从左到右）
    ///   - size: 「+N」气泡的直径，默认 `32`
    ///   - overlap: 相邻头像的重叠宽度，默认 `10`
    ///   - maxVisible: 最多显示几个头像，超出折叠为「+N」，默认 `4`
    ///   - separatorColor: 头像之间的描边色，默认 `.systemBackground`
    ///   - overflowTint: 「+N」气泡的底色，默认 `.gray`
    public init(avatars: [Avatar],
                size: CGFloat = 32,
                overlap: CGFloat = 10,
                maxVisible: Int = 4,
                separatorColor: Color = .systemBackground,
                overflowTint: Color = .gray) {
        self.avatars = avatars
        self.size = max(16, size)
        self.overlap = max(0, overlap)
        self.maxVisible = max(1, maxVisible)
        self.separatorColor = separatorColor
        self.overflowTint = overflowTint
    }

    public var body: some View {
        let visible = Array(avatars.prefix(maxVisible))
        let overflow = avatars.count - visible.count

        HStack(spacing: -overlap) {
            ForEach(Array(visible.enumerated()), id: \.offset) { index, avatar in
                avatar
                    .overlay {
                        Circle().strokeBorder(separatorColor, lineWidth: 2)
                    }
                    // 前面的头像压住后面的，视觉上像一叠卡片
                    .zIndex(Double(visible.count - index))
            }
            if overflow > 0 {
                ZStack {
                    Circle().fill(overflowTint.opacity(0.22))
                    Text("+\(overflow)")
                        .font(.system(size: size * 0.36, weight: .semibold))
                        .foregroundStyle(.secondary)
                }
                .frame(width: size, height: size)
                .overlay {
                    Circle().strokeBorder(separatorColor, lineWidth: 2)
                }
            }
        }
    }
}

// MARK: 中文命名别名

/// 中文名：头像（等同 `Avatar`）
public typealias 头像 = Avatar

/// 中文名：头像组（等同 `AvatarGroup`）
public typealias 头像组 = AvatarGroup

public extension Avatar {

    /// 头像（中文参数，文字占位）
    /// - Parameters:
    ///   - 姓名: 姓名，自动取首字生成占位
    ///   - 尺寸: 直径，默认 `44`
    ///   - 底色: 文字占位的底色；传 `nil` 时按姓名稳定派生，默认 `nil`
    ///   - 描边: 是否显示描边，默认 `false`
    ///   - 描边颜色: 描边颜色，默认 `.white`
    ///   - 状态: 右下角在线状态小圆点，默认 `nil`
    init(姓名: String,
         尺寸: CGFloat = 44,
         底色: Color? = nil,
         描边: Bool = false,
         描边颜色: Color = .white,
         状态: AvatarStatus? = nil) {
        self.init(姓名, size: 尺寸, tint: 底色, showsBorder: 描边,
                  borderColor: 描边颜色, status: 状态)
    }

    /// 头像（中文参数，本地图片）
    init(图片: Image,
         尺寸: CGFloat = 44,
         描边: Bool = false,
         描边颜色: Color = .white,
         状态: AvatarStatus? = nil) {
        self.init(image: 图片, size: 尺寸, showsBorder: 描边,
                  borderColor: 描边颜色, status: 状态)
    }

    /// 头像（中文参数，远程图片）
    init(网址: URL?,
         尺寸: CGFloat = 44,
         描边: Bool = false,
         描边颜色: Color = .white,
         状态: AvatarStatus? = nil) {
        self.init(url: 网址, size: 尺寸, showsBorder: 描边,
                  borderColor: 描边颜色, status: 状态)
    }
}

public extension AvatarGroup {

    /// 头像组（中文参数）
    /// - Parameters:
    ///   - 头像列表: 头像数组（顺序即从左到右）
    ///   - 尺寸: 「+N」气泡的直径，默认 `32`
    ///   - 重叠: 相邻头像的重叠宽度，默认 `10`
    ///   - 最多显示: 最多显示几个头像，超出折叠为「+N」，默认 `4`
    ///   - 分隔颜色: 头像之间的描边色，默认 `.systemBackground`
    ///   - 溢出底色: 「+N」气泡的底色，默认 `.gray`
    init(头像列表: [Avatar],
         尺寸: CGFloat = 32,
         重叠: CGFloat = 10,
         最多显示: Int = 4,
         分隔颜色: Color = .systemBackground,
         溢出底色: Color = .gray) {
        self.init(avatars: 头像列表, size: 尺寸, overlap: 重叠, maxVisible: 最多显示,
                  separatorColor: 分隔颜色, overflowTint: 溢出底色)
    }
}
