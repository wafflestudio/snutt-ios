//
//  PushNotificationSettingsView.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

struct PushNotificationSettingsView: View {
    @Bindable var viewModel: PushNotificationSettingsViewModel
    @Environment(\.errorAlertHandler) private var errorAlertHandler

    var body: some View {
        Form {
            switch viewModel.loadState {
            case .loading:
                ProgressView()
            case .loaded:
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
        }
        .navigationTitle(SettingsStrings.servicePushNotification)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            errorAlertHandler.withAlert {
                try await viewModel.loadPreferences()
            }
        }
        .onChange(of: viewModel.preferences) { oldValue, newValue in
            guard newValue != viewModel.savedPreferences else { return }
            errorAlertHandler.withAlert {
                try await viewModel.savePreferences(oldValue)
            }
        }
        .tint(SharedUIComponentsAsset.cyan.swiftUIColor)
    }
}

#Preview {
    NavigationStack {
        PushNotificationSettingsView(viewModel: .init())
    }
}
