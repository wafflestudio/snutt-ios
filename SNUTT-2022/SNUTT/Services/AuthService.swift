//
//  AuthService.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/24.
//

import Foundation

protocol AuthServiceProtocol {
    func loadAccessTokenDuringBootstrap()
    func loginWithLocalId(localId: String, localPassword: String) async throws
    func loginWithApple(appleToken: String) async throws
    func loginWithFacebook(fbId: String, fbToken: String) async throws
    func registerWithLocalId(localId: String, localPassword: String, email: String) async throws
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

    @MainActor private func saveAccessTokenFromLoginResponse(dto: LoginResponseDto) async {
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
        let dto = try await authRepository.loginWithLocalId(localId: localId, localPassword: localPassword)
        await saveAccessTokenFromLoginResponse(dto: dto)
        try await registerFCMToken()
    }

    func registerWithLocalId(localId: String, localPassword: String, email: String) async throws {
        let dto = try await authRepository.registerWithLocalId(localId: localId, localPassword: localPassword, email: email)
        await saveAccessTokenFromLoginResponse(dto: dto)
        try await registerFCMToken()
    }

    func loginWithApple(appleToken: String) async throws {
        let dto = try await authRepository.loginWithApple(appleToken: appleToken)
        await saveAccessTokenFromLoginResponse(dto: dto)
        try await registerFCMToken()
    }

    func loginWithFacebook(fbId: String, fbToken: String) async throws {
        let dto = try await authRepository.loginWithFacebook(fbId: fbId, fbToken: fbToken)
        await saveAccessTokenFromLoginResponse(dto: dto)
        try await registerFCMToken()
    }

    func logout() async throws {
        let fcmToken = userDefaultsRepository.get(String.self, key: .fcmToken, defaultValue: "")
        guard let userId = appState.user.userId else { throw STError(.NO_USER_TOKEN) }
        let _ = try? await authRepository.logout(userId: userId, fcmToken: fcmToken)
        await clearUserInfo()
    }
}

/// A collection of methods that are called both on `UserService` and `AuthService`.
protocol UserAuthHandler {
    var appState: AppState { get set }
    var localRepositories: AppEnvironment.LocalRepositories { get set }
    func clearUserInfo() async
}

extension UserAuthHandler {
    @MainActor func clearUserInfo() async {
        appState.user.accessToken = nil
        appState.user.userId = nil
        appState.user.current = nil
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
    func logout() async throws {}
}
