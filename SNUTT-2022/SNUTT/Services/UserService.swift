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

struct UserService: UserServiceProtocol, UserAuthHandler {
    var appState: AppState
    let webRepositories: AppEnvironment.WebRepositories

    var localRepositories: AppEnvironment.LocalRepositories

    var userRepository: UserRepositoryProtocol {
        webRepositories.userRepository
    }

    var userDefaultsRepository: UserDefaultsRepositoryProtocol {
        localRepositories.userDefaultsRepository
    }

    func fetchUser() async throws {
        let dto = try await userRepository.fetchUser()
        updateUser(from: dto)
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
        clearUserToken()
    }

    private func updateToken(from dto: TokenResponseDto) async throws {
        DispatchQueue.main.async {
            appState.user.accessToken = dto.token
        }
        userDefaultsRepository.set(String.self, key: .token, value: dto.token)
        try await fetchUser()
    }

    private func updateUser(from dto: UserDto) {
        DispatchQueue.main.async {
            appState.user.current = User(from: dto)
        }
        userDefaultsRepository.set(UserDto.self, key: .userDto, value: dto)
    }
}

class FakeUserService: UserServiceProtocol {
    func fetchUser() {}
    func unregister() async throws {}
    func addLocalId(id _: String, password _: String) async throws {}
    func changePassword(from _: String, to _: String) async throws {}
    func detachFacebook() async throws {}
    func attachFacebook(fbId _: String, fbToken _: String) async throws {}
}
