import SwiftUI
import SwiftUIProKit

/// SwiftUIProKit 组件分区：轮播图 / 倒计时 / 引导页 / 文本增强 / 热力图 / 瀑布流 / 日历 / 标签 / 饼图
struct SwiftUIProKitPanel: View {

    @State private var countdownPaused = false
    @State private var countdownID = 0
    @State private var showOnboarding = false
    @State private var selectedDate = Date()
    @State private var selectedRange: ClosedRange<Date>?
    @State private var tags: [String] = ["SwiftUI", "中文"]

    var body: some View {
        VStack(spacing: 20) {
            Card("轮播图 CarouselView（SF Symbol 图标 · 自动轮播 · 分页圆点）") {
                CarouselView(
                    systemImages: ["sparkles", "photo", "camera", "star", "heart", "bolt"],
                    interval: 2.5,
                    height: 120
                )
            }

            Card("轮播图 · 自定义视图（任意视图 · AnyView 类型擦除）") {
                CarouselView(
                    views: [
                        AnyView(banner("1", "第一页", .blue)),
                        AnyView(banner("2", "第二页", .purple)),
                        AnyView(banner("3", "第三页", .orange)),
                    ],
                    interval: 3,
                    height: 90
                )
            }

            Card("倒计时 CountdownView（圆环进度 · 可暂停 / 重置 · 归零回调）") {
                VStack(spacing: 12) {
                    CountdownView(
                        seconds: 30,
                        paused: $countdownPaused,
                        onFinish: { print("倒计时结束") }
                    )
                    .id(countdownID)

                    HStack {
                        Button(countdownPaused ? "继续" : "暂停") {
                            countdownPaused.toggle()
                        }
                        Button("重置") {
                            countdownID += 1
                            countdownPaused = false
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }

            Card("引导页 OnboardingView（跳过 / 下一步 / 开始使用）") {
                Button("打开引导页") {
                    showOnboarding = true
                }
                .buttonStyle(.borderedProminent)
            }

            Card("展开收起文本 ExpandableText（按实测高度决定是否显示按钮，拖动窗口看显隐）") {
                ExpandableText(
                    "这是一段较长的演示文本，用来展示「展开 / 收起」的交互。只有当文本实际超过设定的行数时，"
                    + "下方才会出现展开按钮；如果窗口够宽、文字没被截断，按钮不会出现。试着左右拖动窗口宽度，"
                    + "观察按钮的显隐——判断依据是并排藏起来的两段测量文本的高度差，而不是预估字数。",
                    lineLimit: 2,
                    expandTitle: "展开全文",
                    collapseTitle: "收起"
                )
            }

            Card("关键词高亮 HighlightedText（命中词着色 / 加粗 / 底色）") {
                VStack(alignment: .leading, spacing: 8) {
                    HighlightedText(
                        "SwiftUI 的中文封装库，让常用控件与属性见名知意。",
                        highlights: ["SwiftUI", "中文", "控件"],
                        highlightColor: .orange,
                        highlightBackground: .yellow.opacity(0.3)
                    )
                    HighlightedText(
                        "默认不区分大小写：搜索 kit 也能命中 KIT。",
                        highlights: ["kit"],
                        highlightColor: .blue
                    )
                }
            }

            Card("打字机文本 TypingText（逐字显现 · 闪烁光标 · 可选循环）") {
                TypingText("正在为你生成回答……", speed: 0.06, showsCursor: true)
            }

            Card("热力图日历 HeatmapCalendar（GitHub 贡献图样式 · 近 120 天）") {
                HeatmapCalendar(
                    values: Self.sampleHeatmap,
                    startDate: Self.sampleHeatmapStart,
                    endDate: Date()
                ) { day in
                    print("点击了 \(day)")
                }
            }

            if #available(macOS 13, *) {
                Card("瀑布流 MasonryGrid（不等高多列 · Layout 协议 · iOS 16 / macOS 13+）") {
                    MasonryGrid(columns: 3, spacing: 8) {
                        ForEach(0..<9, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color.blue.opacity(0.15 + Double(index % 5) * 0.15))
                                .frame(height: 40 + CGFloat(index % 4) * 26)
                                .overlay(Text("\(index + 1)").foregroundStyle(.secondary))
                        }
                    }
                }
            }

            Card("日历选择器 CalendarPicker（左：单选 · 右：选区段）") {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .top, spacing: 20) {
                        CalendarPicker(selection: $selectedDate)
                        CalendarPicker(range: $selectedRange)
                    }
                    Text("单选：\(selectedDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    Text("区间：\(rangeDescription)")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
            }

            if #available(macOS 13, *) {
                Card("标签输入 TagInput（回车 / 逗号 / 顿号成标签 · FlowLayout 自动换行）") {
                    VStack(alignment: .leading, spacing: 10) {
                        TagInput(tags: $tags,
                                 placeholder: "输入后回车，或用逗号 / 顿号分隔",
                                 maxTags: 6,
                                 onReject: { print("被拒绝的标签：\($0)") })
                        Text("当前 \(tags.count) 个标签：\(tags.joined(separator: "、"))")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Card("饼图 / 环形占比图 PieChart（左：环形 + 中心文字 · 右：饼图）") {
                HStack(alignment: .top, spacing: 24) {
                    PieChart(values: [40, 35, 25],
                             labels: ["iOS", "Android", "其他"],
                             isDonut: true,
                             centerText: "占比")
                    PieChart(slices: [
                        .init(label: "已完成", value: 12, color: .green),
                        .init(label: "进行中", value: 5, color: .orange),
                        .init(label: "未开始", value: 3, color: .gray),
                    ], size: 140)
                }
            }
        }
        .sheet(isPresented: $showOnboarding) {
            OnboardingView(
                pages: [
                    OnboardingPage(icon: "sparkles", title: "欢迎", message: "这是第一页，向你介绍功能。"),
                    OnboardingPage(icon: "star", title: "强大", message: "这是第二页，展示核心能力。"),
                    OnboardingPage(icon: "heart", title: "开始", message: "这是最后一页，点击「开始使用」。"),
                ],
                onSkip: { showOnboarding = false },
                onFinish: { showOnboarding = false }
            )
            .frame(width: 420, height: 420)
        }
    }

    /// 已选区间的可读描述
    private var rangeDescription: String {
        guard let range = selectedRange else { return "未选完（先点起点，再点终点）" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "\(formatter.string(from: range.lowerBound)) ~ \(formatter.string(from: range.upperBound))"
    }

    /// 自定义轮播页内容
    private func banner(_ number: String, _ text: String, _ color: Color) -> some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .fill(LinearGradient(
                colors: [color, color.opacity(0.6)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            ))
            .overlay(
                VStack(spacing: 4) {
                    Text(number).font(.title.bold())
                    Text(text).font(.caption)
                }
                .foregroundStyle(.white)
            )
    }

    /// 热力图演示数据的起始日（今天往前第 119 天）
    private static var sampleHeatmapStart: Date {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return calendar.date(byAdding: .day, value: -119, to: today) ?? today
    }

    /// 造一份近 120 天的演示数据：约三成日子「没有活动」，其余按日期做确定性伪随机取值，
    /// 保证每次渲染颜色一致（不用 `hashValue`，它是按进程加盐的、每次启动都会变）。
    private static var sampleHeatmap: [Date: Double] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var result: [Date: Double] = [:]
        for offset in 0..<120 {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            let seed = Int(day.timeIntervalSince1970 / 86_400) % 10
            guard seed > 2 else { continue }   // 约 30% 的日子留空
            result[day] = Double(seed * seed)
        }
        return result
    }
}
