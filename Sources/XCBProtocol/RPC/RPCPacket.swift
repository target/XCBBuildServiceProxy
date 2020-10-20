import Foundation
import MessagePack
import NIO

/// An intermediate representation of an RPC message.
///
/// Bytes are decoded to form an `RPCPacket`. `RPCPacket`s are decoded to form `RPCRequest` and `RPCResponse` instances.
public struct RPCPacket {
    /// The RPC channel that is being communicated on.
    ///
    /// A response will come back on the same channel as a request.
    /// The request might additionally open up a "stream" and send the channel for multiple responses to come back on (e.g. build results),
    /// in which case responses will have a `channel` not first used by a request.
    public let channel: UInt64
    
    /// The content of the message. This will be parsed to form a specific request or response.
    public let body: [MessagePackValue]
}

/// Decodes `RPCPacket`s from, and encodes `RPCPacket`s to, a NIO `Channel`.
public class RPCPacketCodec: ByteToMessageDecoder, MessageToByteEncoder {
    public typealias InboundOut = RPCPacket
    public typealias OutboundIn = RPCPacket
    
    private struct PacketHeader {
        let channel: UInt64
        let payloadSize: UInt32
    }
    
    private let label: String
    
    private var decodedHeader: PacketHeader?
    
    public init(label: String) {
        self.label = label
    }
    
    public func decode(context: ChannelHandlerContext, buffer: inout ByteBuffer) throws -> DecodingState {
        if let packet = try findNextPacket(buffer: &buffer) {
            logger.trace("[\(label)] Decoded RPCPacket: \(packet)")
            context.fireChannelRead(wrapInboundOut(packet))
            return .continue
        } else {
            return .needMoreData
        }
    }
    
    private func findNextPacket(buffer: inout ByteBuffer) throws -> RPCPacket? {
        guard
            let header = decodeHeader(buffer: &buffer),
            let payload = buffer.readBytes(length: Int(header.payloadSize))
        else {
            return nil
        }
        
        // Reset header state since we have read the full packet now
        decodedHeader = nil
        
        logger.trace("[\(label)] Decoded RPCPacket payload: \(payload)")
        
        let body = try MessagePackValue.unpackAll(Data(payload))
        
        return RPCPacket(channel: header.channel, body: body)
    }
    
    private func decodeHeader(buffer: inout ByteBuffer) -> PacketHeader? {
        if let decodedHeader = decodedHeader {
            return decodedHeader
        }
        
        // The first 12 bytes are the channel (UInt64) and payload size (UInt32)
        guard buffer.readableBytes >= 12 else {
            return nil
        }
        
        let header = PacketHeader(
            channel: buffer.readInteger(endianness: .little)!,
            payloadSize: buffer.readInteger(endianness: .little)!
        )
        
        // Save header state since we read it off the stream
        decodedHeader = header
        
        return header
    }
    
    public func encode(data packet: RPCPacket, out: inout ByteBuffer) throws {
        logger.trace("[\(label)] Encoding RPCPacket: \(packet)")
        
        let body = packet.body.reduce(into: Data()) { body, element in body.append(element.pack()) }
        
        out.writeInteger(packet.channel, endianness: .little, as: UInt64.self)
        out.writeInteger(UInt32(body.count), endianness: .little, as: UInt32.self)
        out.writeBytes(body)
    }
}
