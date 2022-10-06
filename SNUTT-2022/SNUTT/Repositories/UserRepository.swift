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
    func connectFacebook(fbId: String, fbToken: String) async throws -> TokenResponseDto
    func disconnectFacebook() async throws -> TokenResponseDto
    func changePassword(from oldPassword: String, to newPassword: String) async throws -> TokenResponseDto
    func addLocalId(id: String, password: String) async throws -> TokenResponseDto
    func deleteUser() async throws
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

    func connectFacebook(fbId: String, fbToken: String) async throws -> TokenResponseDto {
        return try await session
            .request(UserRouter.connectFacebook(id: fbId, token: fbToken))
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

    func addLocalId(id: String, password: String) async throws -> TokenResponseDto {
        return try await session
            .request(UserRouter.addLocalId(id: id, password: password))
            .serializingDecodable(TokenResponseDto.self)
            .handlingError()
    }

    func deleteUser() async throws {
        let _ = try await session
            .request(UserRouter.deleteUser)
            .serializingString()
            .handlingError()
    }
}
