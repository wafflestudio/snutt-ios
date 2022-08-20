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
              disableBackgroundTap: false,
              disableDragGesture: false) {
            VStack {
                MenuSheetTopBar(cancel: cancel, confirm: confirm, confirmDisabled: titleText.isEmpty)
                
                TitleTextField(titleText: $titleText, isSheetOpen: isOpen)

                Spacer()
            }
            .padding(.horizontal, 20)
        }
    }
}


