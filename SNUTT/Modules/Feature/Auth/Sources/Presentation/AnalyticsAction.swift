//
//  AnalyticsAction.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import AnalyticsInterface
import AuthInterface
import FoundationUtility

enum AnalyticsAction: AnalyticsLogEvent {
    var eventName: String {
        switch self {
        case .login:
            "login"
        case .logout:
            "logout"
        case .signUp:
            "sign_up"
        }
    }

    var parameters: [String: String]? {
        switch self {
        case .login(let loginParameter):
            loginParameter.stringDictionary
        case .logout, .signUp:
            nil
        }
    }

    case login(LoginParameter)
    case logout
    case signUp
}

struct LoginParameter: Encodable, Sendable {
    enum Provider: String, Encodable, Sendable {
        case local
        case google
        case apple
        case facebook
        case kakao
    }

    let provider: Provider
}

extension SocialAuthProvider {
    var logValue: LoginParameter.Provider {
        switch self {
        case .kakao:
            .kakao
        case .google:
            .google
        case .apple:
            .apple
        case .facebook:
            .facebook
        }
    }
}
