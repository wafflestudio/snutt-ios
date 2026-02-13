//
//  FriendsUserDefaultsRepository.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies
import DependenciesUtility
import Foundation

struct FriendsUserDefaultsRepository: FriendsLocalRepository {
    @Dependency(\.userDefaults) private var userDefaults

    func loadSelectedFriendID() -> String? {
        userDefaults.string(forKey: Keys.selectedFriendID.rawValue)
    }

    func storeSelectedFriendID(_ friendID: String?) {
        if let friendID {
            userDefaults.set(friendID, forKey: Keys.selectedFriendID.rawValue)
        } else {
            userDefaults.removeValue(forKey: Keys.selectedFriendID.rawValue)
        }
    }

    private enum Keys: String {
        case selectedFriendID
    }
}
