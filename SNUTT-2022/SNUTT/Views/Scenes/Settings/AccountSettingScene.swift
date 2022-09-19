//
//  AccountSettingScene.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/01.
//

import SwiftUI

struct AccountSettingScene: View {
    @ObservedObject var viewModel: AccountSettingViewModel

    private var menuList: [[SettingsMenu]] {
        viewModel.menuList.map { $0.map { convertToView(menu: $0) }}
    }

    var body: some View {
        List(menuList, id: \.self) { section in
            Section {
                ForEach(section, id: \.self) { menu in
                    menu
                }
            }
        }
        .onLoad {
            await viewModel.fetchUser()
        }
        .listStyle(.grouped)
        .navigationTitle("계정 관리")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension AccountSettingScene {
    private func convertToView(menu: AccountSettings) -> SettingsMenu {
        // TODO: implement destination of each menu
        switch menu {
        case .addLocalId:
            return SettingsMenu(AccountSettings.addLocalId) {
                AddLocalIdScene(viewModel: AddLocalIdViewModel(container: viewModel.container))
            }
        case .showLocalId:
            return SettingsMenu(AccountSettings.showLocalId,
                                content: viewModel.currentUser?.localId ?? "(없음)")
        case .changePassword:
            return SettingsMenu(AccountSettings.changePassword)
        case .makeFbConnection:
            return SettingsMenu(AccountSettings.makeFbConnection)
        case .showFbName:
            return SettingsMenu(AccountSettings.showFbName,
                                content: viewModel.currentUser?.fbName ?? "(없음)")
        case .deleteFbConnection:
            return SettingsMenu(AccountSettings.deleteFbConnection)
        case .showEmail:
            return SettingsMenu(AccountSettings.showEmail,
                                content: viewModel.currentUser?.email ?? "(없음)")
        case .deleteAccount:
            return SettingsMenu(AccountSettings.deleteAccount, destructive: true) {
                viewModel.deleteUser()
            }
        }
    }
}

struct AccountSettingScene_Previews: PreviewProvider {
    static var previews: some View {
        AccountSettingScene(viewModel: .init(container: .preview))
    }
}
