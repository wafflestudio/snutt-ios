//
//  OnboardViewModel.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import AuthInterface
import Combine
import Dependencies
import UIKit

import struct SwiftUI.NavigationPath

@MainActor
@Observable
final class OnboardViewModel {
    @ObservationIgnored
    @Dependency(\.authUseCase) private var authUseCase

    @ObservationIgnored
    @Dependency(\.authRepository) private var authRepository

    @ObservationIgnored
    @Dependency(\.authState) var authState

    @ObservationIgnored
    @Dependency(\.socialAuthServiceProvider) private var socialAuthServiceProvider

    @ObservationIgnored
    @Dependency(\.analyticsLogger) private var analyticsLogger

    var paths = [OnboardDetailSceneTypes]()

    func loginWithLocalId(localID: String, localPassword: String) async throws {
        analyticsLogger.logEvent(AnalyticsAction.login(.init(provider: .local)))
        try await authUseCase.loginWithLocalID(localID: localID, localPassword: localPassword)
    }

    func registerWithLocalID(localID: String, localPassword: String, email: String) async throws {
        analyticsLogger.logEvent(AnalyticsAction.signUp)
        let response = try await authRepository.registerWithLocalID(
            localID: localID,
            localPassword: localPassword,
            email: email
        )
        authState.set(.accessToken, value: response.accessToken)
        authState.set(.userID, value: response.userID)
    }

    func loginWithSocialProvider(provider: SocialAuthProvider) async throws {
        analyticsLogger.logEvent(AnalyticsAction.login(.init(provider: provider.logValue)))
        do {
            let providerToken = try await socialAuthServiceProvider.provider(for: provider).authenticate()
            let response = try await authRepository.loginWithSocial(provider: provider, providerToken: providerToken)
            authState.set(.accessToken, value: response.accessToken)
            authState.set(.userID, value: response.userID)
        } catch let error as SocialAuthError where error.reason.isCancelled {
            return
        }
    }

    func sendVerificationCode(email: String) async throws {
        try await authRepository.sendVerificationCode(email: email)
    }

    func checkVerificationCode(code: String, localID: String? = nil) async throws {
        if let localID {
            try await authRepository.checkVerificationCode(localID: localID, code: code)
        }
    }

    func getLinkedEmail(localID: String) async throws -> String {
        try await authRepository.getLinkedEmail(localID: localID)
    }

    func resetPassword(localID: String, password: String, code: String) async throws {
        try await authRepository.resetPassword(localID: localID, password: password, code: code)
    }

    func findLocalID(email: String) async throws {
        try await authRepository.findLocalID(email: email)
    }

    func sendFeedback(email: String?, message: String) async throws {
        try await authRepository.sendFeedback(email: email, message: message)
    }
}

enum OnboardDetailSceneTypes: Hashable {
    case loginLocal
    case registerLocal
    case findLocalID
    case resetLocalPassword
    case termsOfService
    case verificationCode(email: String, mode: VerificationMode, localID: String? = nil)
    case enterNewPassword(localID: String, verificationCode: String)
    case emailVerification(email: String)
    case userSupport

    enum VerificationMode: Hashable {
        case signup
        case resetPassword
    }
}
