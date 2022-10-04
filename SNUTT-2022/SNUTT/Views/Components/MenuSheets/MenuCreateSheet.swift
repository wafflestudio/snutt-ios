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
    @Binding var selectedQuarter: Quarter?

    var quarterChoices: [Quarter]

    var cancel: () -> Void
    var confirm: () async -> Void

    var showPicker: Bool {
        selectedQuarter != nil
    }

    @State private var selectedIndex: Int = 0

    var body: some View {
        Sheet(isOpen: $isOpen,
              orientation: .bottom(maxHeight: showPicker ? 370 : 180),
              disableBackgroundTap: false,
              disableDragGesture: true) {
            VStack {
                MenuSheetTopBar(cancel: cancel, confirm: confirm, confirmDisabled: titleText.isEmpty, isSheetOpen: isOpen)

                TitleTextField(titleText: $titleText, isSheetOpen: isOpen)

                if showPicker {
                    Picker("학기 선택", selection: $selectedIndex) {
                        ForEach(quarterChoices.indices, id: \.self) { index in
                            let quarter = quarterChoices[index]
                            Text(quarter.longString()).tag(quarter)
                        }
                    }
                    .pickerStyle(.wheel)
                    .onChange(of: selectedIndex) { newValue in
                        selectedQuarter = quarterChoices[newValue]
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 20)
        }
        .onChange(of: isOpen) { newValue in
            if newValue {
                selectedIndex = 0
            }
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
