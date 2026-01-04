//
//  AuthUseCase.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
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

        dictionary.keys.forEach { key in
            // Preserve only system keys (Apple*)
            guard !key.hasPrefix("Apple") else { return }

            // Remove everything else
            defaults.removeObject(forKey: key)
        }

        defaults.synchronize()
    }
}
