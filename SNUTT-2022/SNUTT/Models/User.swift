//
//  User.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/18.
//

import Foundation

struct User {
    var localId: String?
    var fbName: String?
    var email: String?
}

extension User {
    init(from dto: UserDto) {
        localId = dto.local_id
        fbName = dto.fb_name
        email = dto.email
    }
}

struct UserDto: Codable {
    var local_id: String?
    var fb_name: String?
    var email: String?
}

extension UserDto {
    init(with model: User) {
        local_id = model.localId
        fb_name = model.fbName
        email = model.email
    }
}
