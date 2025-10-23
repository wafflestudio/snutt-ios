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
    @State private var isNicknameCopiedAlertPresented = false
    @State private var isSignOutAlertPresented = false

    @Environment(\.errorAlertHandler) private var errorAlertHandler

    var body: some View {
        List {
            Section {
                switch viewModel.loadState {
                case .loaded(let user):
                    SettingsNavigationLink(
                        title: SettingsStrings.accountNicknameChange,
                        value: MyAccountPathType.changeNickname,
                        detail: user.nickname.description
                    )
                    SettingsMenuButton(
                        title: SettingsStrings.accountNicknameCopy,
                        onTap: {
                            UIPasteboard.general.string = user.nickname.description
                            isNicknameCopiedAlertPresented = true
                        },
                        detailImage: Image(systemName: "square.on.square")
                    )
                case .loading:
                    Text("-")
                }
            }

            Section {
                switch viewModel.loadState {
                case .loaded(let user):
                    if let localID = user.localID {
                        SettingsMenuButton(
                            title: SettingsStrings.accountId,
                            detail: localID
                        )
                        SettingsNavigationLink(
                            title: SettingsStrings.accountPasswordChange,
                            value: MyAccountPathType.changePassword
                        )
                    } else {
                        SettingsNavigationLink(
                            title: SettingsStrings.accountIdAdd,
                            value: MyAccountPathType.addId
                        )
                    }
                case .loading:
                    Text("-")
                }
            }

            Section {
                SettingsNavigationLink(
                    title: SettingsStrings.accountSns,
                    value: MyAccountPathType.snsConnection
                )
            }

            Section {
                switch viewModel.loadState {
                case .loaded(let user):
                    SettingsMenuButton(
                        title: SettingsStrings.accountEmail,
                        detail: user.email ?? "(없음)"
                    )
                case .loading:
                    Text("-")
                }
            }

            Section {
                SettingsMenuButton(
                    title: SettingsStrings.accountSignOut,
                    onTap: { isSignOutAlertPresented = true },
                    destructive: true
                )
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
    MyAccountScene(viewModel: .init())
}
