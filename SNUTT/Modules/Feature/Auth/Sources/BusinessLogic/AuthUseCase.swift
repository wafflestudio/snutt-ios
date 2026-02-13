//
//  AuthUseCase.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import AuthInterface
import Dependencies
import DependenciesUtility
import Foundation
import os

public struct AuthUseCase: AuthUseCaseProtocol {
    @Dependency(\.authRepository) private var authRepository
    @Dependency(\.authState) private var authState
    @Dependency(\.authSecureRepository) private var secureRepository
    @Dependency(\.analyticsLogger) private var analyticsLogger
    @Dependency(\.socialAuthServiceProvider) private var socialAuthServiceProvider

    public init() {}

    public func syncAuthState() {
        if let userID = authState.get(.userID) {
            // If userID exists in userDefaults, store it into in-memory store
            authState.set(.userID, value: userID)
        } else {
            // The user has never logged in, clear the keychain
            authState.clear()
            try? secureRepository.clear()
            return
        }
        if let accessToken = secureRepository.getAccessToken() {
            authState.set(.accessToken, value: accessToken)
        }
    }

    public func loginWithLocalID(localID: String, localPassword: String) async throws {
        let response = try await authRepository.loginWithLocalID(localID: localID, localPassword: localPassword)
        try secureRepository.saveAccessToken(response.accessToken)
        authState.set(.accessToken, value: response.accessToken)
        authState.set(.userID, value: response.userID)
        try await registerPendingFCMTokenIfNeeded()
    }

    public func registerWithLocalID(localID: String, localPassword: String, email: String) async throws {
        let response = try await authRepository.registerWithLocalID(
            localID: localID,
            localPassword: localPassword,
            email: email
        )
        try secureRepository.saveAccessToken(response.accessToken)
        authState.set(.accessToken, value: response.accessToken)
        authState.set(.userID, value: response.userID)
        try await registerPendingFCMTokenIfNeeded()
    }

    public func loginWithSocialProvider(_ provider: SocialAuthProvider) async throws {
        let providerToken = try await socialAuthServiceProvider.provider(for: provider).authenticate()
        let response = try await authRepository.loginWithSocial(provider: provider, providerToken: providerToken)
        try secureRepository.saveAccessToken(response.accessToken)
        authState.set(.accessToken, value: response.accessToken)
        authState.set(.userID, value: response.userID)
        try await registerPendingFCMTokenIfNeeded()
    }

    public func logout() async throws {
        analyticsLogger.logEvent(AnalyticsAction.logout)
        if let fcmToken = authState.get(.fcmToken) {
            try? await authRepository.logout(fcmToken: fcmToken)
        } else {
            Logger.auth.warning("FCM token is not found. Check your firebase settings.")
        }

        clearAllUserData()
        try secureRepository.clear()
        authState.clear()
    }

    public func registerFCMToken(_ token: String) async throws {
        authState.set(.fcmToken, value: token)
        // register fcm token only when `accessToken` exists
        guard authState.get(.accessToken) != nil else { return }
        try await authRepository.addDevice(fcmToken: token)
    }

    public func deleteAccount() async throws {
        try await authRepository.deleteAccount()

        clearAllUserData()
        try secureRepository.clear()
        authState.clear()
    }

    // MARK: - UserDefaults Cleanup

    /// Clear ALL UserDefaults data except system keys
    private func clearAllUserData() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        let fcmTokenKey = UserDefaultsEntryDefinitions().fcmToken.key

        dictionary.keys.forEach { key in
            // Preserve only system keys (Apple*)
            guard !key.hasPrefix("Apple"), key != fcmTokenKey else { return }

            // Remove everything else
            defaults.removeObject(forKey: key)
        }

        defaults.synchronize()
    }

    private func registerPendingFCMTokenIfNeeded() async throws {
        guard authState.get(.accessToken) != nil else { return }
        guard let fcmToken = authState.get(.fcmToken) else { return }
        try await authRepository.addDevice(fcmToken: fcmToken)
    }
}

extension AuthUseCase {
    public func migrateV3AuthIfNeeded() {
        guard let suiteName = legacySuiteName(),
            let legacyDefaults = UserDefaults(suiteName: suiteName)
        else { return }

        let accessToken = legacyDefaults.decodedString(forKey: "accessToken")
        let userID = legacyDefaults.decodedString(forKey: "userId")
        let fcmToken = legacyDefaults.decodedString(forKey: "fcmToken")

        guard let accessToken, let userID else { return }

        authState.set(.userID, value: userID)
        authState.set(.accessToken, value: accessToken)
        if let fcmToken {
            authState.set(.fcmToken, value: fcmToken)
        }

        legacyDefaults.removeObject(forKey: "accessToken")
        legacyDefaults.removeObject(forKey: "userId")
        legacyDefaults.removeObject(forKey: "fcmToken")
    }

    private func legacySuiteName() -> String? {
        guard let bundleIdentifier = Bundle.main.bundleIdentifier else { return nil }
        return "group.\(bundleIdentifier)"
    }
}

extension UserDefaults {
    fileprivate func decodedString(forKey key: String) -> String? {
        guard let data = data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(String.self, from: data)
    }
}
