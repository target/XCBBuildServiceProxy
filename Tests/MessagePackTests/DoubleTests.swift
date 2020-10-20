import Foundation
import XCTest

@testable import MessagePack

class DoubleTests: XCTestCase {
    let packed = Data([0xcb, 0x40, 0x09, 0x1e, 0xb8, 0x51, 0xeb, 0x85, 0x1f])

    func testPack() {
        XCTAssertEqual(MessagePackValue.pack(.double(3.14)), packed)
    }

    func testUnpack() throws {
        let unpacked = try MessagePackValue.unpack(packed)
        XCTAssertEqual(unpacked.value, .double(3.14))
        XCTAssertEqual(unpacked.remainder.count, 0)
    }
}
