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
                SettingsMenu(Settings.accountSetting) {
                    AccountSettingScene(viewModel: AccountSettingViewModel(container: viewModel.container))
                }
                SettingsMenu(Settings.timetableSetting) {
                    TimetableSettingScene()
                }
            }
            Section {
                SettingsMenu(Settings.showVersionInfo)
            }
            Section {
                SettingsMenu(Settings.developerInfo) {
                    DeveloperInfoView()
                }
                SettingsMenu(Settings.userSupport) {
                    UserSupportScene()
                }
            }
            Section {
                SettingsMenu(Settings.licenseInfo) {
                    LicenseView()
                }
                SettingsMenu(Settings.termsOfService) {
                    TermsOfServiceView()
                }
                SettingsMenu(Settings.privacyPolicy) {
                    PrivacyPolicyView()
                }
            }
            Section {
                SettingsMenu(Settings.logout, destructive: true)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)

        let _ = debugChanges()
    }
}

#if DEBUG
    struct SettingScene_Previews: PreviewProvider {
        static var previews: some View {
            NavigationView {
                TabView {
                    SettingScene(viewModel: .init(container: .preview))
                }
            }
        }
    }
#endif
