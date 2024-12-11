//
//  AnimatedTextField.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/30.
//

import SwiftUI

struct AnimatedTextField: View {
    let label: String?
    let placeholder: String
    @Binding var text: String
    
    let keyboardType: UIKeyboardType

    let shouldFocusOn: Bool
    let secure: Bool
    let disabled: Bool

    // TextField with Timer
    let needsTimer: Bool
    let canRestart: Bool
    @Binding var timeOut: Bool
    @Binding var remainingTime: Int
    let restart: (() -> Void)?

    @FocusState private var _isFocused: Bool

    init(label: String? = nil, placeholder: String, text: Binding<String>,
         keyboardType: UIKeyboardType = .default, shouldFocusOn: Bool = false,
         secure: Bool = false, disabled: Bool = false,
         needsTimer: Bool = false, canRestart: Bool = false, timeOut: Binding<Bool> = .constant(false),
         remainingTime: Binding<Int> = .constant(0),
         restart: (() -> Void)? = nil) {
        self.label = label
        self.placeholder = placeholder
        self.keyboardType = keyboardType
        self.shouldFocusOn = shouldFocusOn
        self.secure = secure
        self.needsTimer = needsTimer
        self.canRestart = canRestart
        self.restart = restart
        _text = text
        self.disabled = disabled
        _timeOut = timeOut
        _remainingTime = remainingTime
    }

    var body: some View {
        VStack(spacing: 12) {
            if let label = label {
                Text(label)
                    .font(STFont.regular14.font)
                    .foregroundColor(Color(uiColor: .secondaryLabel))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 0) {
                    Group {
                        if secure {
                            SecureField(placeholder, text: $text)
                        } else {
                            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(STColor.assistive))
                                .foregroundStyle(disabled ? STColor.assistive : .primary)
                                .disabled(disabled)
                        }
                    }
                    .focused($_isFocused)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .font(STFont.regular15.font)

                    // TextField with Timer
                    if needsTimer {
                        Spacer().frame(width: 4)
                        Group {
                            if !timeOut {
                                Text(Calendar.current.date(byAdding: .second, value: remainingTime + 1, to: Date()) ?? Date(), style: .timer)
                                    .foregroundColor(STColor.red)
                            } else if canRestart {
                                Button {
                                    restart?()
                                } label: {
                                    Text("다시 요청")
                                        .foregroundColor(STColor.cyan)
                                }
                            }
                        }
                        .font(STFont.semibold15.font)
                        .padding(.horizontal, 10)
                    }
                }
                
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color(uiColor: .quaternaryLabel))

                    Rectangle()
                        .frame(maxWidth: _isFocused ? .infinity : 0, alignment: .leading)
                        .frame(height: 1)
                        .foregroundColor(STColor.cyan)
                        .animation(.customSpring, value: _isFocused)
                }
            }
        }
        .onTapGesture {
            _isFocused = true
        }
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
