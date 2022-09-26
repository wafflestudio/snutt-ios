//
//  AuthRepository.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/24.
//

import Alamofire
import Foundation

protocol AuthRepositoryProtocol {
    func registerWithId(id: String, password: String, email: String?) async throws -> LoginResponseDto
    func loginWithApple(token: String) async throws -> LoginResponseDto
    func loginWithFacebook(id: String, token: String) async throws -> LoginResponseDto
    func loginWithId(id: String, password: String) async throws -> LoginResponseDto
    func logout(userId: String, fcmToken: String) async throws -> LogoutResponseDto
}

class AuthRepository: AuthRepositoryProtocol {
    private let session: Session

    init(session: Session) {
        self.session = session
    }

    func registerWithId(id: String, password: String, email: String?) async throws -> LoginResponseDto {
        return try await session
            .request(AuthRouter.registerWithId(id: id, password: password, email: email))
            .serializingDecodable(LoginResponseDto.self)
            .handlingError()
    }

    func loginWithApple(token: String) async throws -> LoginResponseDto {
        return try await session
            .request(AuthRouter.loginWithApple(token: token))
            .serializingDecodable(LoginResponseDto.self)
            .handlingError()
    }

    func loginWithFacebook(id: String, token: String) async throws -> LoginResponseDto {
        return try await session
            .request(AuthRouter.loginWithFacebook(id: id, token: token))
            .serializingDecodable(LoginResponseDto.self)
            .handlingError()
    }

    func loginWithId(id: String, password: String) async throws -> LoginResponseDto {
        return try await session
            .request(AuthRouter.loginWithId(id: id, password: password))
            .serializingDecodable(LoginResponseDto.self)
            .handlingError()
    }

    func logout(userId: String, fcmToken: String) async throws -> LogoutResponseDto {
        return try await session
            .request(AuthRouter.logout(userId: userId, fcmToken: fcmToken))
            .serializingDecodable(LogoutResponseDto.self)
            .handlingError()
    }
}
