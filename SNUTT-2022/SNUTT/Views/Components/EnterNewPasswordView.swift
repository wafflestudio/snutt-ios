//
//  EnterNewPasswordView.swift
//  SNUTT
//
//  Created by 최유림 on 11/13/24.
//

import SwiftUI

struct EnterNewPasswordView: View {
    
    @Binding var returnToEmailVerification: Bool
    @Binding var returnToLogin: Bool
    
    /// new -> success
    let resetPassword: (String) async -> Bool
    let initialTime = 180
    
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    
    @State private var showErrorAlert: Bool = false
    @State private var errorState: ErrorState = .none
    
    @State private var timeOut: Bool = false
    @State private var remainingTime: Int = 0
    
    @Environment(\.dismiss) private var dismiss
    
    var disableButton: Bool {
        password.isEmpty || confirmPassword.isEmpty
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 48) {
            VStack(alignment: .leading, spacing: 40) {
                Text("새로운 비밀번호를 입력해주세요.")
                    .lineHeight(with: STFont.bold17, percentage: 145)
                VStack(spacing: 24) {
                    AnimatedTextField(placeholder: "영문, 숫자 모두 포함 6-20자 이내", text: $password, shouldFocusOn: true, secure: true, needsTimer: true, timeOut: $timeOut, remainingTime: $remainingTime)
                        .timer(initialTime: initialTime, timeOut: $timeOut, remainingTime: $remainingTime)
                    AnimatedTextField(placeholder: "비밀번호를 한번 더 입력하세요", text: $confirmPassword, secure: true)
                }
            }
            RoundedRectButton(label: "확인",
                              tracking: 1.6,
                              type: .max,
                              disabled: disableButton) {
                Task {
                    if password != confirmPassword {
                        errorState = .passwordNotEqual
                        showErrorAlert = true
                    } else if !Validation.check(password: password) {
                        errorState = .passwordNotValid
                        showErrorAlert = true
                    } else if await resetPassword(password) {
                        errorState = .none
                        showErrorAlert = true
                    }
                }
            }
            Spacer()
        }
        .navigationTitle("비밀번호 재설정")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    errorState = .backGesture
                    showErrorAlert = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                        Text("아이디 입력")
                    }
                    .padding(.leading, -8)
                }
            }
        }
        .padding(.top, 44)
        .padding(.horizontal, 20)
        .alert("", isPresented: $showErrorAlert) {
            Button("확인") {
                if errorState == .none || errorState == .backGesture {
                    returnToLogin = true
                    dismiss()
                }
            }
            if errorState == .backGesture {
                Button("취소", role: .cancel) {}
            }
        } message: {
            Text(errorState.message)
        }
        .alert("시간 초과", isPresented: $timeOut) {
            Button("확인") {
                returnToEmailVerification = true
            }
        } message: {
            Text("시간이 초과되어\n인증코드 재입력이 필요합니다.")
        }
    }
}

extension EnterNewPasswordView {
    private enum ErrorState {
        case passwordNotEqual
        case passwordNotValid
        case backGesture
        case none
        
        var message: String {
            switch self {
            case .passwordNotEqual: "비밀번호가 일치하지 않습니다.\n다시 시도해주세요."
            case .passwordNotValid: "조건에 맞지 않는 비밀번호입니다.\n영문, 숫자 포함 6-20자 이내로\n입력해주세요."
            case .backGesture: "비밀번호 초기화를 그만두고 처음으로 돌아가시겠습니까?"
            case .none: "비밀번호가 변경되었습니다."
            }
        }
    }
}
