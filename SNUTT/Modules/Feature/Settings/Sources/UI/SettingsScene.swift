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
    @State private(set) var viewModel: SettingsViewModel
    @State private var isLogoutAlertPresented = false

    @State private var path: [Destination] = []

    @Environment(\.errorAlertHandler) private var errorAlertHandler
    @Environment(\.vacancyUIProvider) private var vacancyUIProvider

    public init() {
        viewModel = .init()
    }

    public var body: some View {
        NavigationStack(path: $path) {
            List {
                Section {
                    SettingsListCell(menu: Settings.myAccount("와플#7777"), path: $path)
                        .padding(.vertical, 12)
                }

                Section(SettingsStrings.display) {
                    SettingsListCell(menu: Settings.appearance("자동"), path: $path)
                    SettingsListCell(menu: Settings.appLanguage, path: $path)
                    SettingsListCell(menu: Settings.timetableSettings, path: $path)
                    SettingsListCell(menu: Settings.timetableTheme, path: $path)
                }

                Section(SettingsStrings.service) {
                    SettingsListCell(menu: Settings.vacancyNotification, path: $path)
                    SettingsListCell(menu: Settings.themeMarket, path: $path)
                }

                Section(SettingsStrings.info) {
                    SettingsListCell(menu: Settings.version(viewModel.appVersion), path: $path)
                    SettingsListCell(menu: Settings.developers, path: $path)
                }

                Section {
                    SettingsListCell(menu: Settings.shareFeedback, path: $path)
                }

                Section {
                    SettingsListCell(menu: Settings.openSourceLicense, path: $path)
                    SettingsListCell(menu: Settings.termsOfService, path: $path)
                    SettingsListCell(menu: Settings.privacyPolicy, path: $path)
                }

                #if DEBUG
                    Section(SettingsStrings.debug) {
                        SettingsListCell(menu: Settings.networkLogs, path: $path)
                    }
                #endif

                Section {
                    SettingsListCell(menu: Settings.logout, path: $path) {
                        isLogoutAlertPresented = true
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(SettingsStrings.settings)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case let .settings(menu):
                    navigateToDestination(of: menu)
                case let .myAccount(menu):
                    navigateToDestination(of: menu)
                }
            }
        }
        .alert(
            SettingsStrings.logoutAlert,
            isPresented: $isLogoutAlertPresented
        ) {
            Button(SettingsStrings.logout, role: .destructive) {
                Task {
                    await logout()
                }
            }
            Button(SharedUIComponentsStrings.alertCancel, role: .cancel) {}
        }
        .task {}
    }
}

extension SettingsScene {
    private func logout() async {
        await errorAlertHandler.withAlert {
            try await viewModel.logout()
        }
    }

    @ViewBuilder private func navigateToDestination(of menu: Settings) -> some View {
        switch menu {
        case .myAccount:
            MyAccountScene($path)
        case .appearance:
            ColorModeSettingView()
        case .appLanguage:
            ColorView(color: .yellow)
        case .timetableSettings:
            TimetableSettingView(
                makePainter: viewModel.makePainter,
                config: $viewModel.configuration
            )
        case .timetableTheme:
            ColorView(color: .blue)
        case .vacancyNotification:
            AnyView(vacancyUIProvider.makeVacancyScene())
        case .themeMarket:
            ColorView(color: .orange)
        case .developers:
            ColorView(color: .green)
        case .shareFeedback:
            ColorView(color: .cyan)
        case .openSourceLicense:
            ColorView(color: .orange)
        case .termsOfService:
            ColorView(color: .brown)
        case .privacyPolicy:
            ColorView(color: .gray)
        case .networkLogs:
            ColorView(color: .red)
        default: EmptyView()
        }
    }

    @ViewBuilder private func navigateToDestination(of menu: MyAccount) -> some View {
        switch menu {
        case .changeNickname:
            ColorView(color: .blue)
        case .addId:
            ColorView(color: .orange)
        case .changePassword:
            ColorView(color: .green)
        case .snsConnection:
            ColorView(color: .cyan)
        default: EmptyView()
        }
    }
}

#Preview {
    SettingsScene()
}
