import SwiftUI
import AppKit

/// KitsDemo 应用入口
///
/// 作为 Swift Package 可执行目标运行：`swift run` 或 Xcode 选中 KitsDemo scheme 运行。
/// 启动时把 App 设为常规前台应用并激活，确保窗口弹出后能获得焦点。
@main
struct KitsDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(minWidth: 720, minHeight: 600)
                .onAppear {
                    NSApp.setActivationPolicy(.regular)
                    NSApp.activate(ignoringOtherApps: true)
                }
        }
    }
}
