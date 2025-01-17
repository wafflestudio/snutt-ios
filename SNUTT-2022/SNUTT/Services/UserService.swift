//
//  UserService.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/09.
//

import Foundation

@MainActor
protocol UserServiceProtocol: Sendable {
    func fetchUser() async throws
    func fetchSocialProvider() async throws
    func changeNickname(to nickname: String) async throws
    func deleteUser() async throws
    func addLocalId(localId: String, localPassword: String) async throws
    func changePassword(from oldPassword: String, to newPassword: String) async throws
    func connectKakao(kakaoToken: String) async throws
    func disconnectKakao() async throws
    func connectGoogle(googleToken: String) async throws
    func disconnectGoogle() async throws
    func connectApple(appleToken: String) async throws
    func disconnectApple() async throws
    func connectFacebook(facebookId: String, facebookToken: String) async throws
    func disconnectFacebook() async throws
    func addDevice(fcmToken: String) async throws
    func deleteDevice(fcmToken: String) async throws
    func sendVerificationCode(email: String) async throws
    func submitVerificationCode(code: String) async throws
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

    func fetchSocialProvider() async throws {
        let dto = try await userRepository.fetchSocialProvider()
        appState.user.socialProvider = SocialProvider(from: dto)
    }

    func fetchUser() async throws {
        let dto = try await userRepository.fetchUser()
        updateUser(from: dto)
    }

    func changeNickname(to nickname: String) async throws {
        let dto = try await userRepository.changeNickname(to: nickname)
        updateUser(from: dto)
    }

    func changePassword(from oldPassword: String, to newPassword: String) async throws {
        let dto = try await userRepository.changePassword(from: oldPassword, to: newPassword)
        try await updateToken(from: dto)
    }

    func addLocalId(localId: String, localPassword: String) async throws {
        let dto = try await userRepository.addLocalId(localId: localId, localPassword: localPassword)
        try await updateToken(from: dto)
    }

    func connectKakao(kakaoToken: String) async throws {
        let dto = try await userRepository.connectKakao(kakaoToken: kakaoToken)
        try await updateToken(from: dto)
    }

    func disconnectKakao() async throws {
        let dto = try await userRepository.disconnectKakao()
        try await updateToken(from: dto)
    }

    func connectGoogle(googleToken: String) async throws {
        let dto = try await userRepository.connectGoogle(googleToken: googleToken)
        try await updateToken(from: dto)
    }

    func disconnectGoogle() async throws {
        let dto = try await userRepository.disconnectGoogle()
        try await updateToken(from: dto)
    }

    func connectApple(appleToken: String) async throws {
        let dto = try await userRepository.connectApple(appleToken: appleToken)
        try await updateToken(from: dto)
    }

    func disconnectApple() async throws {
        let dto = try await userRepository.disconnectApple()
        try await updateToken(from: dto)
    }

    func connectFacebook(facebookId: String, facebookToken: String) async throws {
        let dto = try await userRepository.connectFacebook(facebookId: facebookId, facebookToken: facebookToken)
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

        let _ = try await userRepository.addDevice(fcmToken: fcmToken)
    }

    func deleteDevice(fcmToken: String) async throws {
        userDefaultsRepository.set(String.self, key: .fcmToken, value: nil)

        if appState.user.accessToken == nil {
            return
        }

        let _ = try await userRepository.deleteDevice(fcmToken: fcmToken)
    }

    func sendVerificationCode(email: String) async throws {
        let _ = try await userRepository.sendVerificationCode(email: email)
    }

    func submitVerificationCode(code: String) async throws {
        let _ = try await userRepository.submitVerificationCode(code: code)
    }

    private func updateToken(from dto: TokenResponseDto) async throws {
        appState.user.accessToken = dto.token
        userDefaultsRepository.set(String.self, key: .accessToken, value: dto.token)
        try await fetchUser()
    }

    private func updateUser(from dto: UserDto) {
        appState.user.current = User(from: dto)
        userDefaultsRepository.set(UserDto.self, key: .userDto, value: dto)
    }
}

class FakeUserService: UserServiceProtocol {
    func fetchUser() {}
    func fetchSocialProvider() {}
    func changeNickname(to _: String) async throws {}
    func deleteUser() async throws {}
    func addLocalId(localId _: String, localPassword _: String) async throws {}
    func changePassword(from _: String, to _: String) async throws {}
    func connectKakao(kakaoToken _: String) async throws {}
    func disconnectKakao() async throws {}
    func connectGoogle(googleToken _: String) async throws {}
    func disconnectGoogle() async throws {}
    func connectApple(appleToken _: String) async throws {}
    func disconnectApple() async throws {}
    func connectFacebook(facebookId _: String, facebookToken _: String) async throws {}
    func disconnectFacebook() async throws {}
    func addDevice(fcmToken _: String) async throws {}
    func deleteDevice(fcmToken _: String) async throws {}
    func sendVerificationCode(email _: String) async throws {}
    func submitVerificationCode(code _: String) async throws {}
    func checkEmailVerification() async throws {}
}
