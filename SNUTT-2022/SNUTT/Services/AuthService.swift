//
//  AuthService.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/24.
//

import Foundation

protocol AuthServiceProtocol {
    func loadAccessTokenDuringBootstrap()
    func loginWithId(id: String, password: String) async throws
    func loginWithApple(token: String) async throws
    func loginWithFacebook(id: String, token: String) async throws
    func registerWithId(id: String, password: String, email: String?) async throws
    func logout() async throws
}

struct AuthService: AuthServiceProtocol {
    let appState: AppState
    let webRepositories: AppEnvironment.WebRepositories
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
        userDefaultsRepository.set(String.self, key: .token, value: dto.token)
        userDefaultsRepository.set(String.self, key: .userId, value: dto.user_id)
    }

    func loadAccessTokenDuringBootstrap() {
        /// **DO NOT RUN THIS CODE ASYNCHRONOUSLY**. We need to show splash screen until the loading finishes.
        appState.user.accessToken = userDefaultsRepository.get(String.self, key: .token)
        appState.user.userId = userDefaultsRepository.get(String.self, key: .userId)
        if let userDto = userDefaultsRepository.get(UserDto.self, key: .userDto) {
            appState.user.current = User(from: userDto)
        }
    }

    func loginWithId(id: String, password: String) async throws {
        let dto = try await authRepository.loginWithId(id: id, password: password)
        saveAccessTokenFromLoginResponse(dto: dto)
    }
    
    func registerWithId(id: String, password: String, email: String?) async throws {
        let dto = try await authRepository.registerWithId(id: id, password: password, email: email)
        saveAccessTokenFromLoginResponse(dto: dto)
    }

    func loginWithApple(token: String) async throws {
        let dto = try await authRepository.loginWithApple(token: token)
        saveAccessTokenFromLoginResponse(dto: dto)
    }

    func loginWithFacebook(id: String, token: String) async throws {
        let dto = try await authRepository.loginWithFacebook(id: id, token: token)
        saveAccessTokenFromLoginResponse(dto: dto)
    }
    
    func logout() async throws {
        // TODO: update when FCM ready
        guard let userId = appState.user.userId else { throw STError.NO_USER_TOKEN }
        let _ = try? await authRepository.logout(userId: userId, fcmToken: "fweafa")
        DispatchQueue.main.async {
            appState.user.accessToken = nil
            appState.user.userId = nil
            appState.user.current = nil
        }
        userDefaultsRepository.set(String.self, key: .token, value: nil)
        userDefaultsRepository.set(String.self, key: .userId, value: nil)
        userDefaultsRepository.set(UserDto.self, key: .userDto, value: nil)
//        if dto.message != "ok" {
//            throw STError.UNKNOWN_ERROR
//        }
    }
}

class FakeAuthService: AuthServiceProtocol {
    func loadAccessTokenDuringBootstrap() {}
    func loginWithId(id _: String, password _: String) async throws {}
    func loginWithApple(token _: String) async throws {}
    func loginWithFacebook(id _: String, token _: String) async throws {}
    func registerWithId(id: String, password: String, email: String?) async throws {}
    func logout() async throws {}
}
