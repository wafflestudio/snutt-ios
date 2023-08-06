//
//  ConfigDto.swift
//  SNUTT
//
//  Created by 박신홍 on 2023/08/05.
//

import Foundation

struct ConfigsDto: Codable {
    let vacancyNotificationBanner: VacancyNotificationBannerDto
}

extension ConfigsDto {
    struct VacancyNotificationBannerDto: Codable {
        let visible: Bool
    }
}
