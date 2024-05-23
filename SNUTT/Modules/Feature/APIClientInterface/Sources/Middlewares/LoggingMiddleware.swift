//
//  LoggingMiddleware.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import OpenAPIRuntime
import HTTPTypes
import Foundation
import Dependencies

public struct LoggingMiddleware: ClientMiddleware {
    public init() {}

    public func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        let (response, body) = try await next(request, body, baseURL)
        let data = try await Data(collecting: body!, upTo: .max)
        if let json = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers),
           let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
           let prettyString = String(data: prettyData, encoding: .utf8) {
//            print(prettyString)
        }
        return (response, HTTPBody(data))
    }
}
