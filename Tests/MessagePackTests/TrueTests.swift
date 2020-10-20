import Foundation
import XCTest

@testable import MessagePack

class TrueTests: XCTestCase {
    let packed = Data([0xc3])

    func testLiteralConversion() {
        let implicitValue: MessagePackValue = true
        XCTAssertEqual(implicitValue, MessagePackValue.bool(true))
    }

    func testPack() {
        XCTAssertEqual(MessagePackValue.pack(.bool(true)), packed)
    }

    func testUnpack() throws {
        let unpacked = try MessagePackValue.unpack(packed)
        XCTAssertEqual(unpacked.value, MessagePackValue.bool(true))
        XCTAssertEqual(unpacked.remainder.count, 0)
    }
}
