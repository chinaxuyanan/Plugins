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
        let chinese = 加载按钮("提交", 加载中: true) {}
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
        _ = 可折叠面板("更多设置", 展开: .constant(false)) {
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
}
