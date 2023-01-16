//
//  AuthService.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/24.
//

import Foundation
import SwiftUI

protocol AuthServiceProtocol {
    func loadAccessTokenDuringBootstrap()
    func loginWithLocalId(localId: String, localPassword: String) async throws
    func loginWithApple(appleToken: String) async throws
    func loginWithFacebook(fbId: String, fbToken: String) async throws
    func registerWithLocalId(localId: String, localPassword: String, email: String) async throws
    func findLocalId(email: String) async throws
    func checkLinkedEmail(localId: String) async throws -> String
    func sendVerificationCode(email: String) async throws
    func checkVerificationCode(localId: String, code: String) async throws
    func resetPassword(localId: String, password: String) async throws
    func logout() async throws
}

struct AuthService: AuthServiceProtocol, UserAuthHandler {
    var appState: AppState
    var webRepositories: AppEnvironment.WebRepositories
    var localRepositories: AppEnvironment.LocalRepositories

    var userRepository: UserRepositoryProtocol {
        webRepositories.userRepository
    }

    var authRepository: AuthRepositoryProtocol {
        webRepositories.authRepository
    }

    var userDefaultsRepository: UserDefaultsRepositoryProtocol {
        localRepositories.userDefaultsRepository
    }

    private func saveAccessTokenFromLoginResponse(dto: LoginResponseDto) {
        DispatchQueue.main.async {
            appState.user.accessToken = dto.token
            appState.user.userId = dto.user_id
        }
        userDefaultsRepository.set(String.self, key: .accessToken, value: dto.token)
        userDefaultsRepository.set(String.self, key: .userId, value: dto.user_id)
    }

    private func registerFCMToken() async throws {
        guard let fcmToken = userDefaultsRepository.get(String.self, key: .fcmToken) else { return }
        let _ = try await userRepository.addDevice(fcmToken: fcmToken)
    }

    func loadAccessTokenDuringBootstrap() {
        /// **DO NOT RUN THIS CODE ASYNCHRONOUSLY**. We need to show splash screen until the loading finishes.
        appState.user.accessToken = userDefaultsRepository.get(String.self, key: .accessToken)
        appState.user.userId = userDefaultsRepository.get(String.self, key: .userId)
        if let userDto = userDefaultsRepository.get(UserDto.self, key: .userDto) {
            appState.user.current = User(from: userDto)
        }
    }

    func loginWithLocalId(localId: String, localPassword: String) async throws {
        let dto = try await authRepository.loginWithLocalId(localId: localId, localPassword: localPassword)
        saveAccessTokenFromLoginResponse(dto: dto)
        try await registerFCMToken()
    }

    func registerWithLocalId(localId: String, localPassword: String, email: String) async throws {
        let dto = try await authRepository.registerWithLocalId(localId: localId, localPassword: localPassword, email: email)
        saveAccessTokenFromLoginResponse(dto: dto)
        try await registerFCMToken()
    }

    func loginWithApple(appleToken: String) async throws {
        let dto = try await authRepository.loginWithApple(appleToken: appleToken)
        saveAccessTokenFromLoginResponse(dto: dto)
        try await registerFCMToken()
    }

    func loginWithFacebook(fbId: String, fbToken: String) async throws {
        let dto = try await authRepository.loginWithFacebook(fbId: fbId, fbToken: fbToken)
        saveAccessTokenFromLoginResponse(dto: dto)
        try await registerFCMToken()
    }

    func findLocalId(email: String) async throws {
        let _ = try await authRepository.findLocalId(email: email)
    }

    func checkLinkedEmail(localId: String) async throws -> String {
        return try await authRepository.checkLinkedEmail(localId: localId).email
    }

    func sendVerificationCode(email: String) async throws {
        try await authRepository.sendVerificationCode(email: email)
    }

    func checkVerificationCode(localId: String, code: String) async throws {
        try await authRepository.checkVerificationCode(localId: localId, code: code)
    }

    func resetPassword(localId: String, password: String) async throws {
        try await authRepository.resetPassword(localId: localId, password: password)
    }

    func logout() async throws {
        let fcmToken = userDefaultsRepository.get(String.self, key: .fcmToken, defaultValue: "")
        guard let userId = appState.user.userId else { throw STError(.NO_USER_TOKEN) }
        let _ = try? await authRepository.logout(userId: userId, fcmToken: fcmToken)
        clearUserInfo()
    }
}

/// A collection of methods that are called both on `UserService` and `AuthService`.
protocol UserAuthHandler {
    var appState: AppState { get set }
    var localRepositories: AppEnvironment.LocalRepositories { get set }
    func clearUserInfo()
}

extension UserAuthHandler {
    func clearUserInfo() {
        DispatchQueue.main.async {
            appState.user.accessToken = nil
            appState.user.userId = nil
            appState.user.current = nil
            appState.timetable.current = nil
        }
        localRepositories.userDefaultsRepository.set(TimetableDto.self, key: .currentTimetable, value: nil)
        localRepositories.userDefaultsRepository.set(String.self, key: .accessToken, value: nil)
        localRepositories.userDefaultsRepository.set(String.self, key: .userId, value: nil)
        localRepositories.userDefaultsRepository.set(UserDto.self, key: .userDto, value: nil)
        localRepositories.userDefaultsRepository.set(String.self, key: .fcmToken, value: nil)
    }
}

class FakeAuthService: AuthServiceProtocol {
    func loadAccessTokenDuringBootstrap() {}
    func loginWithLocalId(localId _: String, localPassword _: String) async throws {}
    func loginWithApple(appleToken _: String) async throws {}
    func loginWithFacebook(fbId _: String, fbToken _: String) async throws {}
    func registerWithLocalId(localId _: String, localPassword _: String, email _: String) async throws {}
    func findLocalId(email _: String) async throws {}
    func checkLinkedEmail(localId _: String) async throws -> String { return "" }
    func sendVerificationCode(email _: String) async throws {}
    func checkVerificationCode(localId _: String, code _: String) async throws {}
    func resetPassword(localId _: String, password _: String) async throws {}
    func logout() async throws {}
}
