//
//  APIClientProvider.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import APIClientInterface
import AuthInterface
import Dependencies
import Foundation
import OpenAPIRuntime
import OpenAPIURLSession
import SharedAppMetadata
import SharedUIComponents

public struct APIClientProvider: Sendable {
    @Dependency(\.appMetadata) private var appMetadata
    @Dependency(\.authState) private var authState
    @Dependency(\.authSecureRepository) private var secureRepository

    public func apiClient() -> any APIProtocol {
        Client(
            serverURL: URL(string: "https://\(appMetadata[.apiURL])")!,
            configuration: .init(dateTranscoder: .iso8601WithFractionalSeconds),
            transport: URLSessionTransport(),
            middlewares: [
                AuthenticationMiddleware(
                    appMetadata: appMetadata,
                    accessToken: authState.get(.accessToken),
                    handleUnauthenticated: {
                        authState.clear()
                        try? secureRepository.clear()
                    }
                ),
                ErrorDecodingMiddleware(),
                LoggingMiddleware(),
            ]
        )
    }
}

extension ClientError: @retroactive ErrorWrapper {}
