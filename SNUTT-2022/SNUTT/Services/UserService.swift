//
//  UserService.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/09.
//

import Foundation

protocol UserServiceProtocol {
    func fetchUser() async throws
    func unregister() async throws
    func addLocalId(id: String, password: String) async throws
    func changePassword(from oldPassword: String, to newPassword: String) async throws
    func detachFacebook() async throws
    func attachFacebook(fbId: String, fbToken: String) async throws
}

struct UserService: UserServiceProtocol {
    let appState: AppState
    let webRepositories: AppEnvironment.WebRepositories

    var localRepositories: AppEnvironment.LocalRepositories

    var userRepository: UserRepositoryProtocol {
        webRepositories.userRepository
    }

    var userDefaultsRepository: UserDefaultsRepositoryProtocol {
        localRepositories.userDefaultsRepository
    }

    func fetchUser() async throws {
        let userDto = try await userRepository.fetchUser()
        let user = User(from: userDto)
        userDefaultsRepository.set(String.self, key: .userLocalId, value: user.localId)
        userDefaultsRepository.set(String.self, key: .userFBName, value: user.fbName)
        updateState(to: user)
    }
    
    func attachFacebook(fbId: String, fbToken: String) async throws {
        let dto = try await userRepository.attachFacebook(fbId: fbId, fbToken: fbToken)
        try await updateToken(from: dto)
    }
    
    func detachFacebook() async throws {
        let dto = try await userRepository.detachFacebook()
        try await updateToken(from: dto)
    }
    
    func changePassword(from oldPassword: String, to newPassword: String) async throws {
        let dto = try await userRepository.changePassword(from: oldPassword, to: newPassword)
        try await updateToken(from: dto)
    }
    
    func addLocalId(id: String, password: String) async throws {
        let dto = try await userRepository.addLocalId(id: id, password: password)
        try await updateToken(from: dto)
    }
    
    func unregister() async throws {
        try await userRepository.unregister()
        DispatchQueue.main.async {
            appState.user.accessToken = nil
            appState.user.userId = nil
        }
        userDefaultsRepository.set(String.self, key: .token, value: nil)
        userDefaultsRepository.set(String.self, key: .userId, value: nil)
    }
    
    private func updateToken(from dto: TokenResponseDto) async throws {
        DispatchQueue.main.async {
            appState.user.accessToken = dto.token
        }
        try await fetchUser()
    }
    
    private func updateState(to user: User) {
        DispatchQueue.main.async {
            appState.user.current = user
        }
    }
}

class FakeUserService: UserServiceProtocol {
    func fetchUser() {}
    func unregister() async throws {}
    func addLocalId(id: String, password ord: String) async throws {}
    func changePassword(from oldPassword: String, to newPassword: String) async throws {}
    func detachFacebook() async throws {}
    func attachFacebook(fbId: String, fbToken: String) async throws {}
}
