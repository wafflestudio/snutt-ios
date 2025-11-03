//
//  SettingsScene.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI
import VacancyInterface

public struct SettingsScene: View {
    @State private(set) var viewModel: SettingsViewModel = .init()
    @AppStorage(AppStorageKeys.preferredColorScheme) private var selectedColorScheme: ColorSchemeSelection = .system

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

                Section(SettingsStrings.display) {
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
                }

                Section(SettingsStrings.service) {
                    SettingsNavigationLink(
                        title: SettingsStrings.serviceVacancy,
                        value: SettingsPathType.vacancyNotification
                    )
                    SettingsNavigationLink(
                        title: SettingsStrings.serviceThemeMarket,
                        value: SettingsPathType.themeMarket
                    )
                }

                Section(SettingsStrings.info) {
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
                }

                Section {
                    SettingsNavigationLink(
                        title: SettingsStrings.feedback,
                        value: SettingsPathType.userSupport
                    )
                }

                #if DEBUG
                    Section(SettingsStrings.debug) {
                        SettingsNavigationLink(
                            title: SettingsStrings.debugLog,
                            value: SettingsPathType.networkLogs
                        )
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
        }
        .analyticsScreen(.settingsHome)
    }
}

#Preview {
    SettingsScene()
}
