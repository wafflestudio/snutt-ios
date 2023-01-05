//
//  ChangePasswordView.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/10/03.
//

import SwiftUI

struct ChangePasswordView: View {
    var resetMode: Bool = false

    /// old, new -> success
    var changePassword: (String, String) async -> Bool = { _, _ in true }
    /// new -> success
    var resetPassword: (String) async -> Bool = { _ in true }

    @State private var oldPassword: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showConfirmAlert: Bool = false
    @Environment(\.presentationMode) private var mode

    var isButtonDisabled: Bool {
        if resetMode {
            return password.isEmpty || confirmPassword.isEmpty || password != confirmPassword
        } else {
            return oldPassword.isEmpty || password.isEmpty || confirmPassword.isEmpty || password != confirmPassword
        }
    }

    var body: some View {
        Form {
            if !resetMode {
                Section(header: Text("이전 비밀번호")) {
                    SecureField("필수사항", text: $oldPassword)
                }
            }

            Section(header: Text("새로운 비밀번호")) {
                SecureField("영문, 숫자 모두 포함 6-20자 이내", text: $password)
                SecureField("비밀번호를 한번 더 입력하세요", text: $confirmPassword)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(resetMode ? "비밀번호 재설정" : "비밀번호 변경")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    Task {
                        showConfirmAlert = await resetMode
                            ? resetPassword(password)
                            : changePassword(oldPassword, password)
                    }
                } label: {
                    Text("저장")
                }
                .disabled(isButtonDisabled)
            }
        }
        .alert("완료", isPresented: $showConfirmAlert) {
            Button("확인") {
                mode.wrappedValue.dismiss()
            }
        } message: {
            Text(resetMode
                ? "비밀번호가 재설정되었습니다."
                : "비밀번호가 변경되었습니다.")
        }
    }
}

struct ChangePasswordView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePasswordView(changePassword: { old, new in
            print(old, new)
            return true
        })
    }
}
