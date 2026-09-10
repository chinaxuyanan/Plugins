import SwiftUI

// MARK: - 引导页

/// 引导页单页内容
///
/// 图标 + 标题 + 描述的结构化数据，供 `OnboardingView` 逐页展示。
public struct OnboardingPage {
    /// SF Symbol 图标名
    public let icon: String
    /// 标题
    public let title: String
    /// 描述文字
    public let message: String

    /// - Parameters:
    ///   - icon: SF Symbol 图标名
    ///   - title: 标题
    ///   - message: 描述文字
    public init(icon: String, title: String, message: String) {
        self.icon = icon
        self.title = title
        self.message = message
    }
}

/// 引导页：多页滑动引导 + 跳过 / 下一步 / 开始使用
///
/// 跨平台实现：iOS 用 `TabView(.page)` 左右滑动翻页，macOS 用交叉淡入淡出切换。
/// 底部提供「跳过」与「下一步 / 开始使用」按钮，最后一页的按钮文案变为「开始使用」并触发 `onFinish`。
///
/// - Example:
///   ```swift
///   OnboardingView(pages: [
///       OnboardingPage(icon: "sparkles", title: "欢迎", message: "这是第一页"),
///       OnboardingPage(icon: "star", title: "强大", message: "这是第二页"),
///   ]) {
///       print("用户看完引导页")
///   }
///   ```
public struct OnboardingView: View {

    /// 引导页内容
    private let pages: [OnboardingPage]
    /// 「跳过」按钮文字
    private let skipTitle: String
    /// 「下一步」按钮文字
    private let nextTitle: String
    /// 「开始使用」按钮文字（最后一页）
    private let finishTitle: String
    /// 主色调
    private let tint: Color
    /// 点击「跳过」回调（可选）
    private let onSkip: (() -> Void)?
    /// 点击「开始使用」回调（可选）
    private let onFinish: (() -> Void)?

    /// 当前页码
    @State private var index = 0

    /// - Parameters:
    ///   - pages: 引导页内容数组
    ///   - skipTitle: 「跳过」按钮文字，默认「跳过」
    ///   - nextTitle: 「下一步」按钮文字，默认「下一步」
    ///   - finishTitle: 「开始使用」按钮文字，默认「开始使用」
    ///   - tint: 主色调，默认 `.accentColor`
    ///   - onSkip: 点击「跳过」回调（可选）
    ///   - onFinish: 点击「开始使用」回调（可选）
    public init(pages: [OnboardingPage],
                skipTitle: String = "跳过",
                nextTitle: String = "下一步",
                finishTitle: String = "开始使用",
                tint: Color = .accentColor,
                onSkip: (() -> Void)? = nil,
                onFinish: (() -> Void)? = nil) {
        self.pages = pages
        self.skipTitle = skipTitle
        self.nextTitle = nextTitle
        self.finishTitle = finishTitle
        self.tint = tint
        self.onSkip = onSkip
        self.onFinish = onFinish
    }

    public var body: some View {
        VStack(spacing: 0) {
            pager

            indicators
                .padding(.vertical, 12)

            buttons
                .padding(.horizontal, 20)
                .padding(.bottom, 12)
        }
    }

    #if os(iOS)
    /// 分页内容（iOS：可左右滑动的 `TabView(.page)`）
    private var pager: some View {
        TabView(selection: $index) {
            ForEach(pages.indices, id: \.self) { i in
                pageView(pages[i])
                    .tag(i)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut(duration: 0.2), value: index)
    }
    #else
    /// 分页内容（macOS：无 `.page` 样式，改用交叉淡入淡出切换当前页）
    private var pager: some View {
        Group {
            if pages.indices.contains(index) {
                pageView(pages[index])
                    .id(index)
                    .transition(.opacity)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: index)
    }
    #endif

    /// 单页内容
    private func pageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: 16) {
            Image(systemName: page.icon)
                .font(.system(size: 72))
                .foregroundStyle(tint)
                .padding(.bottom, 8)
            Text(page.title)
                .font(.title.bold())
            Text(page.message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(.top, 40)
    }

    /// 分页圆点
    private var indicators: some View {
        HStack(spacing: 6) {
            ForEach(pages.indices, id: \.self) { i in
                Capsule()
                    .fill(i == index ? tint : Color.secondary.opacity(0.3))
                    .frame(width: i == index ? 20 : 7, height: 7)
                    .animation(.easeInOut(duration: 0.2), value: index)
            }
        }
    }

    /// 底部按钮区
    private var buttons: some View {
        HStack {
            Button(skipTitle) {
                onSkip?()
            }
            .foregroundStyle(.secondary)

            Spacer()

            Button(buttonTitle) {
                advance()
            }
            .buttonStyle(.borderedProminent)
            .tint(tint)
        }
    }

    /// 当前按钮文字（最后一页为「开始使用」）
    private var buttonTitle: String {
        index >= pages.count - 1 ? finishTitle : nextTitle
    }

    /// 翻页 / 结束
    private func advance() {
        if index < pages.count - 1 {
            index += 1
        } else {
            onFinish?()
        }
    }
}

// MARK: 中文命名别名

/// 中文名：引导页内容（等同 `OnboardingPage`）
public typealias 引导页内容 = OnboardingPage

/// 中文名：引导页（等同 `OnboardingView`）
public typealias 引导页 = OnboardingView

public extension OnboardingPage {
    /// 引导页内容（中文参数）
    /// - Parameters:
    ///   - 图标: SF Symbol 图标名
    ///   - 标题: 标题
    ///   - 描述: 描述文字
    init(图标: String, 标题: String, 描述: String) {
        self.init(icon: 图标, title: 标题, message: 描述)
    }
}

public extension OnboardingView {
    /// 引导页（中文参数）
    /// - Parameters:
    ///   - 页面: 引导页内容数组
    ///   - 跳过文字: 「跳过」按钮文字，默认「跳过」
    ///   - 下一步文字: 「下一步」按钮文字，默认「下一步」
    ///   - 完成文字: 「开始使用」按钮文字，默认「开始使用」
    ///   - 颜色: 主色调，默认 `.accentColor`
    ///   - 跳过: 点击「跳过」回调（可选）
    ///   - 完成: 点击「开始使用」回调（可选）
    init(页面: [OnboardingPage],
         跳过文字: String = "跳过",
         下一步文字: String = "下一步",
         完成文字: String = "开始使用",
         颜色: Color = .accentColor,
         跳过: (() -> Void)? = nil,
         完成: (() -> Void)? = nil) {
        self.init(pages: 页面, skipTitle: 跳过文字, nextTitle: 下一步文字,
                  finishTitle: 完成文字, tint: 颜色, onSkip: 跳过, onFinish: 完成)
    }
}
