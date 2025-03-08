//
//  SettingsScene.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

public struct SettingsScene: View {
    @State private(set) var viewModel: SettingsViewModel
    @State private var isLogoutAlertPresented = false

    @Environment(\.errorAlertHandler) private var errorAlertHandler

    public init() {
        viewModel = .init()
    }

    public var body: some View {
        NavigationStack {
            List {
                Section {
                    SettingsNavigationItem(
                        title: SettingsStrings.account,
                        leadingImage: SettingsAsset.person.swiftUIImage,
                        detail: "와플#7777",
                        destination: MyAccountScene()
                    )
                    .padding(.vertical, 12)
                }

                Section(SettingsStrings.display) {
                    SettingsNavigationItem(
                        title: SettingsStrings.displayColorMode,
                        detail: "자동",
                        destination: ColorModeSettingView()
                    )
                    SettingsNavigationItem(
                        title: SettingsStrings.displayLanguage,
                        detail: "한국어",
                        destination: ColorView(color: .yellow)
                    )
                    SettingsNavigationItem(
                        title: SettingsStrings.displayTable,
                        destination: TimetableSettingView(
                            makePainter: viewModel.makePainter,
                            config: $viewModel.configuration
                        )
                    )
                    SettingsNavigationItem(
                        title: SettingsStrings.displayTheme,
                        destination: ColorView(color: .blue)
                    )
                }

                Section(SettingsStrings.service) {
                    SettingsNavigationItem(
                        title: SettingsStrings.serviceVacancy,
                        destination: ColorView(color: .purple)
                    )
                }

                Section(SettingsStrings.info) {
                    SettingsMenuItem(
                        title: SettingsStrings.infoVersion,
                        detail: viewModel.appVersion
                    )
                    SettingsNavigationItem(
                        title: SettingsStrings.infoDevelopers,
                        destination: ColorView(color: .orange)
                    )
                }

                Section {
                    SettingsNavigationItem(
                        title: SettingsStrings.feedback,
                        destination: ColorView(color: .cyan)
                    )
                }

                Section {
                    SettingsNavigationItem(
                        title: SettingsStrings.license,
                        destination: ColorView(color: .orange)
                    )
                    SettingsNavigationItem(
                        title: SettingsStrings.termsService,
                        destination: ColorView(color: .brown)
                    )
                    SettingsNavigationItem(
                        title: SettingsStrings.privacyPolicy,
                        destination: ColorView(color: .gray)
                    )
                }

                #if DEBUG
                    Section(SettingsStrings.debug) {
                        SettingsNavigationItem(
                            title: SettingsStrings.debugLog,
                            destination: ColorView(color: .red)
                        )
                    }
                #endif

                Section {
                    SettingsMenuItem(
                        title: SettingsStrings.logout,
                        destructive: true
                    ) {
                        isLogoutAlertPresented = true
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle(SettingsStrings.settings)
            .navigationBarTitleDisplayMode(.inline)
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
}

#Preview {
    SettingsScene()
}
