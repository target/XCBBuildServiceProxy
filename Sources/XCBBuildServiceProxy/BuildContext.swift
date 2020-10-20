import Foundation
import Logging
import XCBProtocol

/// A helper object that allows processes to send responses for a specific build.
///
/// An instance of this will be created for each build created.
public final class BuildContext<ResponsePayload: XCBProtocol.ResponsePayload> {
    public let session: String
    public let buildNumber: Int64
    
    private let responseChannel: UInt64
    private let sendResponse: (RPCResponse<ResponsePayload>) -> Void
    
    public init(
        sendResponse: @escaping (RPCResponse<ResponsePayload>) -> Void,
        session: String,
        buildNumber: Int64,
        responseChannel: UInt64
    ) {
        self.session = session
        self.buildNumber = buildNumber
        self.responseChannel = responseChannel
        self.sendResponse = sendResponse
    }
    
    public func sendResponseMessage<PayloadConvertible>(_ payloadConvertible: PayloadConvertible) where
        PayloadConvertible: ResponsePayloadConvertible,
        PayloadConvertible.Payload == ResponsePayload {
        sendResponse(RPCResponse(channel: responseChannel, payload: payloadConvertible.toResponsePayload()))
    }
}
