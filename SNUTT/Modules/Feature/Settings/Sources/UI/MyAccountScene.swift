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

    @Environment(\.errorAlertHandler) private var errorAlertHandler

    public init() {
        viewModel = .init()
    }

    var body: some View {
        List {
            Section {
                SettingsNavigationItem(
                    title: SettingsStrings.accountNicknameChange,
                    detail: "와플#7777",
                    destination: ColorView(color: .red)
                )
                SettingsMenuItem(
                    title: SettingsStrings.accountNicknameCopy,
                    detailImage: Image(systemName: "square.on.square")
                ) {
                    UIPasteboard.general.string = "닉네임"
                    isNicknameCopiedAlertPresented = true
                }
            }

            Section {
                if true {
                    SettingsMenuItem(
                        title: SettingsStrings.accountId,
                        detail: "snutt"
                    )
                    SettingsNavigationItem(
                        title: SettingsStrings.accountPasswordChange,
                        destination: ColorView(color: .yellow)
                    )
                } else {
                    SettingsNavigationItem(
                        title: SettingsStrings.accountIdAdd,
                        destination: ColorView(color: .orange)
                    )
                }
            }

            Section {
                SettingsNavigationItem(
                    title: SettingsStrings.accountSns,
                    destination: ColorView(color: .green)
                )
            }

            Section {
                SettingsMenuItem(
                    title: SettingsStrings.accountEmail,
                    detail: "snutt@wafflestudio.com"
                )
            }

            Section {
                SettingsMenuItem(
                    title: SettingsStrings.accountSignOut,
                    destructive: true
                ) {
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
    MyAccountScene()
}
