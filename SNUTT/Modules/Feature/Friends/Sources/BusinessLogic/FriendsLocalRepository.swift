//
//  FriendsLocalRepository.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Foundation
import Spyable

@Spyable
public protocol FriendsLocalRepository: Sendable {
    func loadSelectedFriendID() -> String?
    func storeSelectedFriendID(_ friendID: String?)
}
