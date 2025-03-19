//
//  AuthUseCase.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import AuthInterface
import Dependencies

public struct AuthUseCase: AuthUseCaseProtocol {
    @Dependency(\.authRepository) private var authRepository
    @Dependency(\.authState) private var authState
    @Dependency(\.authSecureRepository) private var secureRepository

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
        guard let fcmToken = authState.get(.fcmToken) else {
            return
        }
        try await authRepository.logout(fcmToken: fcmToken)
        try secureRepository.clear()
        authState.clear()
    }

    public func registerFCMToken(_ token: String) async throws {
        authState.set(.fcmToken, value: token)
        // register fcm token only when `accessToken` exists
        guard let _ = authState.get(.accessToken) else { return }
        try await authRepository.addDevice(fcmToken: token)
    }

    public func deleteAccount() async throws {
        try await authRepository.deleteAccount()
        try secureRepository.clear()
        authState.clear()
    }
}
