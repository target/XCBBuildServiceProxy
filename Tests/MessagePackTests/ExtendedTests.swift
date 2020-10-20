import Foundation
import XCTest

@testable import MessagePack

class ExtendedTests: XCTestCase {
    func testPackFixext1() {
        let value = MessagePackValue.extended(5, Data([0x00]))
        let packed = Data([0xd4, 0x05, 0x00])
        XCTAssertEqual(MessagePackValue.pack(value), packed)
    }

    func testUnpackFixext1() throws {
        let packed = Data([0xd4, 0x05, 0x00])
        let value = MessagePackValue.extended(5, Data([0x00]))

        let unpacked = try MessagePackValue.unpack(packed)
        XCTAssertEqual(unpacked.value, value)
        XCTAssertEqual(unpacked.remainder.count, 0)
    }

    func testPackFixext2() {
        let value = MessagePackValue.extended(5, Data([0x00, 0x01]))
        let packed = Data([0xd5, 0x05, 0x00, 0x01])
        XCTAssertEqual(MessagePackValue.pack(value), packed)
    }

    func testUnpackFixext2() throws {
        let packed = Data([0xd5, 0x05, 0x00, 0x01])
        let value = MessagePackValue.extended(5, Data([0x00, 0x01]))

        let unpacked = try MessagePackValue.unpack(packed)
        XCTAssertEqual(unpacked.value, value)
        XCTAssertEqual(unpacked.remainder.count, 0)
    }

    func testPackFixext4() {
        let value = MessagePackValue.extended(5, Data([0x00, 0x01, 0x02, 0x03]))
        let packed = Data([0xd6, 0x05, 0x00, 0x01, 0x02, 0x03])
        XCTAssertEqual(MessagePackValue.pack(value), packed)
    }

    func testUnpackFixext4() throws {
        let packed = Data([0xd6, 0x05, 0x00, 0x01, 0x02, 0x03])
        let value = MessagePackValue.extended(5, Data([0x00, 0x01, 0x02, 0x03]))

        let unpacked = try MessagePackValue.unpack(packed)
        XCTAssertEqual(unpacked.value, value)
        XCTAssertEqual(unpacked.remainder.count, 0)
    }

    func testPackFixext8() {
        let value = MessagePackValue.extended(5, Data([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07]))
        let packed = Data([0xd7, 0x05, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07])
        XCTAssertEqual(MessagePackValue.pack(value), packed)
    }

    func testUnpackFixext8() throws {
        let packed = Data([0xd7, 0x05, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07])
        let value = MessagePackValue.extended(5, Data([0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07]))

        let unpacked = try MessagePackValue.unpack(packed)
        XCTAssertEqual(unpacked.value, value)
        XCTAssertEqual(unpacked.remainder.count, 0)
    }

    func testPackFixext16() {
        let value = MessagePackValue.extended(5, Data([
            0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
        ]))
        let packed = Data([
            0xd8, 0x05, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
        ])
        XCTAssertEqual(MessagePackValue.pack(value), packed)
    }

    func testUnpackFixext16() throws {
        let value = MessagePackValue.extended(5, Data([
            0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
        ]))
        let packed = Data([
            0xd8, 0x05, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f,
        ])

        let unpacked = try MessagePackValue.unpack(packed)
        XCTAssertEqual(unpacked.value, value)
        XCTAssertEqual(unpacked.remainder.count, 0)
    }

    func testPackExt8() {
        let payload = Data(count: 7)
        let value = MessagePackValue.extended(5, payload)
        XCTAssertEqual(MessagePackValue.pack(value), Data([0xc7, 0x07, 0x05]) + payload)
    }

    func testUnpackExt8() throws {
        let payload = Data(count: 7)
        let value = MessagePackValue.extended(5, payload)

        let unpacked = try MessagePackValue.unpack(Data([0xc7, 0x07, 0x05]) + payload)
        XCTAssertEqual(unpacked.value, value)
        XCTAssertEqual(unpacked.remainder.count, 0)
    }

    func testPackExt16() {
        let payload = Data(count: 0x100)
        let value = MessagePackValue.extended(5, payload)
        XCTAssertEqual(MessagePackValue.pack(value), Data([0xc8, 0x01, 0x00, 0x05]) + payload)
    }

    func testUnpackExt16() throws {
        let payload = Data(count: 0x100)
        let value = MessagePackValue.extended(5, payload)

        let unpacked = try MessagePackValue.unpack(Data([0xc8, 0x01, 0x00, 0x05]) + payload)
        XCTAssertEqual(unpacked.value, value)
        XCTAssertEqual(unpacked.remainder.count, 0)
    }

    func testPackExt32() {
        let payload = Data(count: 0x10000)
        let value = MessagePackValue.extended(5, payload)
        XCTAssertEqual(MessagePackValue.pack(value), Data([0xc9, 0x00, 0x01, 0x00, 0x00, 0x05]) + payload)
    }

    func testUnpackExt32() throws {
        let payload = Data(count: 0x10000)
        let value = MessagePackValue.extended(5, payload)

        let unpacked = try MessagePackValue.unpack(Data([0xc9, 0x00, 0x01, 0x00, 0x00, 0x05]) + payload)
        XCTAssertEqual(unpacked.value, value)
        XCTAssertEqual(unpacked.remainder.count, 0)
    }

    func testUnpackInsufficientData() {
        let dataArray: [Data] = [
            // fixent
            Data([0xd4]), Data([0xd5]), Data([0xd6]), Data([0xd7]), Data([0xd8]),
            
            // ext 8, 16, 32
            Data([0xc7]), Data([0xc8]), Data([0xc9]),
        ]

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
