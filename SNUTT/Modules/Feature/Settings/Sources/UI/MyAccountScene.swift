//
//  MyAccountScene.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

struct MyAccountScene: View {
    @State private(set) var viewModel: MyAccountViewModel
    @State private var isNicknameCopiedAlertPresented = false
    @State private var isSignOutAlertPresented = false
    @Binding var path: [Destination]

    @Environment(\.errorAlertHandler) private var errorAlertHandler

    public init(_ path: Binding<[Destination]>) {
        viewModel = .init()
        _path = path
    }

    var body: some View {
        List {
            Section {
                SettingsListCell(menu: MyAccount.changeNickname(nickname: viewModel.userNickname), path: $path)
                SettingsListCell(menu: MyAccount.copyNickname, path: $path) {
                    UIPasteboard.general.string = viewModel.userNickname
                    isNicknameCopiedAlertPresented = true
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
    MyAccountScene(.constant([]))
}
