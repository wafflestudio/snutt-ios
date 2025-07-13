//
//  TestClientTransport.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Foundation
import HTTPTypes
import OpenAPIRuntime
import OpenAPIURLSession

/// A test implementation of the `ClientTransport` protocol.
///
/// The `TestClientTransport` struct provides a way to simulate network calls by
/// utilizing a custom `CallHandler` closure. This allows testing the behavior of
/// client-side API interactions in controlled scenarios.
///
/// Example usage:
/// ```swift
/// let testTransport = TestClientTransport { request, baseURL, operationID in
///     // Simulate response logic here
///     return Response(...)
/// }
///
/// let client = APIClient(transport: testTransport)
/// ```
public struct TestClientTransport: ClientTransport {
    /// A typealias representing a call handler closure for processing client requests.
    public typealias CallHandler = @Sendable (HTTPRequest, HTTPBody?, URL, String) async throws -> (
        HTTPResponse, HTTPBody?
    )

    /// The call handler responsible for processing client requests.
    public let callHandler: CallHandler

    /// Initializes a `TestClientTransport` instance with a custom call handler.
    ///
    /// - Parameter callHandler: The closure responsible for processing client requests.
    public init(callHandler: @escaping CallHandler) { self.callHandler = callHandler }

    /// Sends a client request using the test transport.
    ///
    /// - Parameters:
    ///   - request: The request to send.
    ///   - body: The optional HTTP body to include in the request.
    ///   - baseURL: The base URL for the request.
    ///   - operationID: The ID of the operation being performed.
    /// - Returns: The response received from the call handler.
    /// - Throws: An error if the call handler encounters an issue.
    public func send(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String
    ) async throws -> (
        HTTPResponse, HTTPBody?
    ) { try await callHandler(request, body, baseURL, operationID) }
}
