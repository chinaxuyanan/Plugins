import SwiftUI
import SwiftUIProKit

/// SwiftUIProKit 组件分区：轮播图 / 倒计时 / 引导页
struct SwiftUIProKitPanel: View {

    @State private var countdownPaused = false
    @State private var countdownID = 0
    @State private var showOnboarding = false

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
}
