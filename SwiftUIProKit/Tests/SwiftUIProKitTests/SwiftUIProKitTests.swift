import XCTest
import SwiftUI
@testable import SwiftUIProKit

/// SwiftUIProKit 纯逻辑测试：只测可脱离视图树运行的部分（颜色十六进制解析等），View 扩展跳过。
final class SwiftUIProKitTests: XCTestCase {

    func testHexColorRoundTrip() {
        // 只用 0x00 / 0xFF 这类可精确表示的分量，避免浮点误差
        XCTAssertEqual(Color(hex: 0xFF0000).hexString, "#FF0000")
        XCTAssertEqual(Color(hex: 0x00FF00).hexString, "#00FF00")
        XCTAssertEqual(Color(hex: 0x0000FF).hexString, "#0000FF")
        XCTAssertEqual(Color(hex: 0x000000).hexString, "#000000")
        XCTAssertEqual(Color(hex: 0xFFFFFF).hexString, "#FFFFFF")
    }

    func testHexStringInit() {
        XCTAssertEqual(Color(hexString: "#FF0000").hexString, "#FF0000")
        XCTAssertEqual(Color(hexString: "00FF00").hexString, "#00FF00")
        XCTAssertEqual(Color(hexString: "#0000FFFF").hexString, "#0000FF")  // 8 位含 alpha，hexString 只输出 RGB
    }

    func testInvalidHexStringFallsBackToBlack() {
        XCTAssertEqual(Color(hexString: "不是颜色").hexString, "#000000")
        XCTAssertEqual(Color(hexString: "GGGGGG").hexString, "#000000")   // 长度对但非十六进制
        XCTAssertEqual(Color(hexString: "#F00").hexString, "#000000")     // 3 位不支持
    }

    func testRandomAndPlatformColorsSmoke() {
        _ = Color.random()
        _ = Color.systemBackground
        _ = Color.cardBackground
    }

    // MARK: - 复合组件冒烟（只实例化，不渲染，验证构造器与中文别名可解析）

    func testLoadingButtonConstructs() {
        let button = LoadingButton("提交", isLoading: true) {}
        _ = button
        // 中文 init 首参带「标题:」标签——与英文无标签首参区分，避免重载歧义
        let chinese = 加载按钮(标题: "提交", 加载中: true) {}
        _ = chinese
    }

    func testRatingViewConstructs() {
        _ = RatingView(rating: 4.5)
        _ = RatingView(rating: .constant(3.0))
        _ = RatingView(rating: 2.0) { _ in }
        _ = 评分视图(评分: 4.5)
        _ = 评分视图(评分: .constant(3.5))
    }

    func testCollapsibleViewConstructs() {
        _ = CollapsibleView("更多设置", isExpanded: .constant(false)) {
            Text("折叠内容")
        }
        // 中文 init 首参带「标题:」标签——与英文无标签首参区分，避免重载歧义
        _ = 可折叠面板(标题: "更多设置", 展开: .constant(false)) {
            Text("折叠内容")
        }
    }

    func testCarouselViewConstructs() {
        _ = CarouselView(systemImages: ["photo", "camera", "star"])
        _ = CarouselView(views: [Text("第一页"), Text("第二页")])
        _ = 轮播图(系统图标: ["star"])
        _ = 轮播图(视图: [Text("第一页")])
    }

    func testCountdownViewConstructs() {
        _ = CountdownView(seconds: 60)
        _ = CountdownView(seconds: 10, paused: .constant(false)) { }
        _ = 倒计时视图(秒数: 60)
    }

    func testOnboardingViewConstructs() {
        let pages = [
            OnboardingPage(icon: "sparkles", title: "欢迎", message: "第一页"),
            OnboardingPage(icon: "star", title: "强大", message: "第二页"),
        ]
        _ = OnboardingView(pages: pages)
        _ = OnboardingView(pages: pages, onFinish: { })
        _ = 引导页(页面: pages, 完成: { })
        _ = 引导页内容(图标: "star", 标题: "标题", 描述: "描述")
    }

    // MARK: - 二维码生成（@MainActor：qrCode 依赖 CoreImage 且标注主线程）

