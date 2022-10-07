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
                SettingsLinkItem(title: "계정 관리") {
                    AccountSettingScene(viewModel: .init(container: viewModel.container))
                }

                SettingsLinkItem(title: "시간표 설정") {
                    TimetableSettingScene(viewModel: .init(container: viewModel.container))
                }
            }

            Section {
                SettingsTextItem(title: "버전 정보", detail: viewModel.versionString)
            }

            Section {
                SettingsLinkItem(title: "개발자 정보") {
                    DeveloperInfoView()
                }
                SettingsLinkItem(title: "개발자 괴롭히기") {
                    UserSupportScene()
                }
            }

            Section {
                SettingsLinkItem(title: "라이센스 정보") {
                    LicenseView()
                }
                SettingsLinkItem(title: "서비스 약관") {
                    TermsOfServiceView()
                }
                SettingsLinkItem(title: "개인정보 처리방침") {
                    PrivacyPolicyView()
                }
            }

            Section {
                SettingsButtonItem(title: "로그아웃", role: .destructive) {
                    Task {
                        await viewModel.logout()
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("설정")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchUser()
        }

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
