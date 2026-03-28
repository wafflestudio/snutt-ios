//
//  MenuEllipsisSheet.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import AppReviewPromptInterface
import Dependencies
import SharedUIComponents
import SwiftUI
import SwiftUIUtility
import ThemesInterface
import TimetableInterface

struct MenuEllipsisSheet: View {
    let viewModel: TimetableMenuViewModel
    let metadata: TimetableMetadata

    @Environment(\.errorAlertHandler) private var errorAlertHandler
    @Environment(\.dismiss) private var dismiss
    @Environment(\.sheetDismiss) private var menuSheetDismiss
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.themeViewModel) private var themeViewModel
    @Dependency(\.appReviewService) private var appReviewService

    @State private var isRenameMenuPresented = false
    @State private var timetableImage: TimetableImage?

    var body: some View {
        ActionSheet {
            ActionSheetItem(image: Menu.edit.image, title: Menu.edit.text) {
                isRenameMenuPresented = true
            }
            ActionSheetItem(
                image: Menu.primary(isOn: metadata.isPrimary).image,
                title: Menu.primary(isOn: metadata.isPrimary).text
            ) {
                dismiss()
                errorAlertHandler.withAlert {
                    if metadata.isPrimary {
                        try await viewModel.unsetPrimaryTimetable(timetableID: metadata.id)
                    } else {
                        try await viewModel.setPrimaryTimetable(timetableID: metadata.id)
                    }
                }
            }
            ActionSheetItem(image: Menu.share.image, title: Menu.share.text) {
                errorAlertHandler.withAlert {
                    timetableImage = try await viewModel.createTimetableImage(
                        timetable: metadata,
                        colorScheme: colorScheme,
                        availableThemes: themeViewModel.availableThemes
                    )
                }
            }
            ActionSheetItem(image: Menu.theme.image, title: Menu.theme.text) {
                menuSheetDismiss()
                viewModel.presentThemeSheet()
            }
            ActionSheetItem(image: Menu.delete.image, title: Menu.delete.text) {
                dismiss()
                errorAlertHandler.withAlert {
                    try await viewModel.deleteTimetable(timetableID: metadata.id)
                }
            }
        }
        .sheet(isPresented: $isRenameMenuPresented) {
            MenuRenameSheet(viewModel: viewModel, metadata: metadata)
        }
        .sheet(item: $timetableImage) { image in
            TimetableShareSheet(timetableImage: image)
        }
        .observeErrors()
    }
}

private enum Menu {
    case edit
    case primary(isOn: Bool)
    case share
    case theme
    case delete

    var image: Image {
        switch self {
        case .edit: Image(uiImage: TimetableAsset.sheetEdit.image)
        case .primary(true): Image(uiImage: TimetableAsset.sheetFriendOff.image)
        case .primary(false): Image(uiImage: TimetableAsset.sheetFriend.image)
        case .share: Image(uiImage: TimetableAsset.navShare.image)
        case .theme: Image(uiImage: TimetableAsset.sheetPalette.image)
        case .delete: Image(uiImage: TimetableAsset.sheetTrash.image)
        }
    }

    var text: String {
        switch self {
        case .edit: TimetableStrings.sheetEllipsisEditTitle
        case .primary(true): TimetableStrings.sheetEllipsisPrimaryDisable
        case .primary(false): TimetableStrings.sheetEllipsisPrimaryEnable
        case .share: TimetableStrings.sheetEllipsisShare
        case .theme: TimetableStrings.sheetEllipsisTheme
        case .delete: TimetableStrings.sheetEllipsisDelete
        }
    }
}

#Preview {
    @Previewable @State var isPresented = true
    ZStack {
        Color.gray
        Button("Present") {
            isPresented = true
        }
        .buttonStyle(.borderedProminent)
    }
    .ignoresSafeArea()
    .sheet(isPresented: $isPresented) {
        MenuEllipsisSheet(
            viewModel: .init(timetableViewModel: .init()),
            metadata: PreviewHelpers.previewMetadata(with: "1")
        )
    }
}
