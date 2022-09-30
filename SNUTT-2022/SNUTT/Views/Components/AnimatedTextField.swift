//
//  AnimatedTextField.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/30.
//

import SwiftUI

struct AnimatedTextField: View {
    let label: String
    let placeholder: String
    @Binding var text: String

    var shouldFocusOn: Bool
    @FocusState private var _isFocused: Bool

    var body: some View {
        VStack {
            Text("시간표 제목")
                .font(STFont.detailLabel)
                .foregroundColor(Color(uiColor: .secondaryLabel))
                .frame(maxWidth: .infinity, alignment: .leading)

            TextField("시간표 제목을 입력하세요", text: $text)
                .focused($_isFocused)

            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(Color(uiColor: .opaqueSeparator))

                Rectangle()
                    .frame(maxWidth: text.isEmpty ? 0 : .infinity, alignment: .leading)
                    .frame(height: 2)
                    .foregroundColor(STColor.cyan)
                    .animation(.customSpring, value: text.isEmpty)
            }
        }
        .onChange(of: shouldFocusOn) { newValue in
            _isFocused = newValue
        }
    }
}

