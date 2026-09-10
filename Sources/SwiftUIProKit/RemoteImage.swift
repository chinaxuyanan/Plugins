import SwiftUI

// MARK: - 远程图片

/// 远程图片：`AsyncImage` 的封装
///
/// 一行代码搞定「远程图片 + 加载占位 + 失败重试 + 圆角 + 固定尺寸」，
/// 省掉每次手写 `AsyncImage` 的 `empty / success / failure` 三段式。
///
/// - Example:
///   ```swift
///   RemoteImage(url: avatarURL, cornerRadius: 8, size: CGSize(width: 64, height: 64))
///   RemoteImage(url: bannerURL) {
///       ProgressView()          // 自定义占位
///   } failure: {
///       Image(systemName: "photo")   // 自定义失败视图
///   }
///   ```
public struct RemoteImage: View {

    /// 图片地址（`nil` 时直接显示占位）
    private let url: URL?
    /// 圆角半径
    private let cornerRadius: CGFloat
    /// 固定尺寸（`nil` 表示由父视图决定）
    private let size: CGSize?
    /// 缩放模式
    private let contentMode: ContentMode
    /// 失败时是否可点击重试
    private let showsRetry: Bool
    /// 自定义占位视图（`nil` 用内置占位）
    private let customPlaceholder: AnyView?
    /// 自定义失败视图（`nil` 用内置失败视图）
    private let customFailure: AnyView?

    /// 重试计数：自增后视图被重新创建，从而重新发起请求
    @State private var attempt = 0

    /// 使用内置占位 / 失败视图
    ///
    /// - Parameters:
    ///   - url: 图片地址
    ///   - cornerRadius: 圆角半径，默认 `0`
    ///   - size: 固定尺寸，默认 `nil`（自适应父视图）
    ///   - contentMode: 缩放模式，默认 `.fill`
    ///   - showsRetry: 加载失败时是否可点击重试，默认 `true`
    public init(url: URL?,
                cornerRadius: CGFloat = 0,
                size: CGSize? = nil,
                contentMode: ContentMode = .fill,
                showsRetry: Bool = true) {
        self.url = url
        self.cornerRadius = cornerRadius
        self.size = size
        self.contentMode = contentMode
        self.showsRetry = showsRetry
        self.customPlaceholder = nil
        self.customFailure = nil
    }

    /// 自定义占位 / 失败视图
    ///
    /// - Parameters:
    ///   - url: 图片地址
    ///   - cornerRadius: 圆角半径，默认 `0`
    ///   - size: 固定尺寸，默认 `nil`（自适应父视图）
    ///   - contentMode: 缩放模式，默认 `.fill`
    ///   - placeholder: 加载中的占位视图
    ///   - failure: 加载失败的视图
    public init<P: View, F: View>(url: URL?,
                                  cornerRadius: CGFloat = 0,
                                  size: CGSize? = nil,
                                  contentMode: ContentMode = .fill,
                                  @ViewBuilder placeholder: () -> P,
                                  @ViewBuilder failure: () -> F) {
        self.url = url
        self.cornerRadius = cornerRadius
        self.size = size
        self.contentMode = contentMode
        self.showsRetry = false
        self.customPlaceholder = AnyView(placeholder())
        self.customFailure = AnyView(failure())
    }

    public var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: contentMode)
            case .failure:
                failureContent
                    .contentShape(Rectangle())
                    .onTapGesture { if showsRetry { attempt += 1 } }
            case .empty:
                placeholderContent
            @unknown default:
                placeholderContent
            }
        }
        .frame(width: size?.width, height: size?.height)
        .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        .id(attempt)
    }

    /// 占位视图：自定义优先，否则灰底 + 转圈
    @ViewBuilder
    private var placeholderContent: some View {
        if let customPlaceholder = customPlaceholder {
            customPlaceholder
        } else {
            ZStack {
                Color.gray.opacity(0.15)
                ProgressView()
            }
        }
    }

    /// 失败视图：自定义优先，否则灰底 + 感叹号（+ 重试提示）
    @ViewBuilder
    private var failureContent: some View {
        if let customFailure = customFailure {
            customFailure
        } else {
            ZStack {
                Color.gray.opacity(0.15)
                VStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 16))
                        .foregroundStyle(.secondary)
                    if showsRetry {
                        Text("点击重试")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}

// MARK: 中文命名别名

/// 中文名：远程图片（等同 `RemoteImage`）
public typealias 远程图片 = RemoteImage

public extension RemoteImage {

    /// 远程图片（中文参数，使用内置占位 / 失败视图）
    /// - Parameters:
    ///   - 网址: 图片地址
    ///   - 圆角: 圆角半径，默认 `0`
    ///   - 尺寸: 固定尺寸，默认 `nil`（自适应父视图）
    ///   - 填充模式: 缩放模式，默认 `.fill`
    ///   - 显示重试: 加载失败时是否可点击重试，默认 `true`
    init(网址: URL?,
         圆角: CGFloat = 0,
         尺寸: CGSize? = nil,
         填充模式: ContentMode = .fill,
         显示重试: Bool = true) {
        self.init(url: 网址, cornerRadius: 圆角, size: 尺寸,
                  contentMode: 填充模式, showsRetry: 显示重试)
    }

    /// 远程图片（中文参数，自定义占位 / 失败视图）
    /// - Parameters:
    ///   - 网址: 图片地址
    ///   - 圆角: 圆角半径，默认 `0`
    ///   - 尺寸: 固定尺寸，默认 `nil`（自适应父视图）
    ///   - 填充模式: 缩放模式，默认 `.fill`
    ///   - 占位: 加载中的占位视图
    ///   - 失败: 加载失败的视图
    init<P: View, F: View>(网址: URL?,
                           圆角: CGFloat = 0,
                           尺寸: CGSize? = nil,
                           填充模式: ContentMode = .fill,
                           @ViewBuilder 占位: () -> P,
                           @ViewBuilder 失败: () -> F) {
        self.init(url: 网址, cornerRadius: 圆角, size: 尺寸,
                  contentMode: 填充模式, placeholder: 占位, failure: 失败)
    }
}
