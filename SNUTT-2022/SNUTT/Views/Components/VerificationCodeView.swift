//
//  VerificationCodeView.swift
//  SNUTT
//
//  Created by 최유림 on 2022/12/17.
//

import Combine
import SwiftUI

struct VerificationCodeView: View {
    @State private var verificationCode: String = ""
    @State private var showHelpAlert: Bool = false
    @State private var timeOut: Bool = false
    @State private var remainingTime: Int = 0

    @State private var timer = Timer.publish(every: 1, on: .main, in: .common)
    @State private var currentTimer: Cancellable? = nil

    let mode: Mode
    let email: String

    /// Time limitation for entering verification code. 180 seconds by default.
    var timeLimit: Int = 180
    let sendVerificationCode: (String) async -> Bool
    let checkVerificationCode: (String) async -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 48) {
            Text("\(email)으로 전송된\n인증코드를 입력해주세요.")
                .lineHeight(with: STFont.bold17, percentage: 145)

            VStack(alignment: .leading) {
                AnimatedTextField(label: "인증코드", placeholder: mode.placeholder, text: $verificationCode, keyboardType: mode.keyboardType, needsTimer: true, timeOut: $timeOut, remainingTime: remainingTime) {
                    Task {
                        if await sendVerificationCode(email) {
                            startTimer()
                        }
                    }
                }
                .onReceive(timer) { _ in
                    if remainingTime > 0 {
                        remainingTime -= 1
                    } else {
                        currentTimer?.cancel()
                        timeOut = true
                    }
                }

                if timeOut {
                    Text("시간이 초과되었습니다. 다시 요청해주세요.")
                        .font(STFont.regular13.font)
                        .foregroundColor(STColor.red)
                }
            }
            
            VStack(spacing: 20) {
                RoundedRectButton(label: "확인", tracking: 1.6, type: .max, disabled: verificationCode.count != mode.codeLength || timeOut) {
                    Task {
                        await checkVerificationCode(verificationCode)
                    }
                }
                
                Button {
                    showHelpAlert = true
                } label: {
                    Text("인증번호가 오지 않나요?")
                        .foregroundStyle(STColor.assistive)
                        .font(STFont.medium14.font)
                }
            }
            Spacer()
        }
        .alert("", isPresented: $showHelpAlert) {
            Button {} label: {
                Text("확인")
            }
        } message: {
            Text("전송에 시간이 소요될 수 있습니다.\n스팸함을 확인하거나,\n3분 초과 시 재요청을 해주세요.")
        }
        .navigationTitle("비밀번호 재설정")
        .navigationBarTitleDisplayMode(.inline)
        .padding(.horizontal, 20)
        .padding(.top, 44)
        .onAppear {
            startTimer()
        }
    }
}

extension VerificationCodeView {
    enum Mode {
        case signup
        case resetPassword

        var placeholder: String {
            "인증코드 \(codeLength)자리를 입력하세요"
        }

        var codeLength: Int {
            self == .signup ? 6 : 8
        }

        var keyboardType: UIKeyboardType {
            self == .signup ? .numberPad : .asciiCapable
        }
    }
}

extension VerificationCodeView {
    private func startTimer() {
        timeOut = false
        remainingTime = timeLimit
        currentTimer?.cancel()
        timer = Timer.publish(every: 1, on: .main, in: .common)
        currentTimer = timer.connect()
    }
}

struct VerifyEmailScene_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            VerificationCodeView(mode: .resetPassword, email: "example@gmail.com", timeLimit: 10) { _ in
                true
            } checkVerificationCode: { _ in
            }
        }
    }
}