    @MainActor
    func testQRCodeGeneration() {
        XCTAssertNotNil(Image.qrCode("https://example.com"))
        XCTAssertNotNil(Image.qrCode("hello", scale: 12, correctionLevel: .h))
        XCTAssertNil(Image.qrCode(""), "空文本不应生成二维码")
        XCTAssertNotNil(Image.二维码("hello"))
    }

    // MARK: - 环形进度 / 滚动数字 / 渐变描边 / 水印

    func testRingProgressClampsValue() {
        XCTAssertEqual(RingProgress(value: 0.5).normalizedValue, 0.5, accuracy: 1e-9)
        XCTAssertEqual(RingProgress(value: -1).normalizedValue, 0, accuracy: 1e-9)
        XCTAssertEqual(RingProgress(value: 2).normalizedValue, 1, accuracy: 1e-9)
        _ = 环形进度(进度: 0.3)
    }

    func testAnimatedNumberConstructs() {
        _ = AnimatedNumber(value: 1280)
        _ = AnimatedNumber(value: 3.14, decimals: 2, prefix: "¥", suffix: " 元")
        _ = 滚动数字(数值: 42, 后缀: " 分")
    }

    func testGradientBorderAndWatermarkModifiers() {
        // View 扩展仅验证可参与类型检查（不渲染）
        _ = Text("卡片").gradientBorder([.purple, .blue], lineWidth: 2, cornerRadius: 12)
        _ = Text("卡片").gradientDashedBorder([.gray, .blue], cornerRadius: 12)
        _ = Text("卡片").渐变描边([.red, .orange])
        _ = Text("内容").watermark("内部资料")
        _ = Text("内容").水印("机密")
    }

    /// `pullToRefresh` / `下拉刷新` 的参数据 `refreshable(action:)` 契约要求为 `@Sendable`，
    /// 此处用不带捕获的闭包锁住签名，避免退回非 Sendable 版本时又冒编译告警。
    func testPullToRefreshAcceptsSendableAction() {
        _ = List { Text("项") }.pullToRefresh { await Task.yield() }
        _ = List { Text("项") }.下拉刷新 { await Task.yield() }
    }

    // MARK: - 远程图片 / 验证码输入框 / 跑马灯 / 步骤条

    func testRemoteImageConstructs() {
        let url = URL(string: "https://example.com/a.png")
        _ = RemoteImage(url: url, cornerRadius: 8, size: CGSize(width: 64, height: 64))
        _ = RemoteImage(url: nil)
        _ = RemoteImage(url: url) {
            ProgressView()
        } failure: {
            Text("加载失败")
        }
        _ = 远程图片(网址: url, 圆角: 8, 尺寸: CGSize(width: 64, height: 64))
        _ = 远程图片(网址: url) {
            Text("加载中")
        } 失败: {
            Text("失败")
        }
    }

    func testOTPFieldConstructs() {
        _ = OTPField(code: .constant("123456"), length: 6)
        _ = OTPField(code: .constant(""), length: 4, boxSize: 40, spacing: 8, cornerRadius: 6) { _ in }
        _ = 验证码输入框(验证码: .constant("1234"), 位数: 4, 格子尺寸: 40)
        _ = 验证码输入框(验证码: .constant(""), 位数: 6, 输满回调: { _ in })
    }

    func testMarqueeTextConstructs() {
        _ = MarqueeText("一条很长的公告文字")
        _ = MarqueeText("反向滚动", font: .headline, tint: .red, speed: 60, gap: 24,
                        direction: .leftToRight, isActive: false)
        // 中文 init 首参带「文字:」标签——与英文无标签首参区分，避免重载歧义
        _ = 跑马灯(文字: "中文别名")
        _ = 跑马灯(文字: "中文别名", 速度: 50, 方向: .leftToRight)
    }

    func testStepsViewConstructs() {
        let steps = ["填信息", "选套餐", "付定金", "完成"]
        _ = StepsView(steps: steps, current: 1)
        _ = StepsView(steps: steps, current: 2, direction: .vertical, showsIndex: false)
        _ = 步骤条(步骤: steps, 当前: 1)
        _ = 步骤条(步骤: steps, 当前: 3, 方向: .vertical, 圆点尺寸: 24)
    }

    // MARK: - 头像 / 时间轴 / 迷你图表 / 搜索栏

