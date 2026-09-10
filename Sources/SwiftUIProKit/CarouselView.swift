import SwiftUI
import Combine

// MARK: - 轮播图

/// 轮播图：自动轮播的多页内容 + 分页圆点指示器
///
/// 基于 `TabView(.page)` + `Timer` 实现，每隔固定时长自动切到下一页，循环播放。
/// 支持两种内容来源：SF Symbol 图标数组、任意视图数组（内部做类型擦除）。
///
/// - Example:
///   ```swift
///   // SF Symbol 轮播
///   CarouselView(systemImages: ["photo", "camera", "star"])
///
///   // 任意视图轮播
///   CarouselView(views: [banner1, banner2, banner3], interval: 4, height: 200)
///   ```
public struct CarouselView: View {

    /// 轮播页面（类型擦除）
    private let pages: [AnyView]
    /// 自动切换间隔（秒），内部下限为 `0.5` 秒防止误填 `0`
    private let interval: TimeInterval
    /// 轮播区高度；`nil` 表示自适应内容高度
    private let height: CGFloat?
    /// 是否显示分页圆点指示器
    private let showsIndicators: Bool
    /// 定时器（创建时按 `interval` 配置，避免 body 重算时重置）
    private let timer: Publishers.Autoconnect<Timer.TimerPublisher>

    /// 当前页码
    @State private var currentIndex = 0

    /// SF Symbol 图标轮播
    ///
    /// - Parameters:
    ///   - systemImages: SF Symbol 图标名数组
    ///   - interval: 自动切换间隔（秒），默认 `3`
    ///   - height: 轮播区高度，默认 `nil`（自适应）
    ///   - showsIndicators: 是否显示分页圆点，默认 `true`
    public init(systemImages: [String],
                interval: TimeInterval = 3,
                height: CGFloat? = nil,
                showsIndicators: Bool = true) {
        self.pages = systemImages.map {
            AnyView(
                Image(systemName: $0)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(.secondary)
                    .padding(24)
            )
        }
        self.interval = interval
        self.height = height
        self.showsIndicators = showsIndicators
        self.timer = CarouselView.makeTimer(interval: interval)
    }

    /// 任意视图轮播
    ///
    /// - Parameters:
    ///   - views: 每页内容视图数组
    ///   - interval: 自动切换间隔（秒），默认 `3`
    ///   - height: 轮播区高度，默认 `nil`（自适应）
    ///   - showsIndicators: 是否显示分页圆点，默认 `true`
    public init<Content: View>(views: [Content],
                               interval: TimeInterval = 3,
                               height: CGFloat? = nil,
                               showsIndicators: Bool = true) {
        self.pages = views.map { AnyView($0) }
        self.interval = interval
        self.height = height
        self.showsIndicators = showsIndicators
        self.timer = CarouselView.makeTimer(interval: interval)
    }

    public var body: some View {
        VStack(spacing: 10) {
            pageView
                .clipped()
                .animation(.easeInOut(duration: 0.25), value: currentIndex)

            if showsIndicators && pages.count > 1 {
                indicators
            }
        }
        .onReceive(timer) { _ in
            guard pages.count > 1 else { return }
            currentIndex = (currentIndex + 1) % pages.count
        }
    }

    /// 分页内容区
    @ViewBuilder
    private var pageView: some View {
        TabView(selection: $currentIndex) {
            ForEach(pages.indices, id: \.self) { index in
                pages[index]
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: height)
    }

    /// 分页圆点指示器
    private var indicators: some View {
        HStack(spacing: 6) {
            ForEach(pages.indices, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? Color.accentColor : Color.secondary.opacity(0.3))
                    .frame(width: 7, height: 7)
                    .animation(.easeInOut(duration: 0.2), value: currentIndex)
            }
        }
    }

    /// 构造自动轮播定时器（间隔至少 0.5 秒，避免 `Timer` 间隔为 0 崩溃）
    private static func makeTimer(interval: TimeInterval) -> Publishers.Autoconnect<Timer.TimerPublisher> {
        Timer.publish(every: max(0.5, interval), on: .main, in: .common).autoconnect()
    }
}

// MARK: 中文命名别名

/// 中文名：轮播图（等同 `CarouselView`）
public typealias 轮播图 = CarouselView

public extension CarouselView {
    /// 轮播图（SF Symbol 图标，中文参数）
    /// - Parameters:
    ///   - 系统图标: SF Symbol 图标名数组
    ///   - 间隔: 自动切换间隔（秒），默认 `3`
    ///   - 高度: 轮播区高度，默认 `nil`（自适应）
    ///   - 显示指示器: 是否显示分页圆点，默认 `true`
    init(系统图标: [String], 间隔: TimeInterval = 3, 高度: CGFloat? = nil, 显示指示器: Bool = true) {
        self.init(systemImages: 系统图标, interval: 间隔, height: 高度, showsIndicators: 显示指示器)
    }

    /// 轮播图（任意视图，中文参数）
    /// - Parameters:
    ///   - 视图: 每页内容视图数组
    ///   - 间隔: 自动切换间隔（秒），默认 `3`
    ///   - 高度: 轮播区高度，默认 `nil`（自适应）
    ///   - 显示指示器: 是否显示分页圆点，默认 `true`
    init<Content: View>(视图: [Content], 间隔: TimeInterval = 3, 高度: CGFloat? = nil, 显示指示器: Bool = true) {
        self.init(views: 视图, interval: 间隔, height: 高度, showsIndicators: 显示指示器)
    }
}
