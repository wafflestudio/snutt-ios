//
//  Configs.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Foundation

public struct ConfigsModel: Codable, Sendable {
    public let vacancyNotificationBanner: VacancyNotificationBanner?
    public let vacancySugangSnuUrl: VacancySugangSnuUrl?
    public let settingsBadge: SettingsBadge?
    public let reactNativeBundleFriends: ReactNativeBundleFriends?
    public let notice: NoticeViewInfo?
    public let disableMapFeature: Bool?

    public static var empty: ConfigsModel {
        .init(
            vacancyNotificationBanner: nil,
            vacancySugangSnuUrl: nil,
            settingsBadge: nil,
            reactNativeBundleFriends: nil,
            notice: nil,
            disableMapFeature: nil
        )
    }
}

extension ConfigsModel {
    public struct VacancyNotificationBanner: Codable, Sendable {
        public let visible: Bool
    }

    public struct VacancySugangSnuUrl: Codable, Sendable {
        public let url: URL
    }

    public struct SettingsBadge: Codable, Sendable {
        public let new: [String]
    }

    public struct ReactNativeBundleFriends: Codable, Sendable {
        public let src: [String: String]

        public var iosBundleSrc: String? {
            src["ios"]
        }
    }

    public struct NoticeViewInfo: Codable, Sendable {
        let title: String
        let content: String
        let visible: Bool
    }
}
