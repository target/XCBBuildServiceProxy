import Foundation
import XCTest

@testable import MessagePack

class FalseTests: XCTestCase {
    let packed = Data([0xc2])

    func testLiteralConversion() {
        let implicitValue: MessagePackValue = false
        XCTAssertEqual(implicitValue, MessagePackValue.bool(false))
    }

    func testPack() {
        XCTAssertEqual(MessagePackValue.pack(.bool(false)), packed)
    }

    func testUnpack() throws {
        let unpacked = try MessagePackValue.unpack(packed)
        XCTAssertEqual(unpacked.value, .bool(false))
        XCTAssertEqual(unpacked.remainder.count, 0)
    }
}
