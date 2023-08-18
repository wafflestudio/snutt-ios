//
//  MenuEllipsisSheet.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/08/06.
//

import SwiftUI

struct MenuEllipsisSheet: View {
    @Binding var isOpen: Bool
    var openRenameSheet: @MainActor () -> Void
    var setPrimaryTimetable: @MainActor () async -> Void
    var openThemeSheet: @MainActor () -> Void
    var deleteTimetable: @MainActor () async -> Void
    @State private var isDeleteAlertPresented = false

    var body: some View {
        Sheet(isOpen: $isOpen, orientation: .bottom(maxHeight: 225)) {
            VStack(spacing: 0) {
                EllipsisSheetButton(menu: .edit, isSheetOpen: isOpen) {
                    openRenameSheet()
                }

                EllipsisSheetButton(menu: .primary) {
                    Task {
                        await setPrimaryTimetable()
                    }
                }

                EllipsisSheetButton(menu: .theme, isSheetOpen: isOpen) {
                    openThemeSheet()
                }

                EllipsisSheetButton(menu: .delete, isSheetOpen: isOpen) {
                    isDeleteAlertPresented = true
                }
                .alert("시간표를 삭제하시겠습니까?", isPresented: $isDeleteAlertPresented) {
                    Button("취소", role: .cancel, action: {})
                    Button("삭제", role: .destructive) {
                        Task {
                            await deleteTimetable()
                        }
                    }
                }
            }
        }
    }
}
