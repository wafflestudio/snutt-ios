//
//  MenuRenameSheet.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI
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
        GeometryReader { _ in
            VStack(spacing: 20) {
                SheetTopBar(
                    cancel: {
                        dismiss()
                    },
                    confirm: {
                        dismiss()
                        isRenameLoading = true
                        Task {
                            await errorAlertHandler.withAlert {
                                try await viewModel.renameTimetable(timetableID: metadata.id, title: title)
                            }
                            isRenameLoading = false
                        }
                    },
                    isConfirmDisabled: isRenameLoading
                )

                AnimatableTextField(label: "시간표 제목", placeholder: "시간표 제목을 입력하세요", text: $title)
                    .focused($searchFocus)
                    .onAppear {
                        searchFocus = true
                    }
                    .padding()
            }
        }
        .presentationDetents([.height(130)])
        .observeErrors()
    }
}

#Preview {
    MenuRenameSheet(viewModel: .init(timetableViewModel: .init()), metadata: PreviewHelpers.previewMetadata(with: "1"))
}