    func testAvatarInitials() {
        // 中文取前两字
        XCTAssertEqual(Avatar.initials(from: "张三"), "张三")
        XCTAssertEqual(Avatar.initials(from: "李四光"), "李四")
        // 英文按单词：单个词取首字母大写，多个词取前两个词首字母
        XCTAssertEqual(Avatar.initials(from: "Alice"), "A")
        XCTAssertEqual(Avatar.initials(from: "alice"), "A")
        XCTAssertEqual(Avatar.initials(from: "Alice Wang"), "AW")
        // 空白 / 空串兜底
        XCTAssertEqual(Avatar.initials(from: ""), "?")
        XCTAssertEqual(Avatar.initials(from: "   "), "?")
    }

    func testAvatarAndGroupConstruct() {
        _ = Avatar("张三")
        _ = Avatar("Alice", size: 56, tint: .blue, showsBorder: true, status: .online)
        _ = Avatar(image: Image(systemName: "person.crop.circle"))
        _ = Avatar(url: URL(string: "https://example.com/a.png"), status: .away)
        _ = 头像(姓名: "张三", 尺寸: 56, 状态: .busy)
        _ = 头像(图片: Image(systemName: "person"))
        _ = 头像(网址: nil)

        let avatars = [Avatar("张三", size: 32), Avatar("李四", size: 32)]
        _ = AvatarGroup(avatars: avatars, size: 32, maxVisible: 1)
        _ = 头像组(头像列表: avatars, 尺寸: 32, 重叠: 8, 最多显示: 1)
    }

    func testTimelineConstructs() {
        let items = [
            TimelineItem(title: "已下单", detail: "09:12", icon: "cart.fill", isDone: true),
            TimelineItem(title: "运输中"),
        ]
        _ = Timeline(items: items)
        _ = Timeline(items: items, tint: .orange, showsIcons: false, spacing: 12)
        _ = 时间轴条目(标题: "已签收", 详情: "昨天", 图标: "checkmark", 已完成: true)
        _ = 时间轴(节点: items, 颜色: .green, 未完成颜色: .gray, 间距: 12)
    }

    func testSparklineNormalization() {
        // 空数组不画线
        XCTAssertEqual(Sparkline.normalizedRatios([]), [])
        // 单值 / 全相等 → 一律中线，且不除零
        XCTAssertEqual(Sparkline.normalizedRatios([5]), [0.5])
        XCTAssertEqual(Sparkline.normalizedRatios([2, 2, 2]), [0.5, 0.5, 0.5])
        // 常规归一化：最小 0、最大 1
        let ratios = Sparkline.normalizedRatios([0, 5, 10])
        XCTAssertEqual(ratios.count, 3)
        XCTAssertEqual(ratios[0], 0, accuracy: 1e-9)
        XCTAssertEqual(ratios[1], 0.5, accuracy: 1e-9)
        XCTAssertEqual(ratios[2], 1, accuracy: 1e-9)
    }

    func testMiniChartConstructs() {
        _ = Sparkline(values: [3, 7, 4, 9])
        _ = Sparkline(values: [1, 2], tint: .green, lineWidth: 3, height: 32,
                      showsArea: false, showsDots: true)
        _ = 迷你折线图(数值: [1, 2, 3], 颜色: .blue, 高度: 28, 显示面积: false)

        _ = MiniBarChart(values: [3, 7, 4, 9])
        _ = MiniBarChart(values: [1], height: 48, spacing: 4, cornerRadius: 2, highlightsMax: false)
        _ = 迷你柱状图(数值: [1, 2, 3], 颜色: .orange, 高度: 48, 高亮最大值: false)
    }

    func testMiniBarRatios() {
        XCTAssertEqual(MiniBarChart.barRatios([]), [])
        // 最大值非正 → 全 0（由视图层兜底最小柱高）
        XCTAssertEqual(MiniBarChart.barRatios([0, 0]), [0, 0])
        XCTAssertEqual(MiniBarChart.barRatios([-1, -2]), [0, 0])
        // 负数按 0 处理，不让柱子反向
        let ratios = MiniBarChart.barRatios([-3, 4, 8])
        XCTAssertEqual(ratios.count, 3)
        XCTAssertEqual(ratios[0], 0, accuracy: 1e-9)
        XCTAssertEqual(ratios[1], 0.5, accuracy: 1e-9)
        XCTAssertEqual(ratios[2], 1, accuracy: 1e-9)
    }

