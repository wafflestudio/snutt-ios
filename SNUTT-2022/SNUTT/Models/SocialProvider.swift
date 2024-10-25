//
//  SocialProvider.swift
//  SNUTT
//
//  Created by 이채민 on 10/25/24.
//

import Foundation

struct SocialProvider {
    var local: Bool
    var facebook: Bool
    var google: Bool
    var kakao: Bool
    var apple: Bool
}

extension SocialProvider {
    init(from dto: SocialProviderDto) {
        local = dto.local
        facebook = dto.facebook
        google = dto.google
        kakao = dto.kakao
        apple = dto.apple
    }
}
