//
//  EnterNewPasswordView.swift
//  SNUTT
//
//  Created by 최유림 on 11/13/24.
//

import Combine
import SwiftUI

struct EnterNewPasswordView: View {
    
    @Binding var returnToEmailVerification: Bool
    
    /// new -> success
    let resetPassword: (String) async -> Bool
    
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showConfirmAlert: Bool = false
    @State private var didResetPassword: Bool = false
    
    @State private var timeOut: Bool = false
    @State private var remainingTime: Int = 0

    @State private var timer = Timer.publish(every: 1, on: .main, in: .common)
    @State private var currentTimer: Cancellable? = nil
    
    /// Time limitation for entering verification code. 180 seconds by default.
    @State private var timeLimit: Int = 180
    
    @Environment(\.dismiss) private var dismiss
    
    var disableButton: Bool {
        password.isEmpty || confirmPassword.isEmpty
    }
    
    var passwordEquals: Bool {
        password == confirmPassword
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 48) {
            VStack(alignment: .leading, spacing: 40) {
                Text("새로운 비밀번호를 입력해주세요.")
                    .lineHeight(with: STFont.bold17, percentage: 145)

                VStack(spacing: 24) {
                    AnimatedTextField(placeholder: "영문, 숫자 모두 포함 6-20자 이내", text: $password, shouldFocusOn: true, secure: true, needsTimer: true, remainingTime: remainingTime)
                        .onReceive(timer) { _ in
                            if remainingTime > 0 {
                                remainingTime -= 1
                            } else {
                                currentTimer?.cancel()
                                timeOut = true
                            }
                        }
                    
                    AnimatedTextField(placeholder: "비밀번호를 한번 더 입력하세요", text: $confirmPassword, secure: true)
                }
            }
            RoundedRectButton(label: "확인",
                              tracking: 1.6,
                              type: .max,
                              disabled: disableButton) {
                Task {
                    if !passwordEquals || !Validation.check(password: password) {
                        showConfirmAlert = true
                        return
                    }
                    didResetPassword = await resetPassword(password)
                    if didResetPassword {
                        showConfirmAlert = true
                    }
                }
            }
            Spacer()
        }
        .navigationTitle("비밀번호 재설정")
        .navigationBarTitleDisplayMode(.inline)
        .padding(.top, 44)
        .padding(.horizontal, 20)
        .alert("시간 초과", isPresented: $timeOut) {
            Button("확인") {
                returnToEmailVerification = true
                //dismiss()
            }
        } message: {
            Text("시간이 초과되어\n인증코드 재입력이 필요합니다.")
        }
        .alert("", isPresented: $showConfirmAlert) {
            Button("확인") {
                if didResetPassword {
                    dismiss()
                }
            }
        } message: {
            if !passwordEquals {
                Text("비밀번호가 일치하지 않습니다.\n다시 시도해주세요.")
            } else if Validation.check(password: password) {
                Text("조건에 맞지 않는 비밀번호입니다.\n영문, 숫자 포함 6-20자 이내로 입력해주세요.")
            } else {
                Text("비밀번호가 변경되었습니다.")
            }
        }
        .onAppear {
            startTimer()
        }
    }
}

extension EnterNewPasswordView {
    private func startTimer() {
        timeOut = false
        remainingTime = timeLimit
        currentTimer?.cancel()
        timer = Timer.publish(every: 1, on: .main, in: .common)
        currentTimer = timer.connect()
    }
}
