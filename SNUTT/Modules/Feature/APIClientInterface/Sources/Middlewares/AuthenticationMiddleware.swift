//
//  AuthenticationMiddleware.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import OpenAPIRuntime
import HTTPTypes
import Foundation
import Dependencies
import SharedAppMetadata

public struct AuthenticationMiddleware: ClientMiddleware {
    private let appMetadata: AppMetadata
    private let accessToken: @Sendable () -> String?
    private let handleUnauthenticated: @Sendable () -> Void
    public init(
        appMetadata: AppMetadata,
        accessToken: @autoclosure @escaping @Sendable () -> String?,
        handleUnauthenticated: @escaping @Sendable () -> Void
    ) {
        self.appMetadata = appMetadata
        self.accessToken = accessToken
        self.handleUnauthenticated = handleUnauthenticated
    }

    public func intercept(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String,
        next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var request = request
        if let accessToken = accessToken(),
           let accessTokenKey = HTTPField.Name("x-access-token") {
            request.headerFields[accessTokenKey] = accessToken
        }
        AppMetadataKey.allCases
            .forEach {
                guard let key = $0.keyForHeader,
                      let headerKey = HTTPField.Name(key) else { return }
                request.headerFields[headerKey] = appMetadata[$0]
            }
        let (response, body) = try await next(request, body, baseURL)
        if response.status.kind == .clientError {
            handleUnauthenticated()
        }
        return (response, body)
    }
}
