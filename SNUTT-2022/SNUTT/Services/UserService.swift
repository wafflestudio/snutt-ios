//
//  UserService.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/09.
//

import Foundation

protocol UserServiceProtocol {
    func fetchUser() async throws
    func deleteUser() async throws
    func addLocalId(id: String, password: String) async throws
    func changePassword(from oldPassword: String, to newPassword: String) async throws
    func disconnectFacebook() async throws
    func connectFacebook(fbId: String, fbToken: String) async throws
    func addDevice(fcmToken: String) async throws
    func deleteDevice(fcmToken: String) async throws
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

    func changePassword(from oldPassword: String, to newPassword: String) async throws {
        let dto = try await userRepository.changePassword(from: oldPassword, to: newPassword)
        try await updateToken(from: dto)
    }

    func addLocalId(id: String, password: String) async throws {
        let dto = try await userRepository.addLocalId(id: id, password: password)
        try await updateToken(from: dto)
    }

    func connectFacebook(fbId: String, fbToken: String) async throws {
        let dto = try await userRepository.connectFacebook(fbId: fbId, fbToken: fbToken)
        try await updateToken(from: dto)
    }

    func disconnectFacebook() async throws {
        let dto = try await userRepository.disconnectFacebook()
        try await updateToken(from: dto)
    }

    func deleteUser() async throws {
        try await userRepository.deleteUser()
        clearUserInfo()
    }

    func addDevice(fcmToken: String) async throws {
        userDefaultsRepository.set(String.self, key: .fcmToken, value: fcmToken)

        if appState.user.accessToken == nil {
            // defer until sign in
            return
        }

        try await userRepository.addDevice(fcmToken: fcmToken)
    }

    func deleteDevice(fcmToken: String) async throws {
        userDefaultsRepository.set(String.self, key: .fcmToken, value: nil)

        if appState.user.accessToken == nil {
            return
        }

        try await userRepository.deleteDevice(fcmToken: fcmToken)
    }

    private func updateToken(from dto: TokenResponseDto) async throws {
        await MainActor.run {
            appState.user.accessToken = dto.token
        }
        userDefaultsRepository.set(String.self, key: .token, value: dto.token)
        try await fetchUser()
    }

    private func updateUser(from dto: UserDto) {
        await MainActor.run {
            appState.user.current = User(from: dto)
        }
        userDefaultsRepository.set(UserDto.self, key: .userDto, value: dto)
    }
}

class FakeUserService: UserServiceProtocol {
    func fetchUser() {}
    func deleteUser() async throws {}
    func addLocalId(id _: String, password _: String) async throws {}
    func changePassword(from _: String, to _: String) async throws {}
    func disconnectFacebook() async throws {}
    func connectFacebook(fbId _: String, fbToken _: String) async throws {}
    func addDevice(fcmToken _: String) async throws {}
    func deleteDevice(fcmToken _: String) async throws {}
}
