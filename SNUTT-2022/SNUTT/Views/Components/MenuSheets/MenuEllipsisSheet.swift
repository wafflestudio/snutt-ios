//
//  MenuEllipsisSheet.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/08/06.
//

import SwiftUI

struct MenuEllipsisSheet: View {
    @Binding var isOpen: Bool
    var openTitleTextField: () -> Void
    var deleteTimetable: () async -> Void
    var openPalette: () -> Void
    @State private var isDeleteAlertPresented = false

    var body: some View {
        Sheet(isOpen: $isOpen, orientation: .bottom(maxHeight: 180)) {
            VStack(spacing: 0) {
                EllipsisSheetButton(imageName: "pen", text: "이름 변경") {
                    openTitleTextField()
                }

                EllipsisSheetButton(imageName: "trash", text: "시간표 삭제") {
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

                EllipsisSheetButton(imageName: "palette", text: "시간표 테마 설정") {
                    openPalette()
                }
            }
        }
    }
}
