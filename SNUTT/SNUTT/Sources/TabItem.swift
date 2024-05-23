//
//  TabItem.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import UIKit
import SharedUIComponents

enum TabItem: CaseIterable, SharedUIComponents.TabItem {
    case timetable
    case search
    case review
    case friends
    case settings

    func image(isSelected: Bool) -> UIImage {
        let snuttImage = switch self {
        case .timetable:
            isSelected ? SNUTTAsset.Assets.tabTimetableOn : SNUTTAsset.Assets.tabTimetableOff
        case .search:
            isSelected ? SNUTTAsset.Assets.tabSearchOn : SNUTTAsset.Assets.tabSearchOff
        case .review:
            isSelected ? SNUTTAsset.Assets.tabReviewOn : SNUTTAsset.Assets.tabReviewOff
        case .friends:
            isSelected ? SNUTTAsset.Assets.tabFriendsOn : SNUTTAsset.Assets.tabFriendsOff
        case .settings:
            isSelected ? SNUTTAsset.Assets.tabSettingsOn : SNUTTAsset.Assets.tabSettingsOff
        }
        return snuttImage.image
    }
}
