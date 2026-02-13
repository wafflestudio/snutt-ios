//
//  MyAccountDetails.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

struct MyAccountDetails: View {
    let menuItem: MyAccountPathType
    let viewModel: MyAccountViewModel

    @Environment(\.authUIProvider) private var authUIProvider

    var body: some View {
        switch menuItem {
        case .changeNickname:
            ChangeNicknameView(viewModel: viewModel)
        case .addId:
            authUIProvider.attachLocalIDScene { localID, localPassword in
                try await viewModel.attachLocalID(localID: localID, localPassword: localPassword)
            }
        case .changePassword:
            authUIProvider.changePasswordScene { oldPassword, newPassword in
                try await viewModel.changePassword(oldPassword: oldPassword, newPassword: newPassword)
            }
        case .snsConnection:
            AnyView(authUIProvider.socialLoginSettingsScene())
                .navigationTitle(SettingsStrings.accountSns)
        }
    }
}