    func testSearchBarConstructs() {
        _ = SearchBar(text: .constant(""))
        _ = SearchBar(text: .constant("键盘"),
                      placeholder: "搜索商品",
                      showsCancel: false,
                      cancelTitle: "关闭",
                      debounceInterval: 0,
                      tint: .blue) {
            // 提交回调
        } onDebounce: { _ in
            // 防抖回调
        }
        _ = 搜索栏(文本: .constant(""))
        _ = 搜索栏(文本: .constant("手机"), 占位: "搜商品", 防抖间隔: 0.5, 防抖回调: { _ in })
    }

    @available(iOS 16.0, macOS 13.0, *)
    func testFlowLayoutInitSignatures() {
        // 签名锁定：零参 FlowLayout() 必须能编译（只匹配英文 init，不与中文 init 歧义）
        let 默认 = FlowLayout()
        XCTAssertEqual(默认.spacing, 8)
        XCTAssertEqual(默认.lineSpacing, 8)

        // 英文具名
        let 英文 = FlowLayout(spacing: 4, lineSpacing: 12)
        XCTAssertEqual(英文.spacing, 4)
        XCTAssertEqual(英文.lineSpacing, 12)

        // 中文构造器首参「间距」必填、行间距可省
        let 中文 = 流式布局(间距: 4)
        XCTAssertEqual(中文.spacing, 4)
        XCTAssertEqual(中文.lineSpacing, 8)
        XCTAssertEqual(流式布局(间距: 6, 行间距: 16).lineSpacing, 16)
    }

    // MARK: - 展开文本 / 关键词高亮 / 打字机 / 热力图（第九轮）

    func testExpandableTextConstructs() {
        _ = ExpandableText("一段较长的商品简介")
        _ = ExpandableText("长文", lineLimit: 2, font: .headline, tint: .secondary,
                           lineSpacing: 4, expandTitle: "查看全部", collapseTitle: "收起内容",
                           buttonTint: .blue, showsIcon: false)
        // 中文 init 首参带「文字:」标签——与英文无标签首参区分，避免重载歧义
        _ = 展开文本(文字: "长文", 行数: 2, 展开文字: "查看全部", 收起文字: "收起内容")
    }

    func testHighlightedTextRanges() {
        let text = "SwiftUI 的中文封装库"
        // 单关键词：命中一次
        XCTAssertEqual(HighlightedText.ranges(of: ["封装"], in: text).count, 1)
        // 多关键词：各自命中，结果按起点排序
        let multi = HighlightedText.ranges(of: ["中文", "SwiftUI"], in: text)
        XCTAssertEqual(multi.count, 2)
        XCTAssertEqual(String(text[multi[0]]), "SwiftUI")
        XCTAssertEqual(String(text[multi[1]]), "中文")
        // 同一关键词出现多次：全部命中
        XCTAssertEqual(HighlightedText.ranges(of: ["中"], in: "中中中").count, 3)
        // 空关键词 / 空文本直接跳过
        XCTAssertTrue(HighlightedText.ranges(of: [""], in: text).isEmpty)
        XCTAssertTrue(HighlightedText.ranges(of: ["封装"], in: "").isEmpty)
        // 未命中返回空
        XCTAssertTrue(HighlightedText.ranges(of: ["不存在的词"], in: text).isEmpty)
    }

    func testHighlightedTextCaseSensitivity() {
        let text = "Hello World"
        // 默认不区分大小写
        XCTAssertEqual(HighlightedText.ranges(of: ["hello"], in: text).count, 1)
        XCTAssertEqual(HighlightedText.ranges(of: ["world"], in: text).count, 1)
        // 区分大小写时大小写不匹配则不命中
        XCTAssertTrue(HighlightedText.ranges(of: ["hello"], in: text, caseSensitive: true).isEmpty)
        XCTAssertEqual(HighlightedText.ranges(of: ["Hello"], in: text, caseSensitive: true).count, 1)
        // 中文别名等价转发
        XCTAssertEqual(高亮文本.命中区间(关键词: ["Hello"], 文字: text, 区分大小写: true).count, 1)
    }

