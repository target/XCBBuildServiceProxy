import Foundation
import XCTest

@testable import MessagePack

class FloatTests: XCTestCase {
    let packed = Data([0xca, 0x40, 0x48, 0xf5, 0xc3])

    func testPack() {
        XCTAssertEqual(MessagePackValue.pack(.float(3.14)), packed)
    }

    func testUnpack() throws {
        let unpacked = try MessagePackValue.unpack(packed)
        XCTAssertEqual(unpacked.value, .float(3.14))
        XCTAssertEqual(unpacked.remainder.count, 0)
    }
}
