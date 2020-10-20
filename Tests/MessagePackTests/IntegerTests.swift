import Foundation
import XCTest

@testable import MessagePack

class IntegerTests: XCTestCase {
    func testPackNegFixint() {
        XCTAssertEqual(MessagePackValue.pack(.int8(-1)), Data([0xff]))
    }

    func testUnpackNegFixint() throws {
        let unpacked1 = try MessagePackValue.unpack(Data([0xff]))
        XCTAssertEqual(unpacked1.value, .int8(-1))
        XCTAssertEqual(unpacked1.remainder.count, 0)

        let unpacked2 = try MessagePackValue.unpack(Data([0xe0]))
        XCTAssertEqual(unpacked2.value, .int8(-32))
        XCTAssertEqual(unpacked2.remainder.count, 0)
    }

    func testPackPosFixintSigned() {
        XCTAssertEqual(MessagePackValue.pack(.int8(1)), Data([0xd0, 0x01]))
    }

    func testUnpackPosFixintSigned() throws {
        let unpacked = try MessagePackValue.unpack(Data([0x01]))
        XCTAssertEqual(unpacked.value, .uint8(1))
        XCTAssertEqual(unpacked.remainder.count, 0)
    }

    func testPackPosFixintUnsigned() {
        XCTAssertEqual(MessagePackValue.pack(.uint8(42)), Data([0x2a]))
    }

    func testUnpackPosFixintUnsigned() throws {
        let unpacked = try MessagePackValue.unpack(Data([0x2a]))
        XCTAssertEqual(unpacked.value, .uint8(42))
        XCTAssertEqual(unpacked.remainder.count, 0)
    }

    func testPackUInt8() {
        XCTAssertEqual(MessagePackValue.pack(.uint8(0xff)), Data([0xcc, 0xff]))
    }

    func testUnpackUInt8() throws {
        let unpacked = try MessagePackValue.unpack(Data([0xcc, 0xff]))
        XCTAssertEqual(unpacked.value, .uint8(0xff))
        XCTAssertEqual(unpacked.remainder.count, 0)
    }

    func testPackUInt16() {
        XCTAssertEqual(MessagePackValue.pack(.uint16(0xffff)), Data([0xcd, 0xff, 0xff]))
    }

    func testUnpackUInt16() throws {
        let unpacked = try MessagePackValue.unpack(Data([0xcd, 0xff, 0xff]))
        XCTAssertEqual(unpacked.value, .uint16(0xffff))
        XCTAssertEqual(unpacked.remainder.count, 0)
    }

    func testPackUInt32() {
        XCTAssertEqual(MessagePackValue.pack(.uint32(0xffff_ffff)), Data([0xce, 0xff, 0xff, 0xff, 0xff]))
    }

    func testUnpackUInt32() throws {
        let unpacked = try MessagePackValue.unpack(Data([0xce, 0xff, 0xff, 0xff, 0xff]))
        XCTAssertEqual(unpacked.value, .uint32(0xffff_ffff))
        XCTAssertEqual(unpacked.remainder.count, 0)
    }

    func testPackUInt64() {
        XCTAssertEqual(
            MessagePackValue.pack(.uint64(0xffff_ffff_ffff_ffff)),
            Data([0xcf, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff])
        )
    }

    func testUnpackUInt64() throws {
        let unpacked = try MessagePackValue.unpack(Data([0xcf, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff]))
        XCTAssertEqual(unpacked.value, .uint64(0xffff_ffff_ffff_ffff))
        XCTAssertEqual(unpacked.remainder.count, 0)
    }

    func testPackInt8() {
        XCTAssertEqual(MessagePackValue.pack(.int8(-0x7f)), Data([0xd0, 0x81]))
    }

    func testUnpackInt8() throws {
        let unpacked = try MessagePackValue.unpack(Data([0xd0, 0x81]))
        XCTAssertEqual(unpacked.value, .int8(-0x7f))
        XCTAssertEqual(unpacked.remainder.count, 0)
    }

    func testPackInt16() {
        XCTAssertEqual(MessagePackValue.pack(.int16(-0x7fff)), Data([0xd1, 0x80, 0x01]))
    }

    func testUnpackInt16() throws {
        let unpacked = try MessagePackValue.unpack(Data([0xd1, 0x80, 0x01]))
        XCTAssertEqual(unpacked.value, .int16(-0x7fff))
        XCTAssertEqual(unpacked.remainder.count, 0)
    }

    func testPackInt32() {
        XCTAssertEqual(MessagePackValue.pack(.int32(-0x1_0000)), Data([0xd2, 0xff, 0xff, 0x00, 0x00]))
    }

    func testUnpackInt32() throws {
        let unpacked = try MessagePackValue.unpack(Data([0xd2, 0xff, 0xff, 0x00, 0x00]))
        XCTAssertEqual(unpacked.value, .int32(-0x1_0000))
        XCTAssertEqual(unpacked.remainder.count, 0)
    }

    func testPackInt64() {
        XCTAssertEqual(
            MessagePackValue.pack(.int64(-0x1_0000_0000)),
            Data([0xd3, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00])
        )
    }

    func testUnpackInt64() throws {
        let unpacked = try MessagePackValue.unpack(Data([0xd3, 0xff, 0xff, 0xff, 0xff, 0x00, 0x00, 0x00, 0x00]))
        XCTAssertEqual(unpacked.value, .int64(-0x1_0000_0000))
        XCTAssertEqual(unpacked.remainder.count, 0)
    }

    func testUnpackInsufficientData() {
        let dataArray: [Data] = [Data([0xd0]), Data([0xd1]), Data([0xd2]), Data([0xd3]), Data([0xd4])]
        for data in dataArray {
            do {
                _ = try MessagePackValue.unpack(data)
                XCTFail("Expected unpack to throw")
            } catch {
                XCTAssertEqual(error as? MessagePackUnpackError, .insufficientData)
            }
        }
    }
}
