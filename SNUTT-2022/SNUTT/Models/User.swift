//
//  User.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/25.
//

import SwiftUI

class User: ObservableObject {
    var token: String?
    var userId: String?
    var registeredFCMToken: String?
}
