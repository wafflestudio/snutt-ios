//
//  PushDto.swift
//  SNUTT
//
//  Created by 이채민 on 5/10/25.
//

import Foundation

struct PushDto: Codable {
    let pushPreferences: [PushPreferenceDto]
}

struct PushPreferenceDto: Codable {
    let type: String
    let isEnabled: Bool
}
