//
//  SettingScene.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/24.
//

import SwiftUI

struct SettingScene: View {
    @ObservedObject var viewModel: SettingViewModel
    @State private var pushToNotiScene = false
    @State private var isLogoutAlertPresented: Bool = false

    init(viewModel: SettingViewModel) {
        self.viewModel = viewModel
    }

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

            #if FEATURE_RN_FRIENDS
            Section {
                SettingsLinkItem(title: "친구 (DEV)") {
                    FriendsScene(viewModel: .init(container: viewModel.container))
                }
            }
            #endif

            Section {
                SettingsLinkItem(title: "빈자리 알림", isActive: $viewModel.routingState.pushToVacancy) {
                    VacancyScene(viewModel: .init(container: viewModel.container))
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
                SettingsLinkItem(title: "개인정보 처리방침") {
                    PrivacyPolicyView()
                }
            }

            #if DEBUG
                Section("디버그 메뉴") {
                    SettingsLinkItem(title: "네트워크 로그") {
                        NetworkLogListScene(viewModel: .init(container: viewModel.container))
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
        .environment(\.hasNewBadgeClosure) { name in viewModel.hasNewBadge(settingName: name) }
        .listStyle(.insetGrouped)
        .navigationTitle("더보기")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavBarButton(imageName: "nav.alarm.off") {
                    pushToNotiScene = true
                }
                .circleBadge(condition: viewModel.unreadCount > 0)
            }
        }
        .background {
            NavigationLink(destination: NotificationList(notifications: viewModel.notifications,
                                                         initialFetch: viewModel.fetchInitialNotifications,
                                                         fetchMore: viewModel.fetchMoreNotifications), isActive: $pushToNotiScene) { EmptyView() }
        }
        .background {
            NavigationLink(destination: NotificationList(notifications: viewModel.notifications,
                                                         initialFetch: viewModel.fetchInitialNotifications,
                                                         fetchMore: viewModel.fetchMoreNotifications), isActive: $viewModel.routingState.pushToNotification) { EmptyView() }
        }
        .task {
            await viewModel.fetchUser()
            await viewModel.fetchInitialNotifications(updateLastRead: false)
            await viewModel.fetchNotificationsCount()
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