    func testHighlightedTextConstructs() {
        _ = HighlightedText("SwiftUI 的中文封装库", highlights: ["封装", "中文"])
        _ = HighlightedText("命中标黄", highlights: ["标黄"], highlightColor: .orange,
                            highlightBackground: .yellow.opacity(0.3), isBold: false,
                            font: .footnote, tint: .secondary, caseSensitive: true)
        _ = 高亮文本(文字: "中文别名", 关键词: ["中文"], 高亮底色: .yellow.opacity(0.3))
    }

    func testTypingTextConstructs() {
        _ = TypingText("正在为你生成回答……")
        _ = TypingText("欢迎回来", speed: 0.08, font: .title, tint: .blue,
                       cursorColor: .orange, showsCursor: false, loops: true,
                       loopDelay: 0.5, cursorBlinkInterval: 0.4) { }
        // 中文 init 首参带「文字:」标签——与英文无标签首参区分，避免重载歧义
        _ = 打字机文本(文字: "加载中", 速度: 0.1, 循环: true, 结束: { })
    }

    private func fixedCalendar() -> Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }

    func testHeatmapCalendarLevels() {
        let calendar = fixedCalendar()
        let base = calendar.date(from: DateComponents(year: 2026, month: 1, day: 5))!
        func day(_ offset: Int) -> Date { calendar.date(byAdding: .day, value: offset, to: base)! }

        // 空输入 / 全零 → 空（没有正数就没有色阶基准）
        XCTAssertTrue(HeatmapCalendar.levels(values: [:]).isEmpty)
        XCTAssertTrue(HeatmapCalendar.levels(values: [day(0): 0, day(1): -3]).isEmpty)
        XCTAssertTrue(HeatmapCalendar.levels(values: [day(0): 5], levelCount: 0).isEmpty)

        // 最大值 8，四档：1/8→1、2/8→1、4/8→2、8/8→4（ceil 收敛）
        let levels = HeatmapCalendar.levels(values: [day(0): 1, day(1): 2, day(2): 4, day(3): 8],
                                            levelCount: 4, calendar: calendar)
        XCTAssertEqual(levels[calendar.startOfDay(for: day(0))], 1)
        XCTAssertEqual(levels[calendar.startOfDay(for: day(1))], 1)
        XCTAssertEqual(levels[calendar.startOfDay(for: day(2))], 2)
        XCTAssertEqual(levels[calendar.startOfDay(for: day(3))], 4)
        // 零值 / 负值不进结果
        XCTAssertEqual(levels.count, 4)
    }

    func testHeatmapCalendarWeekColumns() {
        let calendar = fixedCalendar()
        // 2026-01-05 是周一，2026-01-11 是周日
        let start = calendar.date(from: DateComponents(year: 2026, month: 1, day: 5))!
        let end = calendar.date(from: DateComponents(year: 2026, month: 1, day: 11))!
        let columns = HeatmapCalendar.weekColumns(from: start, to: end, calendar: calendar)

        XCTAssertFalse(columns.isEmpty)
        // 每列恰好 7 格（补齐空格）
        XCTAssertTrue(columns.allSatisfy { $0.count == 7 })
        // 有值的格子数等于跨度天数
        let days = columns.flatMap { $0 }.compactMap { $0 }
        XCTAssertEqual(days.count, 7)
        XCTAssertEqual(calendar.startOfDay(for: days.first!), calendar.startOfDay(for: start))
        XCTAssertEqual(calendar.startOfDay(for: days.last!), calendar.startOfDay(for: end))

        // 起止同一天 → 只有一天，仍补齐成整周
        let single = HeatmapCalendar.weekColumns(from: start, to: start, calendar: calendar)
        XCTAssertEqual(single.flatMap { $0 }.compactMap { $0 }.count, 1)
        XCTAssertTrue(single.allSatisfy { $0.count == 7 })
    }

    func testHeatmapCalendarConstructs() {
        _ = HeatmapCalendar(values: [:])
        _ = HeatmapCalendar(values: [:], cellSize: 14, spacing: 4, cornerRadius: 3,
                            colors: [.gray, .green, .blue], emptyColor: .gray.opacity(0.2),
                            showsMonthLabels: false) { _ in }
        // 中文 init 首参带「数值:」标签——与英文无标签首参区分，避免重载歧义
        _ = 热力图日历(数值: [:], 方格尺寸: 12, 显示月份: false)
        _ = 热力图日历.级别(数值: [:], 级别数: 4)
        _ = 热力图日历.周列(起始: Date(), 结束: Date())
    }
}
