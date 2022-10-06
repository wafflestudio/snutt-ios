//
//  ChangePasswordView.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/10/03.
//

import SwiftUI

struct ChangePasswordView: View {
    var changePassword: (String, String) async -> Bool // old, new -> success

    @State private var oldPassword: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @Environment(\.presentationMode) private var mode

    var isButtonDisabled: Bool {
        oldPassword.isEmpty || password.isEmpty || confirmPassword.isEmpty || password != confirmPassword
    }

    var body: some View {
        Form {
            Section(header: Text("이전 비밀번호")) {
                SecureField("필수사항", text: $oldPassword)
            }

            Section(header: Text("새로운 비밀번호")) {
                SecureField("비밀번호", text: $password)
                SecureField("비밀번호 확인", text: $confirmPassword)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("비밀번호 변경")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    Task {
                        let success = await changePassword(oldPassword, password)
                        if success {
                            mode.wrappedValue.dismiss()
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
        ChangePasswordView { old, new in
            print(old, new)
            return true
        }
    }
}
