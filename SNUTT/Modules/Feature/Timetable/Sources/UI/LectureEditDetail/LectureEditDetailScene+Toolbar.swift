//
//  LectureEditDetailScene+Toolbar.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies
import DependenciesAdditions
import SharedUIComponents
import SwiftUI
import TimetableInterface

extension LectureEditDetailScene {
    struct ToolbarOptions: OptionSet {
        let rawValue: Int

        // Leading
        static let cancelButton = ToolbarOptions(rawValue: 1 << 0)

        // Trailing
        static let vacancyNotificationButton = ToolbarOptions(rawValue: 1 << 1)
        static let bookmarkButton = ToolbarOptions(rawValue: 1 << 2)
        static let editButton = ToolbarOptions(rawValue: 1 << 3)
        static let saveButton = ToolbarOptions(rawValue: 1 << 4)
    }

    var toolbarOptions: ToolbarOptions {
        var options: ToolbarOptions = []

        // Leading: Cancel button
        switch viewModel.displayMode {
        case .normal where editMode.isEditing:
            options.insert(.cancelButton)
        case .create:
            options.insert(.cancelButton)
        case let .preview(previewOptions, _) where previewOptions.contains(.showDismissButton):
            options.insert(.cancelButton)
        default:
            break
        }

        // Trailing: Toolbar action buttons (vacancy, bookmark) and edit/save button
        let isCustomLecture = viewModel.entryLecture.isCustom
        let isEditing = editMode.isEditing

        switch viewModel.displayMode {
        case .normal:
            // 액션 버튼들 (공석알림, 북마크)
            if !isCustomLecture && !isEditing {
                options.insert(.vacancyNotificationButton)
                options.insert(.bookmarkButton)
            }

            // Edit/Save 버튼
            if isEditing {
                options.insert(.saveButton)
            } else {
                options.insert(.editButton)
            }

        case .create:
            options.insert(.saveButton)

        case let .preview(previewOptions, _):
            // preview 모드에서는 previewOptions에 따라 액션 버튼만 표시
            // preview 모드에서는 edit/save 버튼 없음
            if !isCustomLecture, previewOptions.contains(.showToolbarActions) {
                options.insert(.vacancyNotificationButton)
                options.insert(.bookmarkButton)
            }
        }

        return options
    }

    // MARK: - Cancellation Action

    @ToolbarContentBuilder
    var cancelToolbarItem: some ToolbarContent {
        if toolbarOptions.contains(.cancelButton) {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", systemImage: "xmark") {
                    handleCancelAction()
                }
            }
        }
    }

    // MARK: - Primary Actions

    @ViewBuilder
    var vacancyNotificationButton: some View {
        if toolbarOptions.contains(.vacancyNotificationButton) {
            Button {
                errorAlertHandler.withAlert {
                    let wasEnabled = viewModel.isVacancyNotificationEnabled
                    try await viewModel.toggleVacancyNotification()

                    if !wasEnabled {
                        presentToast(
                            Toast(
                                message: TimetableStrings.toastVacancyMessage,
                                button: ToastButton(
                                    title: TimetableStrings.toastActionView,
                                    action: {
                                        notificationCenter.post(NavigateToVacancyMessage())
                                    }
                                )
                            )
                        )
                    }
                }
            } label: {
                if viewModel.isVacancyNotificationEnabled {
                    TimetableAsset.navVacancyOn.swiftUIImage
                } else {
                    TimetableAsset.navVacancyOff.swiftUIImage
                }
            }
        }
    }

    @ViewBuilder
    var bookmarkButton: some View {
        if toolbarOptions.contains(.bookmarkButton) {
            Button {
                errorAlertHandler.withAlert {
                    let wasBookmarked = viewModel.isBookmarked
                    try await viewModel.toggleBookmark()
                    if !wasBookmarked {
                        presentToast(
                            Toast(
                                message: TimetableStrings.toastBookmarkMessage,
                                button: ToastButton(
                                    title: TimetableStrings.toastActionView,
                                    action: {
                                        notificationCenter.post(NavigateToBookmarkMessage())
                                    }
                                )
                            )
                        )
                    }
                }
            } label: {
                if viewModel.isBookmarked {
                    TimetableAsset.navBookmarkOn.swiftUIImage
                } else {
                    TimetableAsset.navBookmark.swiftUIImage
                }
            }
        }
    }

    // MARK: - Confirmation Action

    @ToolbarContentBuilder
    var confirmationToolbarItem: some ToolbarContent {
        if toolbarOptions.contains(.editButton) {
            ToolbarItem(placement: .confirmationAction) {
                Button(TimetableStrings.editEdit, systemImage: "pencil") {
                    editMode = .active
                }
                .tint(SharedUIComponentsAsset.cyan.swiftUIColor)
            }
        } else if toolbarOptions.contains(.saveButton) {
            ToolbarItem(placement: .confirmationAction) {
                Button(TimetableStrings.editSave, systemImage: "checkmark") {
                    handleSaveAction()
                }
                .tint(SharedUIComponentsAsset.cyan.swiftUIColor)
            }
        }
    }

    // MARK: - Main Toolbar Content

    @ToolbarContentBuilder
    var toolbarContent: some ToolbarContent {
        cancelToolbarItem

        if toolbarOptions.contains(.vacancyNotificationButton) || toolbarOptions.contains(.bookmarkButton) {
            ToolbarItemGroup(placement: .primaryAction) {
                vacancyNotificationButton
                bookmarkButton
            }
        }

        confirmationToolbarItem
    }

    // MARK: - Actions

    func handleCancelAction() {
        switch viewModel.displayMode {
        case .normal where editMode.isEditing:
            if viewModel.hasUnsavedChanges {
                showCancelConfirmation = true
            } else {
                cancelEditing()
            }
        case .create, .preview:
            dismiss()
        default:
            break
        }
    }

    func handleSaveAction() {
        switch viewModel.displayMode {
        case .normal:
            editMode = .transient
            errorAlertHandler.withAlert {
                do {
                    try await conflictHandler.withConflictHandling { overrideOnConflict in
                        try await viewModel.saveEditableLecture(overrideOnConflict: overrideOnConflict)
                    }
                    editMode = .inactive
                } catch {
                    // 에러가 발생하거나 취소된 경우 변경사항 되돌리기
                    viewModel.cancelEdit()
                    editMode = .inactive
                    throw error
                }
            }
        case .create:
            errorAlertHandler.withAlert {
                do {
                    try await conflictHandler.withConflictHandling { overrideOnConflict in
                        try await viewModel.addCustomLecture(overrideOnConflict: overrideOnConflict)
                        dismiss()
                    }
                } catch {
                    // 에러가 발생하거나 취소된 경우
                    throw error
                }
            }
        case .preview:
            break
        }
    }

    func cancelEditing() {
        viewModel.cancelEdit()
        editMode = .inactive
        application.dismissKeyboard()
    }
}
