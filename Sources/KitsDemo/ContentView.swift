import SwiftUI

/// KitsDemo 主界面：顶部标题 + 分段选择器切换三个功能分区
///
/// - SwiftUIProKit 组件：轮播图 / 倒计时 / 引导页
/// - LogKit 日志：采样 / 导出 / 崩溃兜底
/// - SystemInfoKit 系统：网络流量 / 磁盘读写
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
            Text("KitsDemo · 第四轮功能演示")
                .font(.largeTitle.bold())
            Text("轮播图 / 倒计时 / 引导页 · 日志采样 / 导出 / 崩溃兜底 · 网络流量 / 磁盘读写")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 22)
        .padding(.bottom, 12)
    }
}
