//
//  SocialAuthService.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

public protocol SocialAuthService: Sendable {
    func authenticate() async throws(SocialAuthError) -> String
}

public struct SocialAuthError: Error {
    public let provider: SocialAuthProvider
    public let reason: Reason

    public enum Reason: Sendable {
        case invalidWindow
        case tokenNotFound
        case sdkError(any Error)
        case cancelled
        case unknown
    }

    public init(provider: SocialAuthProvider, reason: Reason) {
        self.provider = provider
        self.reason = reason
    }
}
