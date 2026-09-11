import SwiftUI

/// KitsDemo 主界面：顶部标题 + 分段选择器切换三个功能分区
///
/// - SwiftUIProKit 组件：轮播图 / 倒计时 / 引导页 / 文本增强 / 热力图 / 瀑布流 / 日历选择器 / 标签输入 / 饼图 / 折线图 / 柱状图 / 底部抽屉 / 浮动标签输入 / 图片对比
/// - LogKit 日志：采样 / 导出 / 崩溃兜底 / 反解析 / 链路聚合 / 合并日志 / 格式模板 / Markdown 报告 / HTML 报告 / 按消息聚合 / 差异导出 / 体积统计
/// - SystemInfoKit 系统：网络流量 / 磁盘读写 / 内存明细 / 每核 CPU / 电池温度与电源 / 已安装应用 / 显卡 / USB / 风扇与温度 / 电池剩余时间
struct ContentView: View {

    enum Tab: String, CaseIterable, Identifiable {
        case swiftUI = "SwiftUIProKit 组件"
        case log = "LogKit 日志"
        case system = "SystemInfoKit 系统"

        var id: String { rawValue }
    }

    @State private var tab: Tab = .swiftUI

    var body: some View {
        VStack(spacing: 0) {
            header

            Picker("功能分区", selection: $tab) {
                ForEach(Tab.allCases) { t in
                    Text(t.rawValue).tag(t)
                }
            }
            .pickerStyle(.segmented)
            .labelsHidden()
            .padding(.horizontal, 20)
            .padding(.bottom, 10)

            ScrollView {
                Group {
                    switch tab {
                    case .swiftUI: SwiftUIProKitPanel()
                    case .log: LogKitPanel()
                    case .system: SystemInfoKitPanel()
                    }
                }
                .padding(20)
            }
        }
    }

    private var header: some View {
        VStack(spacing: 4) {
            Text("KitsDemo · 三库功能演示")
                .font(.largeTitle.bold())
            Text("图表 / 底部抽屉 / 浮动标签 · HTML 报告与按消息聚合 · 显卡 / USB / 风扇温度 / 电池剩余时间")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 22)
        .padding(.bottom, 12)
    }
}
