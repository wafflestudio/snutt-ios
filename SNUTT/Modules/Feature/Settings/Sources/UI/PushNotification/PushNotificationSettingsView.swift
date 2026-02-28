//
//  PushNotificationSettingsView.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI

struct PushNotificationSettingsView: View {
    @Bindable var viewModel: PushNotificationSettingsViewModel

    var body: some View {
        Form {
            Section {
                Toggle(SettingsStrings.servicePushNotificationLectureUpdate, isOn: $viewModel.isLectureUpdateOn)
                    .animation(.easeInOut, value: viewModel.isLectureUpdateOn)
                Toggle(SettingsStrings.servicePushNotificationVacancy, isOn: $viewModel.isVacancyOn)
                    .animation(.easeInOut, value: viewModel.isVacancyOn)
            }
        }
        .navigationTitle(SettingsStrings.servicePushNotification)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadPreferences()
        }
    }
}
