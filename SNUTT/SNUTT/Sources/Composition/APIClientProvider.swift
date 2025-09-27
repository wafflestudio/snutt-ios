//
//  APIClientProvider.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import APIClient
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

private struct LenientDateTranscoder: DateTranscoder {
    private let transcoder: any DateTranscoder = .iso8601WithFractionalSeconds
    private let fallbackTranscoders: [any DateTranscoder] = [
        ISO8601DateTranscoder.iso8601,
        TimezoneFallbackTranscoder(transcoder: .iso8601WithFractionalSeconds),
    ]

    public func encode(_ date: Date) throws -> String {
        try transcoder.encode(date)
    }

    public func decode(_ string: String) throws -> Date {
        do {
            return try transcoder.decode(string)
        } catch {
            if let date = fallbackTranscoders.lazy.compactMap { try? $0.decode(string) }.first {
                return date
            }
            throw error
        }
    }
}

private struct TimezoneFallbackTranscoder: DateTranscoder {
    let transcoder: any DateTranscoder

    func encode(_ date: Date) throws -> String {
        try transcoder.encode(date)
    }

    func decode(_ string: String) throws -> Date {
        if hasTimeZone(string) {
            try transcoder.decode(string)
        } else {
            try transcoder.decode(string + "Z")
        }
    }

    private func hasTimeZone(_ s: String) -> Bool {
        let tzRegex = /Z$|[+\-]\d{2}(?::\d{2})?$/
        return s.wholeMatch(of: tzRegex) != nil
    }
}

extension ClientError: @retroactive ErrorWrapper {}
