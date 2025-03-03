//
//  SettingsScene.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI
import SharedUIComponents

public struct SettingsScene: View {
    
    @State private(set) var viewModel: SettingsViewModel
    @State private var isLogoutAlertPresented = false
    
    public init() {
        self.viewModel = .init()
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
                    ) {
                        // ontap
                    }
                    .padding(.vertical, 12)
                }

                Section(SettingsStrings.display) {
                    SettingsNavigationItem(
                        title: SettingsStrings.displayColorMode,
                        detail: "자동",
                        destination: ColorView(color: .red)
                    )
                    SettingsNavigationItem(
                        title: SettingsStrings.displayLanguage,
                        detail: "한국어",
                        destination: ColorView(color: .yellow)
                    )
                    SettingsNavigationItem(
                        title: SettingsStrings.displayTimetable,
                        destination: ColorView(color: .green)
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

                Section(SettingsStrings.information) {
                    SettingsMenuItem(
                        title: SettingsStrings.informationVersion,
                        detail: viewModel.appVersion
                    )
                    SettingsNavigationItem(
                        title: SettingsStrings.informationDevelopers,
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
            .navigationTitle("더보기")
            .navigationBarTitleDisplayMode(.inline)
        }
        .alert(SettingsStrings.logoutAlert, isPresented: $isLogoutAlertPresented) {
            Button(SettingsStrings.logout, role: .destructive) {
                // logout
            }
            Button(SharedUIComponentsStrings.alertCancel, role: .cancel) {}
        }
        .task {
            
        }
    }
}

#Preview {
    SettingsScene()
}
