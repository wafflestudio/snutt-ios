//
//  MenuRenameSheet.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI
import SwiftUIUtility
import TimetableInterface

struct MenuRenameSheet: View {
    let viewModel: TimetableMenuViewModel
    let metadata: TimetableMetadata

    @State private var title: String = ""
    @FocusState private var searchFocus: Bool
    @State private var isRenameLoading = false
    @Environment(\.errorAlertHandler) private var errorAlertHandler
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            SheetTopBar(
                cancel: {
                    dismiss()
                },
                confirm: {
                    dismiss()
                    isRenameLoading = true
                    errorAlertHandler.withAlert {
                        try await viewModel.renameTimetable(timetableID: metadata.id, title: title)
                    }
                    isRenameLoading = false
                },
                isConfirmDisabled: isRenameLoading
            )

            AnimatableTextField(
                label: TimetableStrings.timetableMenuTitleLabel,
                placeholder: TimetableStrings.timetableMenuTitlePlaceholder,
                text: $title
            )
            .focused($searchFocus)
            .onAppear {
                searchFocus = true
            }
            .padding()
        }
        .presentationSizingFitted()
        .observeErrors()
    }
}

#Preview {
    MenuRenameSheet(viewModel: .init(timetableViewModel: .init()), metadata: PreviewHelpers.previewMetadata(with: "1"))
}
