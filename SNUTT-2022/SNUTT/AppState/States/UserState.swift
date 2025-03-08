//
//  UserState.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/25.
//

import FirebaseAnalytics
import SwiftUI

class UserState {
    @Published var accessToken: String?
    @Published var current: User?
    @Published var socialProvider: SocialProvider?

    /// Primary key of User. Required to logout. This is not `localId`.
    var userId: String? {
        didSet {
            Analytics.setUserID(userId)
        }
    }
}
