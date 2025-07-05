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
import APIClient

public struct APIClientProvider: Sendable {
    @Dependency(\.appMetadata) private var appMetadata
    @Dependency(\.authState) private var authState
    @Dependency(\.authSecureRepository) private var secureRepository

    public func apiClient() -> any APIProtocol {
        Client(
            serverURL: URL(string: "https://\(appMetadata[.apiURL])")!,
            configuration: .init(dateTranscoder: LenientDateTranscoder()),
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

private struct LenientDateTranscoder: DateTranscoder, @unchecked Sendable {
    private let transcoder: any DateTranscoder = .iso8601WithFractionalSeconds
    private let fallbackTranscoder: any DateTranscoder = .iso8601

    public func encode(_ date: Date) throws -> String {
        try transcoder.encode(date)
    }

    public func decode(_ string: String) throws -> Date {
        do {
            return try transcoder.decode(string)
        } catch {
            return try fallbackTranscoder.decode(string)
        }
    }
}

extension ClientError: @retroactive ErrorWrapper {}
