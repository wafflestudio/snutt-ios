//
//  MenuRenameSheet.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/08/06.
//

import SwiftUI

struct MenuRenameSheet: View {
    @Binding var isOpen: Bool
    @Binding var titleText: String

    var cancel: () -> Void
    var confirm: () async -> Void

    var body: some View {
        Sheet(isOpen: $isOpen,
              orientation: .bottom(maxHeight: 180),
              disableDragGesture: true) {
            VStack {
                MenuSheetTopBar(cancel: cancel, confirm: confirm, confirmDisabled: titleText.isEmpty, isSheetOpen: isOpen)

                AnimatedTextField(label: "시간표 제목", placeholder: "시간표 제목을 입력하세요", text: $titleText, shouldFocusOn: isOpen)

                Spacer()
            }
            .padding(.horizontal, 20)
        }
    }
}
