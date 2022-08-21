//
//  SettingScene.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/24.
//

import SwiftUI

struct SettingScene: View {
    let viewModel: SettingViewModel

    var body: some View {
        List {
            Section {
                Menu(Settings.accountSetting) {
                    AccountSettingScene(viewModel: AccountSettingViewModel(container: viewModel.container))
                }
                Menu(Settings.timetableSetting) {
                    TimetableSettingScene()
                }
            }
            Section {
                Menu(Settings.showVersionInfo)
            }
            Section {
                Menu(Settings.developerInfo) {
                    DeveloperInfoScene()
                }
                Menu(Settings.userSupport) {
                    UserSupportScene()
                }
            }
            Section {
                Menu(Settings.licenseInfo) {
                    LicenseScene()
                }
                Menu(Settings.termsOfService) {
                    TermsOfServiceScene()
                }
                Menu(Settings.privacyPolicy) {
                    PrivacyPolicyScene()
                }
            }
            Section {
                Menu(Settings.logout, destructive: true)
            }
        }
        .listStyle(.grouped)
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)

        let _ = debugChanges()
    }
}

struct SettingScene_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TabView {
                SettingScene(viewModel: .init(container: .preview))
            }
        }
    }
}
