//
//  ConfigDto.swift
//  SNUTT
//
//  Created by 박신홍 on 2023/08/05.
//

import Foundation

struct ConfigsDto: Codable {
    let vacancyNotificationBanner: VacancyNotificationBannerDto?
    let vacancySugangSnuUrl: VacancySugangSnuUrlDto?
    let settingsBadge: SettingsBadgeDto?
    let reactNativeBundleFriends: ReactNativeBundleFriendsDto?
    let notices: NoticeViewInfoDto?
    let disableMapFeature: Bool?
}

extension ConfigsDto {
    struct VacancyNotificationBannerDto: Codable {
        let visible: Bool
    }

    struct VacancySugangSnuUrlDto: Codable {
        let url: URL
    }

    struct SettingsBadgeDto: Codable {
        let new: [String]
    }

    struct ReactNativeBundleFriendsDto: Codable {
        let src: [String: String]

        var iosBundleSrc: String? {
            src["ios"]
        }
    }
    
    struct NoticeViewInfoDto: Codable {
        let title: String
        let content: String
        let visible: Bool
    }
}
