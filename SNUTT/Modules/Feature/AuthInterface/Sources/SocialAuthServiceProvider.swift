//
//  SocialAuthServiceProvider.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Dependencies

public protocol SocialAuthServiceProvider: Sendable {
    func provider(for provider: SocialAuthProvider) -> any SocialAuthService
}

public enum SocialAuthServiceProviderKey: TestDependencyKey {
    public typealias Value = any SocialAuthServiceProvider
    public static let testValue: any SocialAuthServiceProvider = UnimplementedSocialAuthServiceProvider()
}

struct UnimplementedSocialAuthServiceProvider: SocialAuthServiceProvider {
    func provider(for provider: SocialAuthProvider) -> any SocialAuthService {
        fatalError("SocialAuthServiceProvider.provider(_:) is not implemented")
    }
}

extension DependencyValues {
    public var socialAuthServiceProvider: any SocialAuthServiceProvider {
        get { self[SocialAuthServiceProviderKey.self] }
        set { self[SocialAuthServiceProviderKey.self] = newValue }
    }
}
