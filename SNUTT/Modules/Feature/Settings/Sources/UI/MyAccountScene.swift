//
//  MyAccountScene.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

struct MyAccountScene: View {
    @Bindable var viewModel: MyAccountViewModel
    @Binding var path: [Destination]
    @State private var isNicknameCopiedAlertPresented = false
    @State private var isSignOutAlertPresented = false

    @Environment(\.errorAlertHandler) private var errorAlertHandler

    var body: some View {
        List {
            Section {
                switch viewModel.loadState {
                case .loaded(let user):
                    SettingsListCell(menu: MyAccount.changeNickname(nickname: user.nickname.description), path: $path)
                    SettingsListCell(menu: MyAccount.copyNickname, path: $path) {
                        UIPasteboard.general.string = user.nickname.description
                        isNicknameCopiedAlertPresented = true
                    }
                case .loading:
                    Text("-")
                }
            }

            Section {
                if true {
                    SettingsListCell(menu: MyAccount.displayId(id: "snutt"), path: $path)
                    SettingsListCell(menu: MyAccount.changePassword, path: $path)
                } else {
                    SettingsListCell(menu: MyAccount.addId, path: $path)
                }
            }

            Section {
                SettingsListCell(menu: MyAccount.snsConnection, path: $path)
            }

            Section {
                SettingsListCell(menu: MyAccount.displayEmail(email: "snutt@wafflestudio.com"), path: $path)
            }

            Section {
                SettingsListCell(menu: MyAccount.signOut, path: $path) {
                    isSignOutAlertPresented = true
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle(SettingsStrings.account)
        .alert(
            SettingsStrings.accountNicknameCopyAlert,
            isPresented: $isNicknameCopiedAlertPresented
        ) {}
        .alert(
            SettingsStrings.accountSignOutAlert,
            isPresented: $isSignOutAlertPresented
        ) {
            Button(SharedUIComponentsStrings.alertDelete, role: .destructive) {
                Task {
                    await deleteAccount()
                }
            }
            Button(SharedUIComponentsStrings.alertCancel, role: .cancel) {}
        }
        .task {}
    }
}

extension MyAccountScene {
    private func deleteAccount() async {
        await errorAlertHandler.withAlert {
            try await viewModel.deleteAccount()
        }
    }
}

#Preview {
    MyAccountScene(viewModel: .init(), path: .constant([]))
}
