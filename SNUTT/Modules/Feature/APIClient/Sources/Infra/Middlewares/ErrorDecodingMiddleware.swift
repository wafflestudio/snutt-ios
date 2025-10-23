//
//  ErrorDecodingMiddleware.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import APIClientInterface
import Foundation
import HTTPTypes
import OpenAPIRuntime

public struct ErrorDecodingMiddleware: ClientMiddleware {
    public init() {}

    public func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID _: String,
        next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        let (response, body) = try await next(request, body, baseURL)
        if response.status.code >= 500 {
            throw LocalizedErrorCode.serverFault
        }
        let data = try await Data(collecting: body!, upTo: .max)
        guard let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        else { return (response, HTTPBody(data)) }
        if let error = jsonData["errcode"] as? Int,
            let knownError = LocalizedErrorCode(rawValue: error)
        {
            throw knownError
        }
        if let unknownError = ClientUnknownServerError(jsonData: jsonData) {
            throw unknownError
        }
        return (response, HTTPBody(data))
    }
}

extension ClientUnknownServerError {
    public init?(jsonData: [String: Any]) {
        guard let errorCode = jsonData["errcode"] as? Int else { return nil }
        self.init(
            errorCode: errorCode,
            errorDescription: jsonData["title"] as? String,
            failureReason: jsonData["displayMessage"] as? String,
            recoverySuggestion: jsonData["recoveryMessage"] as? String
        )
    }
}
