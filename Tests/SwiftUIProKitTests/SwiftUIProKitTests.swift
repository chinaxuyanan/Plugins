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
}
