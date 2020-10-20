import Foundation
import XCTest

@testable import MessagePack

class ExampleTests: XCTestCase {
    let example: MessagePackValue = ["compact": true, "schema": .uint8(0)]

    // Two possible "correct" values because dictionaries are unordered
    let correctA = Data([0x82, 0xa7, 0x63, 0x6f, 0x6d, 0x70, 0x61, 0x63, 0x74, 0xc3, 0xa6, 0x73, 0x63, 0x68, 0x65, 0x6d, 0x61, 0x00])
    let correctB = Data([0x82, 0xa6, 0x73, 0x63, 0x68, 0x65, 0x6d, 0x61, 0x00, 0xa7, 0x63, 0x6f, 0x6d, 0x70, 0x61, 0x63, 0x74, 0xc3])

    func testPack() {
        let packed = MessagePackValue.pack(example)
        XCTAssertTrue(packed == correctA || packed == correctB)
    }

    func testUnpack() throws {
        let unpacked1 = try MessagePackValue.unpack(correctA)
        XCTAssertEqual(unpacked1.value, example)
        XCTAssertEqual(unpacked1.remainder.count, 0)

        let unpacked2 = try MessagePackValue.unpack(correctB)
        XCTAssertEqual(unpacked2.value, example)
        XCTAssertEqual(unpacked2.remainder.count, 0)
    }

    func testUnpackInvalidData() {
        do {
            _ = try MessagePackValue.unpack(Data([0xc1]))
            XCTFail("Expected unpack to throw")
        } catch {
            XCTAssertEqual(error as? MessagePackUnpackError, .invalidData)
        }
    }

    func testUnpackInsufficientData() {
        do {
            var data = correctA
            data.removeLast()
            _ = try MessagePackValue.unpack(data)
            XCTFail("Expected unpack to throw")
        } catch {
            XCTAssertEqual(error as? MessagePackUnpackError, .insufficientData)
        }
    }
}
