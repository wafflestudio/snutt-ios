//
//  UserState.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/25.
//

import SwiftUI

class UserState: ObservableObject {
    var token: String?
    var apiKey: String?
    @Published var current: User?
}
