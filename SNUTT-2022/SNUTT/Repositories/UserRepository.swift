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
}

class UserRepository: UserRepositoryProtocol {
    private let session: Session

    init(session: Session) {
        self.session = session
    }

    func fetchUser() async throws -> UserDto {
        let data = try await session
            .request(UserRouter.getUser)
            .serializingDecodable(UserDto.self)
            .handlingError()
        return data
    }
}
