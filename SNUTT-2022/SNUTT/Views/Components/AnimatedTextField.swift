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
    
    // TextField with Timer
    var needsTimer: Bool = false
    @Binding var timeOut: Bool
    var remainingTime: Int = 0
    var action: (() -> Void)? = nil

    @FocusState private var _isFocused: Bool
    
    init(label: String, placeholder: String, text: Binding<String>, shouldFocusOn: Bool = false, secure: Bool = false, needsTimer: Bool = false, timeOut: Binding<Bool> = .constant(false), remainingTime: Int = 0, action: (() -> Void)? = nil) {
        self.label = label
        self.placeholder = placeholder
        _text = text
        self.shouldFocusOn = shouldFocusOn
        self.secure = secure
        self.needsTimer = needsTimer
        _timeOut = timeOut
        self.action = action
        self.remainingTime = remainingTime
    }

    var body: some View {
        VStack {
            Text(label)
                .font(STFont.detailLabel)
                .foregroundColor(Color(uiColor: .secondaryLabel))
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 0) {
                Group {
                    if secure {
                        SecureField(placeholder, text: $text)
                    } else {
                        TextField(placeholder, text: $text)
                    }
                }
                .focused($_isFocused)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .font(STFont.detailLabel)
                .frame(height: 20)
                
                // TextField with Timer
                if needsTimer {
                    Spacer().frame(width: 4)
                    
                    Group {
                        if timeOut {
                            Button {
                                action?()
                            } label: {
                                Text("다시 요청")
                                    .foregroundColor(STColor.cyan)
                            }
                        } else {
                            Text(Calendar.current.date(byAdding: .second, value: remainingTime + 1, to: Date()) ?? Date(), style: .timer)
                                .foregroundColor(STColor.red)
                        }
                    }
                    .font(STFont.subheading)
                    .padding(.horizontal, 16)
                }
            }

            ZStack(alignment: .leading) {
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(Color(uiColor: .quaternaryLabel))

                Rectangle()
                    .frame(maxWidth: text.isEmpty ? 0 : .infinity, alignment: .leading)
                    .frame(height: 1)
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
