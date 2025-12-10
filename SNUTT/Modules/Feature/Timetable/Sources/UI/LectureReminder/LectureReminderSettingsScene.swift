//
//  LectureReminderSettingsScene.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import FoundationUtility
import SharedUIComponents
import SwiftUI

public struct LectureReminderSettingsScene: View {
    @State private var viewModel = LectureReminderSettingsViewModel()
    @Environment(\.presentToast) private var presentToast
    @Environment(\.errorAlertHandler) private var errorAlertHandler

    public init() {}

    public var body: some View {
        contentView
            .navigationTitle(TimetableStrings.reminderTitle)
            .navigationBarTitleDisplayMode(.inline)
            .task {
                await errorAlertHandler.withAlert {
                    try await viewModel.loadReminders()
                }
            }
    }

    private var errorStateView: some View {
        LectureReminderEmptyView(
            title: TimetableStrings.reminderErrorTitle,
            description: TimetableStrings.reminderErrorDescription,
            actionButton: {
                Task {
                    await errorAlertHandler.withAlert {
                        try await viewModel.loadReminders()
                    }
                }
            }
        )
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
        .animation(.defaultSpring, value: viewModel.loadState.isLoading)
    }

    private var contentView: some View {
        Group {
            switch viewModel.loadState {
            case .loading, .loaded:
                Form {
                    Section {
                        switch viewModel.loadState {
                        case .loading:
                            ProgressView()
                                .frame(maxWidth: .infinity, alignment: .center)
                        case .loaded:
                            ForEach(viewModel.sortedReminderViewModels, id: \.lectureReminder.timetableLectureID) {
                                reminderViewModel in
                                reminderRow(for: reminderViewModel)
                            }
                        default:
                            EmptyView()
                        }
                    } header: {
                        Text(TimetableStrings.reminderSettingsHeader)
                            .foregroundStyle(SharedUIComponentsAsset.gray30.swiftUIColor)
                    } footer: {
                        Text(TimetableStrings.reminderSettingsFooter.asMarkdown())
                            .lineHeight(with: .systemFont(ofSize: 13), percentage: 140)
                            .foregroundStyle(SharedUIComponentsAsset.gray30.swiftUIColor)
                            .padding(.top, 16)
                            .padding(.bottom, 48)
                            .listRowInsets(EdgeInsets())
                    }
                }
            case .loaded(let array) where array.isEmpty:
                LectureReminderEmptyView()
            case .failed:
                errorStateView
            }
        }
        .refreshable {
            await errorAlertHandler.withAlert {
                try await viewModel.loadReminders()
            }
        }
        .animation(.defaultSpring, value: viewModel.loadState.isLoading)
    }

    private func reminderRow(for reminderViewModel: LectureReminderViewModel) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(reminderViewModel.lectureReminder.lectureTitle)
                .font(.system(size: 15))

            LectureReminderPicker(
                selection: Binding(
                    get: { reminderViewModel.option },
                    set: { newValue in
                        errorAlertHandler.withAlert {
                            try await reminderViewModel.updateOption(newValue)
                            if let message = newValue.toastMessage {
                                presentToast(.init(message: message))
                            }
                        }
                    }
                )
            )
        }
        .padding(.vertical, 8)
    }
}
