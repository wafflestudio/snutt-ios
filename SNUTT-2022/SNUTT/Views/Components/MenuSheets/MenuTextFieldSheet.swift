//
//  MenuTextFieldSheet.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/08/06.
//

import SwiftUI

struct MenuTextFieldSheet: View {
    @Binding var isOpen: Bool
    @Binding var titleText: String

    var cancel: () -> Void
    var confirm: () async -> Void

    @FocusState private var titleTextFieldFocus: Bool
    var body: some View {
        Sheet(isOpen: $isOpen,
              orientation: .bottom(maxHeight: 180),
              disableBackgroundTap: false,
              disableDragGesture: false) {
            VStack {
                HStack {
                    Button {
                        cancel()
                    } label: {
                        Text("취소")
                    }

                    Spacer()

                    Button {
                        Task {
                            await confirm()
                        }
                    } label: {
                        Text("적용")
                    }
                    .disabled(titleText.isEmpty)
                }
                .padding(.vertical)

                Spacer()
                    .frame(height: 20)

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

                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .onChange(of: isOpen) { newValue in
            titleTextFieldFocus = newValue
        }
    }
}
