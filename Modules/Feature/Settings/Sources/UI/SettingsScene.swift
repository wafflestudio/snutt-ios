//
//  SettingsScene.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import AppReviewPromptInterface
import Dependencies
import SharedUIComponents
import SwiftUI
import VacancyInterface

public struct SettingsScene: View {
    @State private(set) var viewModel: SettingsViewModel = .init()
    @AppStorage(AppStorageKeys.preferredColorScheme) private var selectedColorScheme: ColorSchemeSelection = .system
    @Dependency(\.appReviewService) private var appReviewService
    @Environment(\.errorAlertHandler) private var errorAlertHandler

    public init() {}

    public var body: some View {
        NavigationStack(path: $viewModel.path) {
            List {
                Section {
                    SettingsNavigationLink(
                        title: SettingsStrings.account,
                        value: SettingsPathType.myAccount,
                        leadingImage: SettingsAsset.person.swiftUIImage,
                        detail: viewModel.myAccountViewModel.titleDescription
                    )
                    .padding(.vertical, 12)
                }

                Section {
                    SettingsNavigationLink(
                        title: SettingsStrings.notificationInbox,
                        value: SettingsPathType.notificationInbox,
                        showRedDot: viewModel.unreadNotificationCount > 0
                    )
                    SettingsNavigationLink(
                        title: SettingsStrings.servicePushNotification,
                        value: SettingsPathType.pushNotificationSettings
                    )
                } header: {
                    FormSectionHeader(SettingsStrings.notification)
                }

                Section {
                    SettingsNavigationLink(
                        title: SettingsStrings.displayColorMode,
                        value: SettingsPathType.appearance,
                        detail: selectedColorScheme.localizedString
                    )
                    SettingsNavigationLink(
                        title: SettingsStrings.displayTable,
                        value: SettingsPathType.timetableSettings
                    )
                    SettingsNavigationLink(
                        title: SettingsStrings.displayTheme,
                        value: SettingsPathType.timetableTheme
                    )
                } header: {
                    FormSectionHeader(SettingsStrings.display)
                }

                Section {
                    SettingsNavigationLink(
                        title: SettingsStrings.serviceVacancy,
                        value: SettingsPathType.vacancyNotification
                    )
                    SettingsNavigationLink(
                        title: SettingsStrings.serviceLectureReminder,
                        value: SettingsPathType.lectureReminder
                    )
                    #if FEATURE_LECTURE_DIARY
                    SettingsNavigationLink(
                        title: SettingsStrings.serviceLectureDiary,
                        value: SettingsPathType.lectureDiary
                    )
                    #endif
                    SettingsNavigationLink(
                        title: SettingsStrings.serviceThemeMarket,
                        value: SettingsPathType.themeMarket
                    )
                } header: {
                    FormSectionHeader(SettingsStrings.service)
                }

                Section {
                    SettingsMenuButton(
                        title: SettingsStrings.infoVersion,
                        detail: viewModel.appVersion
                    )
                    SettingsNavigationLink(
                        title: SettingsStrings.infoDevelopers,
                        value: SettingsPathType.developers
                    )
                    SettingsNavigationLink(
                        title: SettingsStrings.termsService,
                        value: SettingsPathType.termsOfService
                    )
                    SettingsNavigationLink(
                        title: SettingsStrings.privacyPolicy,
                        value: SettingsPathType.privacyPolicy
                    )
                } header: {
                    FormSectionHeader(SettingsStrings.info)
                }

                Section {
                    SettingsNavigationLink(
                        title: SettingsStrings.feedback,
                        value: SettingsPathType.userSupport
                    )
                    SettingsMenuButton(
                        title: SettingsStrings.infoRateApp,
                        onTap: {
                            Task {
                                await appReviewService.openAppStoreReview()
                            }
                        }
                    )
                }

                #if DEBUG
                Section {
                    SettingsNavigationLink(
                        title: SettingsStrings.debugLog,
                        value: SettingsPathType.networkLogs
                    )
                } header: {
                    FormSectionHeader(SettingsStrings.debug)
                }
                #endif

                Section {
                    LogoutButton {
                        try await viewModel.myAccountViewModel.logout()
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(SettingsStrings.settings)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: SettingsPathType.self) { menuItem in
                SettingsDetails(menuItem: menuItem, viewModel: viewModel)
            }
            .navigationDestination(for: MyAccountPathType.self) { menuItem in
                MyAccountDetails(menuItem: menuItem, viewModel: viewModel.myAccountViewModel)
            }
            .task {
                await errorAlertHandler.withAlert {
                    try await viewModel.loadUnreadNotificationCount()
                }
            }
        }
        .analyticsScreen(.settingsHome)
    }
}

#Preview {
    SettingsScene()
}
