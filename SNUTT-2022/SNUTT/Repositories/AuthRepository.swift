//
//  AuthRepository.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/24.
//

import Alamofire
import Foundation

protocol AuthRepositoryProtocol {
    func registerWithLocalId(localId: String, localPassword: String, email: String) async throws -> LoginResponseDto
    func loginWithApple(appleToken: String) async throws -> LoginResponseDto
    func loginWithFacebook(fbId: String, fbToken: String) async throws -> LoginResponseDto
    func loginWithLocalId(localId: String, localPassword: String) async throws -> LoginResponseDto
    func findId(email: String) async throws -> SendLocalIdDto
    func checkLinkedEmail(localId: String) async throws -> CheckLinkedEmailDto
    func sendVerificationCode(email: String) async throws
    func checkVerificationCode(localId: String, code: String) async throws
    func resetPassword(localId: String, password: String) async throws
    func logout(userId: String, fcmToken: String) async throws -> LogoutResponseDto
}

class AuthRepository: AuthRepositoryProtocol {
    private let session: Session

    init(session: Session) {
        self.session = session
    }

    func registerWithLocalId(localId: String, localPassword: String, email: String) async throws -> LoginResponseDto {
        return try await session
            .request(AuthRouter.registerWithLocalId(localId: localId, localPassword: localPassword, email: email))
            .serializingDecodable(LoginResponseDto.self)
            .handlingError()
    }

    func loginWithApple(appleToken: String) async throws -> LoginResponseDto {
        return try await session
            .request(AuthRouter.loginWithApple(appleToken: appleToken))
            .serializingDecodable(LoginResponseDto.self)
            .handlingError()
    }

    func loginWithFacebook(fbId: String, fbToken: String) async throws -> LoginResponseDto {
        return try await session
            .request(AuthRouter.loginWithFacebook(fbId: fbId, fbToken: fbToken))
            .serializingDecodable(LoginResponseDto.self)
            .handlingError()
    }

    func loginWithLocalId(localId: String, localPassword: String) async throws -> LoginResponseDto {
        return try await session
            .request(AuthRouter.loginWithLocalId(localId: localId, localPassword: localPassword))
            .serializingDecodable(LoginResponseDto.self)
            .handlingError()
    }
    
    func findId(email: String) async throws -> SendLocalIdDto {
        return try await session
            .request(AuthRouter.findId(email: email))
            .serializingDecodable(SendLocalIdDto.self)
            .handlingError()
    }
    
    func checkLinkedEmail(localId: String) async throws -> CheckLinkedEmailDto {
        return try await session
            .request(AuthRouter.checkLinkedEmail(localId: localId))
            .serializingDecodable(CheckLinkedEmailDto.self)
            .handlingError()
    }
    
    func sendVerificationCode(email: String) async throws {
        let _ = try await session
            .request(AuthRouter.sendVerificationCode(email: email))
            .serializingString()
            .handlingError()
    }
    
    func checkVerificationCode(localId: String, code: String) async throws {
        let _ = try await session
            .request(AuthRouter.checkVerificationCode(localId: localId, code: code))
            .serializingString()
            .handlingError()
    }
    
    func resetPassword(localId: String, password: String) async throws {
        let _ = try await session
            .request(AuthRouter.resetPassword(localId: localId, password: password))
            .serializingString()
            .handlingError()
    }

    func logout(userId: String, fcmToken: String) async throws -> LogoutResponseDto {
        return try await session
            .request(AuthRouter.logout(userId: userId, fcmToken: fcmToken))
            .serializingDecodable(LogoutResponseDto.self)
            .handlingError()
    }
}
