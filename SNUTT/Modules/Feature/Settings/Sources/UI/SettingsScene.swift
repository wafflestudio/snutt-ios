//
//  SettingsScene.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI

public struct SettingsScene: View {
    
    @State private(set) var viewModel: SettingsViewModel
    
    public init() {
        self.viewModel = .init()
    }
    
    public var body: some View {
        NavigationStack {
            List {
                Section {
                    Text(SettingsStrings.account)
                }

                Section(SettingsStrings.display) {
                    Text(SettingsStrings.displayColorMode)
                    Text(SettingsStrings.displayLanguage)
                    Text(SettingsStrings.displayTimetable)
                    Text(SettingsStrings.displayTheme)
                }

                Section(SettingsStrings.service) {
                    Text(SettingsStrings.serviceVacancy)
                }

                Section(SettingsStrings.information) {
                    Text(SettingsStrings.informationVersion)
                    Text(SettingsStrings.informationDevelopers)
                }

                Section {
                    Text(SettingsStrings.feedback)
                }

                Section {
                    Text(SettingsStrings.license)
                    Text(SettingsStrings.termsService)
                    Text(SettingsStrings.privacyPolicy)
                }

                #if DEBUG
                    Section(SettingsStrings.debug) {
                        Text(SettingsStrings.debugLog)
                    }
                #endif

                Section {
                    Text(SettingsStrings.logout)
                }
            }
            .listStyle(.insetGrouped)
        }
        .task {
            
        }
    }
}

#Preview {
    SettingsScene()
}
