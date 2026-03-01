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
                Toggle(
                    SettingsStrings.servicePushNotificationLectureUpdate,
                    isOn: $viewModel.preferences.isLectureUpdateEnabled
                )
                .animation(.easeInOut, value: viewModel.preferences.isLectureUpdateEnabled)
                Toggle(
                    SettingsStrings.servicePushNotificationVacancy,
                    isOn: $viewModel.preferences.isVacancyEnabled
                )
                .animation(.easeInOut, value: viewModel.preferences.isVacancyEnabled)
                Toggle(
                    SettingsStrings.servicePushNotificationDiary,
                    isOn: $viewModel.preferences.isDiaryEnabled
                )
                .animation(.easeInOut, value: viewModel.preferences.isDiaryEnabled)
            }
        }
        .navigationTitle(SettingsStrings.servicePushNotification)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadPreferences()
        }
    }
}

#Preview {
    NavigationStack {
        PushNotificationSettingsView(viewModel: .init())
    }
}
