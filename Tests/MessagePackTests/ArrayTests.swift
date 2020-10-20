import Foundation
import XCTest

@testable import MessagePack

class ArrayTests: XCTestCase {
    func testLiteralConversion() {
        let implicitValue: MessagePackValue = ["a", "b", "c"]
        XCTAssertEqual(implicitValue, .array([.string("a"), .string("b"), .string("c")]))
    }

    func testPackFixarray() {
        let value: [MessagePackValue] = [.uint8(0), .uint8(1), .uint8(2), .uint8(3), .uint8(4)]
        let packed = Data([0x95, 0x00, 0x01, 0x02, 0x03, 0x04])
        XCTAssertEqual(MessagePackValue.pack(.array(value)), packed)
    }

    func testUnpackFixarray() {
        let packed = Data([0x95, 0x00, 0x01, 0x02, 0x03, 0x04])
        let value: [MessagePackValue] = [.uint8(0), .uint8(1), .uint8(2), .uint8(3), .uint8(4)]

        let unpacked = try? MessagePackValue.unpack(packed)
        XCTAssertEqual(unpacked?.value, .array(value))
        XCTAssertEqual(unpacked?.remainder.count, 0)
    }

    func testPackArray16() {
        let value = [MessagePackValue](repeating: nil, count: 16)
        let packed = Data([0xdc, 0x00, 0x10] + [UInt8](repeating: 0xc0, count: 16))
        XCTAssertEqual(MessagePackValue.pack(.array(value)), packed)
    }

    func testUnpackArray16() {
        let packed = Data([0xdc, 0x00, 0x10] + [UInt8](repeating: 0xc0, count: 16))
        let value = [MessagePackValue](repeating: nil, count: 16)

        let unpacked = try? MessagePackValue.unpack(packed)
        XCTAssertEqual(unpacked?.value, .array(value))
        XCTAssertEqual(unpacked?.remainder.count, 0)
    }
}
