//
//  AuthenticationMiddleware.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import APIClientInterface
import Foundation
import HTTPTypes
import OpenAPIRuntime
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
        operationID _: String,
        next: @Sendable (HTTPRequest, HTTPBody?, URL) async throws -> (HTTPResponse, HTTPBody?)
    ) async throws -> (HTTPResponse, HTTPBody?) {
        var request = request
        if let accessToken = accessToken(),
            let accessTokenKey = HTTPField.Name("x-access-token")
        {
            request.headerFields[accessTokenKey] = accessToken
        }
        for item in AppMetadataKey.allCases {
            guard let key = item.keyForHeader,
                let headerKey = HTTPField.Name(key)
            else { continue }
            request.headerFields[headerKey] = appMetadata[item]
        }
        do {
            return try await next(request, body, baseURL)
        } catch let error as ClientError {
            if let knownError = error.underlyingError as? LocalizedErrorCode,
                [.wrongUserToken, .noUserToken].contains(knownError)
            {
                handleUnauthenticated()
            }
            throw error
        } catch {
            throw error
        }
    }
}
