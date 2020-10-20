import Foundation
import XCTest

@testable import MessagePack

class NilTests: XCTestCase {
    let packed = Data([0xc0])

    func testLiteralConversion() {
        let implicitValue: MessagePackValue = nil
        XCTAssertEqual(implicitValue, MessagePackValue.nil)
    }

    func testPack() {
        XCTAssertEqual(MessagePackValue.pack(.nil), packed)
    }

    func testUnpack() throws {
        let unpacked = try MessagePackValue.unpack(packed)
        XCTAssertEqual(unpacked.value, MessagePackValue.nil)
        XCTAssertEqual(unpacked.remainder.count, 0)
    }
}
