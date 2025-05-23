//
//  AuthService.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/24.
//

import Foundation
import SwiftUI

@MainActor
protocol AuthServiceProtocol: Sendable {
    func loadAccessTokenDuringBootstrap()
    func loginWithLocalId(localId: String, localPassword: String) async throws
    func loginWithApple(appleToken: String) async throws
    func loginWithFacebook(facebookToken: String) async throws
    func loginWithGoogle(googleToken: String) async throws
    func loginWithKakao(kakaoToken: String) async throws
    func registerWithLocalId(localId: String, localPassword: String, email: String) async throws
    func findLocalId(email: String) async throws
    func getLinkedEmail(localId: String) async throws -> String
    func sendVerificationCode(email: String) async throws
    func checkVerificationCode(localId: String, code: String) async throws
    func resetPassword(localId: String, password: String, code: String) async throws
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
        appState.user.accessToken = dto.token
        appState.user.userId = dto.user_id
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
        FirebaseAnalyticsLogger().logEvent(.login(.init(provider: .local)))
        let dto = try await authRepository.loginWithLocalId(localId: localId, localPassword: localPassword)
        saveAccessTokenFromLoginResponse(dto: dto)
        try await registerFCMToken()
    }

    func registerWithLocalId(localId: String, localPassword: String, email: String) async throws {
        FirebaseAnalyticsLogger().logEvent(.signUp)
        let dto = try await authRepository.registerWithLocalId(
            localId: localId,
            localPassword: localPassword,
            email: email
        )
        saveAccessTokenFromLoginResponse(dto: dto)
        try await registerFCMToken()
    }

    func loginWithApple(appleToken: String) async throws {
        FirebaseAnalyticsLogger().logEvent(.login(.init(provider: .apple)))
        let dto = try await authRepository.loginWithApple(appleToken: appleToken)
        saveAccessTokenFromLoginResponse(dto: dto)
        try await registerFCMToken()
    }

    func loginWithFacebook(facebookToken: String) async throws {
        FirebaseAnalyticsLogger().logEvent(.login(.init(provider: .facebook)))
        let dto = try await authRepository.loginWithFacebook(facebookToken: facebookToken)
        saveAccessTokenFromLoginResponse(dto: dto)
        try await registerFCMToken()
    }

    func loginWithGoogle(googleToken: String) async throws {
        FirebaseAnalyticsLogger().logEvent(.login(.init(provider: .google)))
        let dto = try await authRepository.loginWithGoogle(googleToken: googleToken)
        saveAccessTokenFromLoginResponse(dto: dto)
        try await registerFCMToken()
    }

    func loginWithKakao(kakaoToken: String) async throws {
        FirebaseAnalyticsLogger().logEvent(.login(.init(provider: .kakao)))
        let dto = try await authRepository.loginWithKakao(kakaoToken: kakaoToken)
        saveAccessTokenFromLoginResponse(dto: dto)
        try await registerFCMToken()
    }

    func findLocalId(email: String) async throws {
        let _ = try await authRepository.findLocalId(email: email)
    }

    func getLinkedEmail(localId: String) async throws -> String {
        try await authRepository.getLinkedEmail(localId: localId).email
    }

    func sendVerificationCode(email: String) async throws {
        try await authRepository.sendVerificationCode(email: email)
    }

    func checkVerificationCode(localId: String, code: String) async throws {
        try await authRepository.checkVerificationCode(localId: localId, code: code)
    }

    func resetPassword(localId: String, password: String, code: String) async throws {
        try await authRepository.resetPassword(localId: localId, password: password, code: code)
    }

    func logout() async throws {
        FirebaseAnalyticsLogger().logEvent(.logout)
        let fcmToken = userDefaultsRepository.get(String.self, key: .fcmToken, defaultValue: "")
        let _ = try? await authRepository.logout(fcmToken: fcmToken)
        clearUserInfo()
    }
}

/// A collection of methods that are called both on `UserService` and `AuthService`.
@MainActor
protocol UserAuthHandler {
    var appState: AppState { get set }
    var localRepositories: AppEnvironment.LocalRepositories { get set }
    func clearUserInfo()
}

extension UserAuthHandler {
    func clearUserInfo() {
        appState.user.accessToken = nil
        appState.user.userId = nil
        appState.user.current = nil
        appState.timetable.current = nil
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
    func loginWithFacebook(facebookToken _: String) async throws {}
    func loginWithGoogle(googleToken _: String) async throws {}
    func loginWithKakao(kakaoToken _: String) async throws {}
    func registerWithLocalId(localId _: String, localPassword _: String, email _: String) async throws {}
    func findLocalId(email _: String) async throws {}
    func getLinkedEmail(localId _: String) async throws -> String { return "" }
    func sendVerificationCode(email _: String) async throws {}
    func checkVerificationCode(localId _: String, code _: String) async throws {}
    func resetPassword(localId _: String, password _: String, code _: String) async throws {}
    func logout() async throws {}
}
