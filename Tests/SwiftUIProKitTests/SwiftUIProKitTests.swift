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
}
