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

    var shouldFocusOn: Bool = false
    var secure: Bool = false

    @FocusState private var _isFocused: Bool

    var body: some View {
        VStack {
            Text(label)
                .font(STFont.detailLabel)
                .foregroundColor(Color(uiColor: .secondaryLabel))
                .frame(maxWidth: .infinity, alignment: .leading)

            Group {
                if secure {
                    SecureField(placeholder, text: $text)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .focused($_isFocused)
            .frame(height: 20)
            .textInputAutocapitalization(.never)

            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(Color(uiColor: .quaternaryLabel))

                Rectangle()
                    .frame(maxWidth: text.isEmpty ? 0 : .infinity, alignment: .leading)
                    .frame(height: 2)
                    .foregroundColor(STColor.cyan)
                    .animation(.customSpring, value: text.isEmpty)
            }
        }
        .onTapGesture(perform: {
            _isFocused = true
        })
        .onAppear {
            _isFocused = shouldFocusOn
        }
        .onChange(of: shouldFocusOn) { newValue in
            _isFocused = newValue
        }
    }
}

struct AnimatedTextField_Previews: PreviewProvider {
    struct WrapperView: View {
        @State var text: String = ""
        var body: some View {
            AnimatedTextField(label: "라벨", placeholder: "텍스트를 입력하세요", text: $text)
        }
    }

    static var previews: some View {
        WrapperView().padding(.horizontal, 20)
    }
}
