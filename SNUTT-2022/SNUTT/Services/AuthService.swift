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

    func loadAccessTokenDuringBootstrap() {
        /// **DO NOT RUN THIS CODE ASYNCHRONOUSLY**. We need to show splash screen until the loading finishes.
        appState.user.accessToken = userDefaultsRepository.get(String.self, key: .token)
//        appState.user.accessToken = nil
    }

    func loginWithId(id: String, password: String) async throws {
        let dto = try await authRepository.loginWithId(id: id, password: password)
        DispatchQueue.main.async {
            appState.user.accessToken = dto.token
        }
        userDefaultsRepository.set(String.self, key: .token, value: dto.token)
    }
}

class FakeAuthService: AuthServiceProtocol {
    func loadAccessTokenDuringBootstrap() {}
    func loginWithId(id _: String, password _: String) async throws {}
}
