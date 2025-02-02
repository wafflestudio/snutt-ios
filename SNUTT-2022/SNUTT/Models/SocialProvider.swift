//
//  SocialProvider.swift
//  SNUTT
//
//  Created by 이채민 on 10/25/24.
//

import Foundation

struct SocialProvider {
    let local: Bool
    let facebook: Bool
    let google: Bool
    let kakao: Bool
    let apple: Bool
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
