//
//  ChangePasswordView.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/10/03.
//

import SwiftUI

struct ChangePasswordView: View {
    var initializingPassword: Bool = false

    /// old, new -> success
    var changePassword: (String, String) async -> Bool = { _, _ in true }
    /// localId, new -> success
    var resetPassword: (String) async -> Void = { _ in }

    @State private var oldPassword: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @Environment(\.presentationMode) private var mode

    var isButtonDisabled: Bool {
        if initializingPassword {
            return password.isEmpty || confirmPassword.isEmpty || password != confirmPassword
        } else {
            return oldPassword.isEmpty || password.isEmpty || confirmPassword.isEmpty || password != confirmPassword
        }
    }

    var body: some View {
        Form {
            if !initializingPassword {
                Section(header: Text("이전 비밀번호")) {
                    SecureField("필수사항", text: $oldPassword)
                }
            }

            Section(header: Text("새로운 비밀번호")) {
                SecureField("비밀번호", text: $password)
                SecureField("비밀번호 확인", text: $confirmPassword)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(initializingPassword ? "비밀번호 재설정" : "비밀번호 변경")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    Task {
                        if !initializingPassword {
                            let success = await changePassword(oldPassword, password)
                            if success {
                                mode.wrappedValue.dismiss()
                            }
                        } else {
                            await resetPassword(password)
                        }
                    }
                } label: {
                    Text("저장")
                }
                .disabled(isButtonDisabled)
            }
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
