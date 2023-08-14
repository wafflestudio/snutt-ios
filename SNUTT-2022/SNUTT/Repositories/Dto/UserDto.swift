//
//  UserDto.swift
//  SNUTT
//
//  Created by 최유림 on 2022/09/19.
//

import Foundation


// MARK: User
struct UserDto: Codable {
    let isAdmin: Bool
    var regDate: String
    var notificationCheckedAt: String?
    var email: String?
    var localId: String?
    var fbName: String?
    var nickname: NicknameDto
}

extension UserDto {
    init(from model: User) {
        isAdmin = model.isAdmin
        regDate = model.regDate
        notificationCheckedAt = model.notificationCheckedAt
        email = model.email
        localId = model.localId
        fbName = model.fbName
        nickname = .init(from: model.nickname)
    }
}

// MARK: Nickname
struct NicknameDto: Codable {
    var nickname: String
    var tag: String
}

extension NicknameDto {
    init(from model: Nickname) {
        nickname = model.name
        tag = model.tag
    }
}

struct SendVerificationCodeDto: Decodable {
    let message: String
}

struct EmailVerifiedDto: Decodable {
    let is_email_verified: Bool
}
