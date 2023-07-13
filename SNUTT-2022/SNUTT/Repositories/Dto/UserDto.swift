//
//  UserDto.swift
//  SNUTT
//
//  Created by 최유림 on 2022/09/19.
//

import Foundation

struct UserDto: Codable {
    var local_id: String?
    var fb_name: String?
    var email: String?
}

extension UserDto {
    init(from model: User) {
        local_id = model.localId
        fb_name = model.fbName
        email = model.email
    }
}

struct SendVerificationCodeDto: Decodable {
    let message: String
}

struct EmailVerifiedDto: Decodable {
    let is_email_verified: Bool
}
