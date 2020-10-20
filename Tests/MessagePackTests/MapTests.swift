import Foundation
import XCTest

@testable import MessagePack

func map(_ count: Int) -> [MessagePackValue: MessagePackValue] {
    var dict = [MessagePackValue: MessagePackValue]()
    for i in 0 ..< UInt64(count) {
        dict[.uint64(i)] = .nil
    }

    return dict
}

func payload(_ count: Int) -> Data {
    var data = Data()
    for i in 0 ..< UInt64(count) {
        data.append(MessagePackValue.pack(.uint64(i)) + MessagePackValue.pack(.nil))
    }

    return data
}

func testPackMap(_ count: Int, prefix: Data) throws {
    let packed = MessagePackValue.pack(.map(map(count)))

    XCTAssertEqual(packed.subdata(in: 0 ..< prefix.count), prefix)

    var remainder = Subdata(data: packed, startIndex: prefix.count, endIndex: packed.count)
    var keys = Set<UInt64>()

    for _ in 0 ..< count {
        let value: MessagePackValue
        (value, remainder) = try MessagePackValue.unpack(remainder)
        let key: UInt64
        if case let .uint64(i) = value {
            key = i
        } else {
            throw MessagePackUnpackError.invalidData
        }

        XCTAssertFalse(keys.contains(key))
        keys.insert(key)

        let nilValue: MessagePackValue
        (nilValue, remainder) = try MessagePackValue.unpack(remainder)
        XCTAssertEqual(nilValue, MessagePackValue.nil)
    }

    XCTAssertEqual(keys.count, count)
}

class MapTests: XCTestCase {
    func testLiteralConversion() {
        let implicitValue: MessagePackValue = ["c": "cookie"]
        XCTAssertEqual(implicitValue, .map([.string("c"): .string("cookie")]))
    }
    
    func testPackFixmap() {
        let packed = Data([0x81, 0xa1, 0x63, 0xa6, 0x63, 0x6f, 0x6f, 0x6b, 0x69, 0x65])
        XCTAssertEqual(MessagePackValue.pack(.map([.string("c"): .string("cookie")])), packed)
    }

    func testUnpackFixmap() throws {
        let packed = Data([0x81, 0xa1, 0x63, 0xa6, 0x63, 0x6f, 0x6f, 0x6b, 0x69, 0x65])

        let unpacked = try MessagePackValue.unpack(packed)
        XCTAssertEqual(unpacked.value, MessagePackValue.map([.string("c"): .string("cookie")]))
        XCTAssertEqual(unpacked.remainder.count, 0)
    }

    func testPackMap16() throws {
        try testPackMap(16, prefix: Data([0xde, 0x00, 0x10]))
    }

    func testUnpackMap16() throws {
        let unpacked = try MessagePackValue.unpack(Data([0xde, 0x00, 0x10]) + payload(16))
        XCTAssertEqual(unpacked.value, MessagePackValue.map(map(16)))
        XCTAssertEqual(unpacked.remainder.count, 0)
    }
}
