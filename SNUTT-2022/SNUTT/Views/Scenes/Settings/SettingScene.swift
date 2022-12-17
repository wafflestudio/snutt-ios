//
//  SettingScene.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/24.
//

import SwiftUI

struct SettingScene: View {
    @ObservedObject var viewModel: SettingViewModel
    @State private var isLogoutAlertPresented: Bool = false

    var body: some View {
        List {
            Section {
                SettingsLinkItem(title: "계정 관리") {
                    AccountSettingScene(viewModel: .init(container: viewModel.container))
                }

                SettingsLinkItem(title: "시간표 설정") {
                    TimetableSettingScene(viewModel: .init(container: viewModel.container))
                }

                SettingsLinkItem(title: "색상 모드", detail: viewModel.currentColorSchemeSelection.rawValue) {
                    ColorSchemeSettingScene(selection: $viewModel.currentColorSchemeSelection)
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
                    UserSupportView(sendFeedback: viewModel.sendFeedback(email:message:))
                }
            }

            Section {
                SettingsLinkItem(title: "오픈소스 라이선스") {
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
                    isLogoutAlertPresented = true
                }.alert("로그아웃 하시겠습니까?", isPresented: $isLogoutAlertPresented) {
                    Button("로그아웃", role: .destructive) {
                        Task {
                            await viewModel.logout()
                        }
                    }
                    Button("취소", role: .cancel) {}
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

enum ColorSchemeSelection: String, CaseIterable {
    case automatic = "자동"
    case light = "라이트 모드"
    case dark = "다크 모드"
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
