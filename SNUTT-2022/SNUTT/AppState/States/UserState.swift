//
//  UserState.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/25.
//

import SwiftUI

class UserState: ObservableObject {
    @Published var accessToken: String?
    @Published var current: User?

    /// Primary key of User. Required to logout. This is not `localId`.
    var userId: String?
}
