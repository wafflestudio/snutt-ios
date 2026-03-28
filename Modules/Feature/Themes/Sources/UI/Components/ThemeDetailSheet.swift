//
//  ThemeDetailSheet.swift
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

struct ThemeDetailSheet: View {
    let theme: Theme

    @Environment(\.errorAlertHandler) private var errorAlertHandler
    @Environment(\.dismiss) private var dismiss
    @Environment(\.themeViewModel) private var themeViewModel: any ThemeViewModelProtocol
    @Dependency(\.appReviewService) private var appReviewService
    @State private var isEditDetailPresented = false

    var body: some View {
        ActionSheet {
            ActionSheetItem(
                image: Image(systemName: theme.status == .customPrivate ? "pencil" : "doc.text"),
                title: theme.status == .customPrivate
                    ? ThemesStrings.sheetDetailEdit
                    : ThemesStrings.sheetDetailView
            ) {
                isEditDetailPresented = true
            }
            ActionSheetItem(image: Image(systemName: "paintpalette"), title: ThemesStrings.sheetDetailApply) {
                dismiss()
                errorAlertHandler.withAlert {
                    themeViewModel.selectTheme(theme)
                    try await themeViewModel.saveSelectedTheme()
                    await appReviewService.requestReviewIfNeeded()
                }
            }
            if theme.status == .customPrivate {
                ActionSheetItem(image: Image(systemName: "doc.on.doc"), title: ThemesStrings.sheetDetailDuplicate) {
                    dismiss()
                    errorAlertHandler.withAlert {
                        try await themeViewModel.copyTheme(theme)
                    }
                }
            }
            if theme.status == .customPrivate || theme.status == .customDownloaded {
                ActionSheetItem(
                    image: Image(systemName: "trash"),
                    title: ThemesStrings.sheetDetailDelete,
                    role: .destructive
                ) {
                    dismiss()
                    errorAlertHandler.withAlert {
                        try await themeViewModel.deleteTheme(theme)
                    }
                }
            }
        }
        .sheet(isPresented: $isEditDetailPresented) {
            NavigationStack {
                ThemeEditDetailScene(entryTheme: theme)
            }
            .presentationDetents([.large])
        }
        .observeErrors()
    }
}
