//
//  LiveSocialAuthServiceProvider.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import AuthInterface

public struct LiveSocialAuthServiceProvider: SocialAuthServiceProvider {
    public init() {}

    public func provider(for provider: SocialAuthProvider) -> any SocialAuthService {
        switch provider {
        case .kakao:
            KakaoAuthService()
        case .google:
            GoogleAuthService()
        case .apple:
            AppleAuthService()
        case .facebook:
            FacebookAuthService()
        }
    }
}
