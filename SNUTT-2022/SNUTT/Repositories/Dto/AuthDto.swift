//
//  AuthDto.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/02.
//

import Foundation

struct LoginResponseDto: Codable {
    let token: String
    let user_id: String
}

struct LogoutResponseDto: Codable {
    let message: String // typically "ok"
}

struct TokenResponseDto: Codable {
    let token: String
}

struct DeviceResponseDto: Codable {
    let message: String
}
