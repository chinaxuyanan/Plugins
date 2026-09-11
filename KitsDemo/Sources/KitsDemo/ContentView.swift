import SwiftUI

/// KitsDemo 主界面：顶部标题 + 分段选择器切换三个功能分区
///
/// - SwiftUIProKit 组件：轮播图 / 倒计时 / 引导页 / 展开文本 / 关键词高亮 / 打字机 / 热力图
/// - LogKit 日志：采样 / 导出 / 崩溃兜底 / 反解析 / JSON·摘要导出 / 按小时轮转
/// - SystemInfoKit 系统：网络流量 / 磁盘读写 / 电池状态 / 进程排行 / 网卡 MAC
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
            Text("复合组件 / 文本增强 / 热力图 · 日志反解析与导出 · 电池状态 / 进程排行 / 网卡 MAC")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 22)
        .padding(.bottom, 12)
    }
}
