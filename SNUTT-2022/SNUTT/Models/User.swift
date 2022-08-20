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
    init(from data: UserDto) {
        localId = data.local_id
        fbName = data.fb_name
        email = data.email
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
