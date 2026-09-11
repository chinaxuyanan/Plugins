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
        // 起止日期没有默认值，必须显式给
        let start = Date(timeIntervalSince1970: 1_767_225_600)   // 2026-01-01（UTC）
        let end = start.addingTimeInterval(86_400 * 6)
        _ = HeatmapCalendar(values: [:], startDate: start, endDate: end)
        _ = HeatmapCalendar(values: [:], startDate: start, endDate: end,
                            cellSize: 14, spacing: 4, cornerRadius: 3,
                            colors: [.gray, .green, .blue], emptyColor: .gray.opacity(0.2),
                            showsMonthLabels: false) { _ in }
        // 中文 init 首参带「数值:」标签——与英文无标签首参区分，避免重载歧义
        _ = 热力图日历(数值: [:], 起始: start, 结束: end, 方格尺寸: 12, 显示月份: false)
        _ = 热力图日历.级别(数值: [:], 级别数: 4)
        _ = 热力图日历.周列(起始: Date(), 结束: Date())
    }

    // MARK: - 瀑布流（iOS 16 / macOS 13+，与包最低平台不同，需要可用性标注）

    @available(macOS 13.0, iOS 16.0, *)
    func testMasonryGridShortestColumn() {
        // 空数组兜底
        XCTAssertEqual(MasonryGrid.shortestColumnIndex(in: []), 0)
        // 都为空时取最靠左
        XCTAssertEqual(MasonryGrid.shortestColumnIndex(in: [0, 0, 0]), 0)
        // 取最矮的那一列
        XCTAssertEqual(MasonryGrid.shortestColumnIndex(in: [10, 4, 7]), 1)
        // 并列最矮取最左（保证同样输入总是同样摆法）
        XCTAssertEqual(MasonryGrid.shortestColumnIndex(in: [9, 4, 4]), 1)
    }

    @available(macOS 13.0, iOS 16.0, *)
    func testMasonryGridConstructs() {
        _ = MasonryGrid()
        _ = MasonryGrid(columns: 3, spacing: 10, lineSpacing: 12)
        // 中文 init 首参带「列数:」标签——与英文 init（参数全有默认值）区分，避免歧义
        _ = 瀑布流(列数: 2)
        _ = 瀑布流(列数: 2, 间距: 10, 行间距: 12)
        _ = 瀑布流.最矮列(高度: [1, 2])
    }

    // MARK: - 日历选择器

    func testCalendarPickerMonthGrid() {
        var calendar = fixedCalendar()
        // 2026-01-01 是周四（2026-01-05 是周一）
        let january = calendar.date(from: DateComponents(year: 2026, month: 1, day: 15))!

        calendar.firstWeekday = 1   // 周日开头：前面补 4 个空格
        let sundayFirst = CalendarPicker.monthGrid(for: january, calendar: calendar)
        XCTAssertEqual(sundayFirst.count % 7, 0)
        XCTAssertEqual(sundayFirst.prefix(4).compactMap { $0 }.count, 0)
        XCTAssertEqual(sundayFirst.compactMap { $0 }.count, 31)
        XCTAssertEqual(sundayFirst.compactMap { $0 }.first,
                       calendar.date(from: DateComponents(year: 2026, month: 1, day: 1))!)

        calendar.firstWeekday = 2   // 周一开头：前面补 3 个空格
        let mondayFirst = CalendarPicker.monthGrid(for: january, calendar: calendar)
        XCTAssertEqual(mondayFirst.count % 7, 0)
        XCTAssertEqual(mondayFirst.prefix(3).compactMap { $0 }.count, 0)
        XCTAssertEqual(mondayFirst.compactMap { $0 }.count, 31)
    }

    func testCalendarPickerSymbolsAndSameDay() {
        var calendar = fixedCalendar()
        calendar.firstWeekday = 1
        XCTAssertEqual(CalendarPicker.weekdaySymbols(calendar: calendar),
                       ["日", "一", "二", "三", "四", "五", "六"])
        calendar.firstWeekday = 2
        XCTAssertEqual(CalendarPicker.weekdaySymbols(calendar: calendar),
                       ["一", "二", "三", "四", "五", "六", "日"])

        let morning = calendar.date(from: DateComponents(year: 2026, month: 1, day: 5, hour: 9))!
        let night = calendar.date(from: DateComponents(year: 2026, month: 1, day: 5, hour: 23))!
        let nextDay = calendar.date(from: DateComponents(year: 2026, month: 1, day: 6, hour: 1))!
        XCTAssertTrue(CalendarPicker.isSameDay(morning, night, calendar: calendar))
        XCTAssertFalse(CalendarPicker.isSameDay(morning, nextDay, calendar: calendar))
    }

    func testCalendarPickerMonthShiftAndConstructs() {
        let calendar = fixedCalendar()
        let january = calendar.date(from: DateComponents(year: 2026, month: 1, day: 15))!
        XCTAssertEqual(CalendarPicker.month(byAdding: 1, to: january, calendar: calendar),
                       calendar.date(from: DateComponents(year: 2026, month: 2, day: 1))!)
        XCTAssertEqual(CalendarPicker.month(byAdding: -1, to: january, calendar: calendar),
                       calendar.date(from: DateComponents(year: 2025, month: 12, day: 1))!)

        let february = calendar.date(from: DateComponents(year: 2026, month: 2, day: 10))!
        let range: ClosedRange<Date>? = january...february
        let emptyRange: ClosedRange<Date>? = nil

        _ = CalendarPicker(selection: .constant(january))
        _ = CalendarPicker(selection: .constant(january), calendar: calendar, tint: .red,
                           minimumDate: january, maximumDate: february)
        _ = CalendarPicker(range: .constant(range))
        // 中文 init 首参都带标签，`选择:` 与 `区间:` 凭标签区分，不会歧义
        _ = 日历选择器(选择: .constant(january))
        _ = 日历选择器(区间: .constant(emptyRange))
        _ = 日历选择器.月份矩阵(月份: january, 日历: calendar)
        _ = 日历选择器.同一天(january, february, 日历: calendar)
        _ = 日历选择器.星期表头(日历: calendar)
    }

    // MARK: - 标签输入（iOS 16 / macOS 13+）

    @available(macOS 13.0, iOS 16.0, *)
    func testTagInputParse() {
        XCTAssertEqual(TagInput.parse(""), [])
        XCTAssertEqual(TagInput.parse("   "), [])
        // 半角逗号 / 全角逗号 / 顿号都当分隔符
        XCTAssertEqual(TagInput.parse("a, b，，c、"), ["a", "b", "c"])
        XCTAssertEqual(TagInput.parse("Swift"), ["Swift"])
        XCTAssertEqual(TagInput.parse(" , ， "), [])
    }

    @available(macOS 13.0, iOS 16.0, *)
    func testTagInputApplied() {
        let first = TagInput.applied(["b"], to: ["a"], maxTags: 0, allowsDuplicates: false)
        XCTAssertEqual(first.tags, ["a", "b"])
        XCTAssertEqual(first.added, ["b"])
        XCTAssertTrue(first.rejected.isEmpty)

        // 重复的被拒，其余照常进
        let duplicate = TagInput.applied(["a", "c"], to: ["a"], maxTags: 0, allowsDuplicates: false)
        XCTAssertEqual(duplicate.tags, ["a", "c"])
        XCTAssertEqual(duplicate.added, ["c"])
        XCTAssertEqual(duplicate.rejected, ["a"])

        let allowed = TagInput.applied(["a"], to: ["a"], maxTags: 0, allowsDuplicates: true)
        XCTAssertEqual(allowed.tags, ["a", "a"])

        // 满员后剩下的全拒
        let limited = TagInput.applied(["x", "y", "z"], to: ["a", "b"],
                                       maxTags: 3, allowsDuplicates: false)
        XCTAssertEqual(limited.tags, ["a", "b", "x"])
        XCTAssertEqual(limited.added, ["x"])
        XCTAssertEqual(limited.rejected, ["y", "z"])
    }

    @available(macOS 13.0, iOS 16.0, *)
    func testTagInputConstructs() {
        _ = TagInput(tags: .constant([]))
        _ = TagInput(tags: .constant(["Swift"]), placeholder: "添加", maxTags: 5,
                     allowsDuplicates: true, tagColor: .blue,
                     onAdd: { _ in }, onRemove: { _ in }, onReject: { _ in })
        // 中文 init 首参带「标签:」标签
        _ = 标签输入(标签: .constant([]))
        _ = 标签输入(标签: .constant(["Swift"]), 占位: "添加", 最大数量: 5,
                     允许重复: true, 标签颜色: .blue,
                     添加: { _ in }, 移除: { _ in }, 拒绝: { _ in })
        _ = 标签输入.拆分("a,b")
        _ = 标签输入.合并(["x"], 已有: ["a"], 最大数量: 2)
    }

    // MARK: - 饼图 / 环形占比图

    func testPieChartRatios() {
        XCTAssertEqual(PieChart.ratios([]), [])
        // 总和 0 / 全为负 → 全 0（不画扇形）
        XCTAssertEqual(PieChart.ratios([0, 0]), [0, 0])
        XCTAssertEqual(PieChart.ratios([-1, -2]), [0, 0])
        // 负值按 0，正值照常归一化
        XCTAssertEqual(PieChart.ratios([-1, 1]), [0, 1])
        XCTAssertEqual(PieChart.ratios([1, 3]), [0.25, 0.75])
        XCTAssertEqual(PieChart.ratios([1, 1, 1]).reduce(0, +), 1.0, accuracy: 1e-9)
    }

    func testPieChartAngleRanges() {
        XCTAssertTrue(PieChart.angleRanges([]).isEmpty)

        // 只有一段 → 整圈
        let single = PieChart.angleRanges([5])
        XCTAssertEqual(single.count, 1)
        XCTAssertEqual(single[0].start, 0, accuracy: 1e-9)
        XCTAssertEqual(single[0].end, 360, accuracy: 1e-9)

        // 四等分 → 每段 90°，首尾相接不断档
        let quarters = PieChart.angleRanges([1, 1, 1, 1])
        XCTAssertEqual(quarters.count, 4)
        XCTAssertEqual(quarters[0].start, 0, accuracy: 1e-9)
        XCTAssertEqual(quarters[1].start, 90, accuracy: 1e-9)
        XCTAssertEqual(quarters[2].start, 180, accuracy: 1e-9)
        XCTAssertEqual(quarters[3].end, 360, accuracy: 1e-9)
    }

    func testPieChartConstructs() {
        _ = PieChart(values: [1, 2, 3])
        _ = PieChart(values: [1, 2], labels: ["甲", "乙"], colors: [.red], size: 120,
                     isDonut: true, innerRatio: 0.6, showsLegend: false, centerText: "3")
        _ = PieChart(slices: [PieChart.Slice(label: "甲", value: 1, color: .red)])
        _ = PieChart(slices: [.init(label: "甲", value: 1, color: .red)])
        // 中文 init 首参 「分片:」/「数值:」凭标签区分，不会歧义
        _ = 饼图(分片: [饼图分片(名称: "甲", 数值: 1, 颜色: .red)], 环形: true, 中心文字: "1")
        _ = 饼图(数值: [1, 2], 名称: ["甲", "乙"], 尺寸: 100, 显示图例: false)
        _ = 饼图.占比([1, 3])
        _ = 饼图.角度区间([1, 3])
    }

    // MARK: - 正式图表

    func testChartAxisPaddedRange() {
        // 空 / 全非有限数 → 兜底 0...1
        // 空数组字面量 `[]` 会同时在 `[Double]` 与 `[ChartSeries]` 两个重载之间歧义，必须写清元素类型
        XCTAssertEqual(ChartAxis.paddedRange([Double]()), 0...1)
        XCTAssertEqual(ChartAxis.paddedRange([.nan, .infinity]), 0...1)
        // 上下各留 5% 的跨度
        let range = ChartAxis.paddedRange([1, 2, 3])
        XCTAssertEqual(range.lowerBound, 0.9, accuracy: 1e-9)
        XCTAssertEqual(range.upperBound, 3.1, accuracy: 1e-9)
        // 全部相同 → 围绕该值上下撑开（绝对值也参与，避免全 0 撑不开）
        XCTAssertEqual(ChartAxis.paddedRange([5]), 4.5...5.5)
        XCTAssertEqual(ChartAxis.paddedRange([0, 0]), (-0.5)...0.5)
        // 多条系列摊平后一起算
        let multi = ChartAxis.paddedRange([ChartSeries(label: "甲", values: [0]),
                                           ChartSeries(label: "乙", values: [10])])
        XCTAssertEqual(multi.lowerBound, -0.5, accuracy: 1e-9)
        XCTAssertEqual(multi.upperBound, 10.5, accuracy: 1e-9)
        // 中文别名与英文等价
        XCTAssertEqual(图表坐标轴.paddedRange([1, 2, 3]), range)
    }

    func testChartAxisTicks() {
        XCTAssertEqual(ChartAxis.ticks(in: 0...4, count: 4), [0, 1, 2, 3, 4])
        XCTAssertEqual(ChartAxis.ticks(in: 0...4, count: 0), [0, 4])   // count < 1 按 1 处理
        XCTAssertEqual(ChartAxis.ticks(in: 3...3, count: 4), [3])      // 跨度为 0 只返回一个
        let five = ChartAxis.ticks(in: 0...1, count: 4)
        XCTAssertEqual(five.count, 5)
        XCTAssertEqual(five.first, 0)
        XCTAssertEqual(five.last, 1)
    }

    func testChartAxisRatios() {
        XCTAssertEqual(ChartAxis.ratios([0, 10], in: 0...10), [0, 1])
        // 超出范围会被夹到 0 / 1
        XCTAssertEqual(ChartAxis.ratios([-5, 15], in: 0...10), [0, 1])
        XCTAssertEqual(ChartAxis.ratios([50], in: 0...10), [1])
        // 跨度为 0 → 全落在中线
        XCTAssertEqual(ChartAxis.ratios([1, 2, 3], in: 5...5), [0.5, 0.5, 0.5])
    }

    func testChartAxisLabelIndexes() {
        XCTAssertEqual(ChartAxis.labelIndexes(count: 0, maxLabels: 5), [])
        XCTAssertEqual(ChartAxis.labelIndexes(count: 3, maxLabels: 0), [])
        // 上限不小于个数 → 全显示
        XCTAssertEqual(ChartAxis.labelIndexes(count: 4, maxLabels: 10), [0, 1, 2, 3])
        // 只留一个 → 取第一个
        XCTAssertEqual(ChartAxis.labelIndexes(count: 10, maxLabels: 1), [0])
        // 抽稀带上首尾
        XCTAssertEqual(ChartAxis.labelIndexes(count: 10, maxLabels: 3), [0, 5, 9])
        // 结果严格递增（不会因为四舍五入挤出重复下标）
        let indexes = ChartAxis.labelIndexes(count: 13, maxLabels: 5)
        XCTAssertEqual(indexes, indexes.sorted())
        XCTAssertEqual(Set(indexes).count, indexes.count)
    }

    func testChartAxisLabel() {
        XCTAssertEqual(ChartAxis.label(3), "3")
        XCTAssertEqual(ChartAxis.label(3.5), "3.5")
        XCTAssertEqual(ChartAxis.label(3, suffix: "%"), "3%")
        XCTAssertEqual(ChartAxis.label(-2.5, suffix: "次"), "-2.5次")
        XCTAssertEqual(ChartAxis.label(.nan), "—")
        // 中文别名与英文等价
        XCTAssertEqual(图表坐标轴.留白范围([1, 2, 3]), ChartAxis.paddedRange([1, 2, 3]))
        XCTAssertEqual(图表坐标轴.刻度(in: 0...4, 段数: 4), [0, 1, 2, 3, 4])
        XCTAssertEqual(图表坐标轴.比例([0, 10], 范围: 0...10), [0, 1])
        XCTAssertEqual(图表坐标轴.标签下标(总数: 10, 最多: 3), [0, 5, 9])
        XCTAssertEqual(图表坐标轴.刻度文字(3, 单位: "%"), "3%")
    }

    func testChartConstructs() {
        _ = LineChart(values: [1, 2, 3], labels: ["一", "二", "三"])
        _ = LineChart(series: [.init(label: "甲", values: [1, 2], color: .red)],
                      height: 160, lineWidth: 3, showsArea: false, showsDots: false,
                      showsGrid: false, tickCount: 5, xLabels: ["a", "b"],
                      maxXLabels: 2, showsYLabels: false, showsLegend: false, ySuffix: "次")
        _ = BarChart(values: [1, 2, 3], labels: ["一", "二", "三"])
        _ = BarChart(series: [.init(label: "甲", values: [1, 2])],
                     labels: ["a", "b"], height: 150, spacing: 8, cornerRadius: 4,
                     showsGrid: false, tickCount: 3, maxXLabels: 2,
                     showsYLabels: false, showsLegend: false, highlightsMax: true, ySuffix: "%")
        // 中文 init：`系列:` / `数值:` 凭标签区分，不会歧义
        _ = 折线图(数值: [1, 2], 横轴标签: ["一", "二"], 高度: 120, 纵轴单位: "次")
        _ = 折线图(系列: [图表数据系列(名称: "甲", 数值: [1, 2], 颜色: .blue)], 显示图例: false)
        _ = 柱状图(数值: [1, 2], 高亮最大值: false)
        _ = 柱状图(系列: [图表数据系列(名称: "甲", 数值: [1, 2])], 柱间距: 4)
        XCTAssertEqual(图表数据系列(名称: "甲", 数值: [1, 2]).名称, "甲")
        XCTAssertEqual(图表数据系列(名称: "甲", 数值: [1, 2]).数值, [1, 2])
    }

    func testBarChartBarWidth() {
        // 一组 100 宽、间距 5、2 根柱 → (100 - 3*5) / 2 = 42.5
        XCTAssertEqual(BarChart.barWidth(groupWidth: 100, spacing: 5, barCount: 2), 42.5, accuracy: 1e-9)
        // 宽度不够也至少 1
        XCTAssertEqual(BarChart.barWidth(groupWidth: 4, spacing: 5, barCount: 2), 1)
        // 没有柱子 → 0
        XCTAssertEqual(BarChart.barWidth(groupWidth: 100, spacing: 5, barCount: 0), 0)
        XCTAssertEqual(柱状图.柱宽(组宽: 100, 柱间距: 5, 柱数: 2), 42.5, accuracy: 1e-9)
    }

    // MARK: - 底部抽屉

    func testBottomSheetNormalizedDetents() {
        // 空 / 全非法 → 兜底两档
        XCTAssertEqual(BottomSheet.normalizedDetents([]), [0.4, 0.7])
        XCTAssertEqual(BottomSheet.normalizedDetents([0, -1, 2]), [0.4, 0.7])
        // 升序 + 去重
        XCTAssertEqual(BottomSheet.normalizedDetents([0.7, 0.4, 0.4]), [0.4, 0.7])
        XCTAssertEqual(BottomSheet.normalizedDetents([0.5, 0.5]), [0.5])
        XCTAssertEqual(底部抽屉.归一化档位([0.7, 0.4]), [0.4, 0.7])
    }

    func testBottomSheetHeightAndClamp() {
        XCTAssertEqual(BottomSheet.height(containerHeight: 100, detent: 0.4), 40, accuracy: 1e-9)
        XCTAssertEqual(BottomSheet.height(containerHeight: 100, detent: 1.5), 100, accuracy: 1e-9)
        XCTAssertEqual(BottomSheet.height(containerHeight: 0, detent: 0.4), 0)
        XCTAssertEqual(底部抽屉.面板高度(容器高: 100, 档位: 0.4), 40, accuracy: 1e-9)
        XCTAssertEqual(BottomSheet.clamp(5, count: 3), 2)
        XCTAssertEqual(BottomSheet.clamp(-1, count: 3), 0)
        XCTAssertEqual(BottomSheet.clamp(0, count: 0), 0)
    }

    func testBottomSheetNearestIndex() {
        let detents: [CGFloat] = [0.4, 0.7]
        XCTAssertEqual(BottomSheet.nearestIndex(currentDetent: 0.42, detents: detents), 0)
        XCTAssertEqual(BottomSheet.nearestIndex(currentDetent: 0.65, detents: detents), 1)
        // 向上甩 → 往更大档走；向下甩 → 往更小档走
        XCTAssertEqual(BottomSheet.nearestIndex(currentDetent: 0.42, detents: detents, velocity: -0.5), 1)
        XCTAssertEqual(BottomSheet.nearestIndex(currentDetent: 0.65, detents: detents, velocity: 0.5), 0)
        // 已经在最大档，再向上甩也不会越界
        XCTAssertEqual(BottomSheet.nearestIndex(currentDetent: 0.7, detents: detents, velocity: -0.9), 1)
        // 只有一档 → 恒为 0
        XCTAssertEqual(BottomSheet.nearestIndex(currentDetent: 0.5, detents: [0.5]), 0)
        XCTAssertEqual(底部抽屉.吸附档位(当前档位: 0.65, 档位组: detents), 1)
    }

    // MARK: - 浮动标签输入框

    func testFloatingLabelShouldFloat() {
        XCTAssertFalse(FloatingLabelField.shouldFloat(text: "", isFocused: false))
        XCTAssertTrue(FloatingLabelField.shouldFloat(text: "x", isFocused: false))
        XCTAssertTrue(FloatingLabelField.shouldFloat(text: "", isFocused: true))
        XCTAssertTrue(浮动标签输入框.是否上浮(文本: "", 聚焦中: true))
    }

    func testFloatingLabelConstructs() {
        _ = FloatingLabelField(label: "手机号", text: .constant(""))
        _ = FloatingLabelField(label: "密码", text: .constant(""), isSecure: true,
                               height: 60, cornerRadius: 12, tint: .blue,
                               helperText: "至少 6 位", errorText: "太短了", autoFocus: true)
        // 中文 init 首参「标签:」无默认值
        _ = 浮动标签输入框(标签: "邮箱", 文本: .constant(""))
        _ = 浮动标签输入框(标签: "密码", 文本: .constant(""), 密码输入: true,
                         错误文字: "不能为空", 自动聚焦: true)
    }

    // MARK: - 图片对比滑块

    func testBeforeAfterSliderLogic() {
        XCTAssertEqual(BeforeAfterSlider<Color, Color>.clampRatio(-0.5), 0)
        XCTAssertEqual(BeforeAfterSlider<Color, Color>.clampRatio(1.5), 1)
        XCTAssertEqual(BeforeAfterSlider<Color, Color>.clampRatio(0.3), 0.3, accuracy: 1e-9)
        XCTAssertEqual(BeforeAfterSlider<Color, Color>.ratio(x: 50, width: 100), 0.5, accuracy: 1e-9)
        XCTAssertEqual(BeforeAfterSlider<Color, Color>.ratio(x: 200, width: 100), 1, accuracy: 1e-9)
        // 宽度为 0 → 退回中线
        XCTAssertEqual(BeforeAfterSlider<Color, Color>.ratio(x: 10, width: 0), 0.5, accuracy: 1e-9)
        XCTAssertEqual(图片对比滑块<Color, Color>.限定比例(-1), 0)
        XCTAssertEqual(图片对比滑块<Color, Color>.计算比例(横坐标: 25, 宽度: 100), 0.25, accuracy: 1e-9)
    }

    func testBeforeAfterSliderConstructs() {
        _ = BeforeAfterSlider(before: { Color.red }, after: { Color.blue })
        _ = BeforeAfterSlider(before: { Text("前") }, after: { Text("后") },
                              ratio: .constant(0.3), initialRatio: 0.2, handleSize: 40,
                              cornerRadius: 16, showsLabels: false,
                              beforeLabel: "原图", afterLabel: "修后")
        _ = BeforeAfterSlider(beforeImage: Image(systemName: "photo"),
                              afterImage: Image(systemName: "photo.fill"))
        _ = BeforeAfterSlider(beforeImage: Image(systemName: "photo"),
                              afterImage: Image(systemName: "photo.fill"),
                              initialRatio: 0.3, showsLabels: false)
        // 中文 init：自定义视图与图片各一套
        _ = 图片对比滑块(前: { Color.red }, 后: { Color.blue })
        _ = 图片对比滑块(前图: Image(systemName: "photo"),
                     后图: Image(systemName: "photo.fill"),
                     初始比例: 0.4, 前标签: "原图", 后标签: "修后")
    }
}
