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
    @State private var timeOut: Bool = false
    @State private var remainingTime: Int = 0

    @State private var timer = Timer.publish(every: 1, on: .main, in: .common)
    @State private var currentTimer: Cancellable? = nil

    let email: String
    let timeLimit: Int
    let sendVerificationCode: (String) async -> Bool
    let checkVerificationCode: (String) async -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Spacer().frame(height: 15)

            Text("\(email)으로 전송된\n인증코드를 입력해주세요.")
                .fixedSize()
                .font(STFont.title)

            Spacer().frame(height: 8)

            VStack(alignment: .leading) {
                AnimatedTextField(label: "인증코드", placeholder: "인증코드 8자리를 입력하세요", text: $verificationCode, needsTimer: true, timeOut: $timeOut, remainingTime: remainingTime) {
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
                    Text("시간이 초과되었습니다. 다시 시도해주세요.")
                        .font(.system(size: 12, weight: .light))
                        .foregroundColor(STColor.red)
                }
            }

            Spacer().frame(height: 10)

            Button {
                Task {
                    await checkVerificationCode(verificationCode)
                }
            } label: {
                Text("확인")
                    .font(STFont.title)
                    .frame(maxWidth: .infinity)
                    .frame(height: 40)
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 0))
            .tint(STColor.cyan)
            .disabled(verificationCode.count != 8 || timeOut)

            Spacer()
        }
        .navigationTitle("인증코드 입력")
        .navigationBarTitleDisplayMode(.inline)
        .padding(.horizontal, 20)
        .onAppear {
            startTimer()
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
            VerificationCodeView(email: "example@gmail.com", timeLimit: 10) { _ in
                print("sendVerificationCode")
                return true
            } checkVerificationCode: { _ in
                print("checkVerificationCode")
                // return true
            }
        }
    }
}
