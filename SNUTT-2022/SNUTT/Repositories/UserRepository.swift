//
//  UserRepository.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/09.
//

import Alamofire
import Foundation

protocol UserRepositoryProtocol {
    var userLocalId: String? { get }
    var token: String? { get }
    var fbName: String? { get }
    func cache(token: String)
    func cache(user: UserDto)
    func getUser() async throws -> UserDto
}

class UserRepository: UserRepositoryProtocol {
    private let session: Session

    init(session: Session) {
        self.session = session
    }
    
    var userLocalId: String? {
        local.userLocalId
    }
    
    var token: String? {
        local.token
    }

    var fbName: String? {
        local.userFBName
    }
    
    func cache(token: String) {
        local.token = token
    }
    
    func cache(user: UserDto) {
        local.userLocalId = user.local_id
        local.userFBName = user.fb_name
    }
    
    func getUser() async throws -> UserDto {
        let data = try await session
            .request(UserRouter.getUser)
            .serializingDecodable(UserDto.self)
            .handlingError()
        return data
    }
}
