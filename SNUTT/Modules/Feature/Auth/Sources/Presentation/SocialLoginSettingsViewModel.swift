//
//  SocialLoginSettingsViewModel.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import AuthInterface
import Dependencies
import Observation

@MainActor
@Observable
final class SocialLoginSettingsViewModel {
    @ObservationIgnored
    @Dependency(\.authRepository) private var authRepository

    @ObservationIgnored
    @Dependency(\.authState) private var authState

    @ObservationIgnored
    @Dependency(\.socialAuthServiceProvider) private var socialAuthServiceProvider

    private(set) var socialLoginState: SocialAuthProviderState?

    init() {
        Task {
            try? await fetchSocialLoginState()
        }
    }

    private func fetchSocialLoginState() async throws {
        socialLoginState = try await authRepository.fetchSocialAuthProviderState()
    }

    func linkSocialProvider(provider: SocialAuthProvider) async throws {
        do {
            let providerToken = try await socialAuthServiceProvider.provider(for: provider).authenticate()
            let snuttToken = try await authRepository.linkSocial(provider: provider, providerToken: providerToken)
            authState.set(.accessToken, value: snuttToken.accessToken)
        } catch let error as SocialAuthError {
            if case .cancelled = error.reason {
                return
            }
            throw error
        }
        try? await fetchSocialLoginState()
    }

    func unlinkSocialProvider(provider: SocialAuthProvider) async throws {
        let snuttToken = try await authRepository.unlinkSocial(provider: provider)
        authState.set(.accessToken, value: snuttToken.accessToken)
        try? await fetchSocialLoginState()
    }
}
