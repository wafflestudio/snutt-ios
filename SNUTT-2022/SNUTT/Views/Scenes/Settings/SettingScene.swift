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

    init(viewModel: SettingViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        List {
            Section {
                SettingsLinkItem(title: "내 계정", leadingImage: Image("account.person"), detail: viewModel.currentUser?.nickname.fullString) {
                    AccountSettingScene(viewModel: .init(container: viewModel.container))
                }
                .padding(.vertical, 12)
            }

            Section {
                SettingsLinkItem(title: "색상 모드", detail: viewModel.currentColorSchemeSelection.rawValue) {
                    ColorSchemeSettingScene(selection: $viewModel.currentColorSchemeSelection)
                }

                SettingsLinkItem(title: "시간표 설정") {
                    TimetableSettingScene(viewModel: .init(container: viewModel.container))
                }

                SettingsLinkItem(title: "시간표 테마") {
                    ThemeSettingScene(viewModel:
                        .init(container: viewModel.container))
                        .onDisappear {
                            viewModel.closeBottomSheet()
                        }
                }
            } header: {
                Text("디스플레이")
            }

            Section {
                SettingsLinkItem(title: "빈자리 알림", isActive: $viewModel.routingState.pushToVacancy) {
                    VacancyScene(viewModel: .init(container: viewModel.container))
                }
            } header: {
                Text("서비스")
            }

            Section {
                SettingsTextItem(title: "버전 정보", detail: viewModel.versionString)

                SettingsLinkItem(title: "개발자 정보") {
                    DeveloperInfoView()
                }
            } header: {
                Text("정보 및 제안")
            }

            Section {
                SettingsLinkItem(title: "개발자 괴롭히기") {
                    UserSupportView(email: viewModel.userEmail, sendFeedback: viewModel.sendFeedback(email:message:))
                }
            }

            Section {
                SettingsLinkItem(title: "오픈소스 라이선스") {
                    LicenseView()
                }
                SettingsLinkItem(title: "서비스 약관") {
                    TermsOfServiceView()
                }
                SettingsLinkItem(title: "개인정보처리방침") {
                    PrivacyPolicyView()
                }
            }

            #if DEBUG
                Section("디버그 메뉴") {
                    SettingsLinkItem(title: "네트워크 로그") {
                        NetworkLogListScene(viewModel: .init(container: viewModel.container))
                    }
                    SettingsLinkItem(title: "Base URL 변경") {
                        ChangeBaseURLView()
                    }
                }
            #endif

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
        .environment(\.defaultMinListHeaderHeight, 1)
        .environment(\.hasNewBadgeClosure) { name in viewModel.hasNewBadge(settingName: name) }
        .listStyle(.insetGrouped)
        .navigationTitle("더보기")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.fetchUser()
            await viewModel.getThemeList()
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
