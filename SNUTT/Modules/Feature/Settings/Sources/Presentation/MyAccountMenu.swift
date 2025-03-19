//
//  MyAccountMenu.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Foundation
import SwiftUI

enum MyAccount: MenuItem {
    case changeNickname(nickname: String)
    case copyNickname
    case displayId(id: String)
    case changePassword
    case addId
    case snsConnection
    case displayEmail(email: String)
    case signOut

    var title: String {
        switch self {
        case .changeNickname:
            SettingsStrings.accountNicknameChange
        case .copyNickname:
            SettingsStrings.accountNicknameCopy
        case .displayId:
            SettingsStrings.accountId
        case .changePassword:
            SettingsStrings.accountPasswordChange
        case .addId:
            SettingsStrings.accountIdAdd
        case .snsConnection:
            SettingsStrings.accountSns
        case .displayEmail:
            SettingsStrings.accountEmail
        case .signOut:
            SettingsStrings.accountSignOut
        }
    }

    var leadingImage: Image? {
        nil
    }

    var detail: String? {
        switch self {
        case let .changeNickname(nickname): nickname
        case let .displayId(id): id
        case let .displayEmail(email): email
        default: nil
        }
    }

    var detailImage: Image? {
        switch self {
        case .copyNickname:
            Image(systemName: "square.on.square")
        default: nil
        }
    }

    var destructive: Bool {
        switch self {
        case .signOut: true
        default: false
        }
    }

    var shouldNavigate: Bool {
        switch self {
        case .copyNickname, .displayEmail, .signOut: false
        default: true
        }
    }
}
