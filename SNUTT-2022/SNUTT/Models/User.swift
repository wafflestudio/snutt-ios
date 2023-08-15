//
//  User.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/18.
//

import Foundation

struct User {
    let isAdmin: Bool
    var regDate: String
    var notificationCheckedAt: String?
    var email: String?
    var localId: String?
    var fbName: String?
    var nickname: Nickname
}

extension User {
    init(from dto: UserDto) {
        isAdmin = dto.isAdmin
        regDate = dto.regDate
        notificationCheckedAt = dto.notificationCheckedAt
        email = dto.email
        localId = dto.localId
        fbName = dto.fbName
        nickname = .init(from: dto.nickname)
    }
}

struct Nickname {
    var name: String
    var tag: String
}

extension Nickname {
    init(from dto: NicknameDto) {
        name = dto.nickname
        tag = dto.tag
    }
}
