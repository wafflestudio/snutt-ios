//
//  MenuCreateSheet.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/08/21.
//

import SwiftUI

struct MenuCreateSheet: View {
    @Binding var isOpen: Bool
    @Binding var titleText: String

    var cancel: () -> Void
    var confirm: () async -> Void

    var body: some View {
        Sheet(isOpen: $isOpen,
              orientation: .bottom(maxHeight: 300),
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

struct TitleTextField: View {
    @Binding var titleText: String
    var isSheetOpen: Bool
    
    @FocusState private var titleTextFieldFocus: Bool
    
    var body: some View {
        VStack {
            Text("시간표 제목")
                .font(STFont.detailLabel)
                .foregroundColor(Color(uiColor: .secondaryLabel))
                .frame(maxWidth: .infinity, alignment: .leading)

            TextField("시간표 제목을 입력하세요", text: $titleText)
                .focused($titleTextFieldFocus)

            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(Color(uiColor: .opaqueSeparator))

                Rectangle()
                    .frame(maxWidth: titleText.isEmpty ? 0 : .infinity, alignment: .leading)
                    .frame(height: 2)
                    .foregroundColor(STColor.cyan)
                    .animation(.customSpring, value: titleText.isEmpty)
            }
        }
        .onChange(of: isSheetOpen) { newValue in
            titleTextFieldFocus = newValue
        }
    }
}

