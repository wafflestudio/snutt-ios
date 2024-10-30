//
//  UserRepository.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/09.
//

import Alamofire
import Foundation

protocol UserRepositoryProtocol {
    func fetchUser() async throws -> UserDto
    func fetchSocialProvider() async throws -> SocialProviderDto
    func changeNickname(to nickname: String) async throws -> UserDto
    func connectKakao(kakaoToken: String) async throws -> TokenResponseDto
    func disconnectKakao() async throws -> TokenResponseDto
    func connectGoogle(googleToken: String) async throws -> TokenResponseDto
    func disconnectGoogle() async throws -> TokenResponseDto
    func connectFacebook(facebookId: String, facebookToken: String) async throws -> TokenResponseDto
    func disconnectFacebook() async throws -> TokenResponseDto
    func changePassword(from oldPassword: String, to newPassword: String) async throws -> TokenResponseDto
    func addLocalId(localId: String, localPassword: String) async throws -> TokenResponseDto
    func deleteUser() async throws
    func addDevice(fcmToken: String) async throws -> DeviceResponseDto
    func deleteDevice(fcmToken: String) async throws -> DeviceResponseDto
    func sendVerificationCode(email: String) async throws -> SendVerificationCodeDto
    func submitVerificationCode(code: String) async throws -> EmailVerifiedDto
}

class UserRepository: UserRepositoryProtocol {
    private let session: Session

    init(session: Session) {
        self.session = session
    }

    func fetchUser() async throws -> UserDto {
        return try await session
            .request(UserRouter.getUser)
            .serializingDecodable(UserDto.self)
            .handlingError()
    }

    func fetchSocialProvider() async throws -> SocialProviderDto {
        return try await session
            .request(UserRouter.getSocialProvider)
            .serializingDecodable(SocialProviderDto.self)
            .handlingError()
    }

    func changeNickname(to nickname: String) async throws -> UserDto {
        return try await session
            .request(UserRouter.changeNickname(nickname: nickname))
            .serializingDecodable(UserDto.self)
            .handlingError()
    }

    func connectKakao(kakaoToken: String) async throws ->
        TokenResponseDto
    {
        return try await session
            .request(UserRouter.connectKakao(kakaoToken: kakaoToken))
            .serializingDecodable(TokenResponseDto.self)
            .handlingError()
    }

    func disconnectKakao() async throws -> TokenResponseDto {
        return try await session
            .request(UserRouter.disconnectKakao)
            .serializingDecodable(TokenResponseDto.self)
            .handlingError()
    }

    func connectGoogle(googleToken: String) async throws ->
        TokenResponseDto
    {
        return try await session
            .request(UserRouter.connectGoogle(googleToken: googleToken))
            .serializingDecodable(TokenResponseDto.self)
            .handlingError()
    }

    func disconnectGoogle() async throws -> TokenResponseDto {
        return try await session
            .request(UserRouter.disconnectKakao)
            .serializingDecodable(TokenResponseDto.self)
            .handlingError()
    }

    func connectFacebook(facebookId: String, facebookToken: String) async throws -> TokenResponseDto {
        return try await session
            .request(UserRouter.connectFacebook(facebookId: facebookId, facebookToken: facebookToken))
            .serializingDecodable(TokenResponseDto.self)
            .handlingError()
    }

    func disconnectFacebook() async throws -> TokenResponseDto {
        return try await session
            .request(UserRouter.disconnectFacebook)
            .serializingDecodable(TokenResponseDto.self)
            .handlingError()
    }

    func changePassword(from oldPassword: String, to newPassword: String) async throws -> TokenResponseDto {
        return try await session
            .request(UserRouter.changePassword(oldPassword: oldPassword, newPassword: newPassword))
            .serializingDecodable(TokenResponseDto.self)
            .handlingError()
    }

    func addLocalId(localId: String, localPassword: String) async throws -> TokenResponseDto {
        return try await session
            .request(UserRouter.addLocalId(localId: localId, localPassword: localPassword))
            .serializingDecodable(TokenResponseDto.self)
            .handlingError()
    }

    func addDevice(fcmToken: String) async throws -> DeviceResponseDto {
        return try await session
            .request(UserRouter.addDevice(fcmToken: fcmToken))
            .serializingDecodable(DeviceResponseDto.self)
            .handlingError()
    }

    func deleteDevice(fcmToken: String) async throws -> DeviceResponseDto {
        return try await session
            .request(UserRouter.deleteDevice(fcmToken: fcmToken))
            .serializingDecodable(DeviceResponseDto.self)
            .handlingError()
    }

    func deleteUser() async throws {
        let _ = try await session
            .request(UserRouter.deleteUser)
            .serializingString()
            .handlingError()
    }

    func sendVerificationCode(email: String) async throws -> SendVerificationCodeDto {
        try await session.request(UserRouter.sendVerificationCode(email: email))
            .serializingDecodable(SendVerificationCodeDto.self)
            .handlingError()
    }

    func submitVerificationCode(code: String) async throws -> EmailVerifiedDto {
        try await session.request(UserRouter.submitVerificationCode(code: code))
            .serializingDecodable(EmailVerifiedDto.self)
            .handlingError()
    }
}
