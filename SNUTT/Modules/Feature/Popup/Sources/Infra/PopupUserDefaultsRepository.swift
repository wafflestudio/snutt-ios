//
//  PopupUserDefaultsRepository.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Dependencies
import DependenciesUtility

struct PopupUserDefaultsRepository: PopupLocalRepository {
    @Dependency(\.userDefaults) private var userDefaults

    func fetchPopups() -> [LocalPopup] {
        userDefaults[\.popups]
    }

    func storePopups(_ popups: [LocalPopup]) {
        userDefaults[\.popups] = popups
    }
}

extension UserDefaultsEntryDefinitions {
    var popups: UserDefaultsEntry<[LocalPopup]> {
        .init(key: "popups", defaultValue: [])
    }
}
