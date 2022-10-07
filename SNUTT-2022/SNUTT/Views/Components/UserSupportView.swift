//
//  UserSupportView.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/19.
//

import SwiftUI

struct UserSupportView: View {
    var sendFeedback: (String, String) async -> Bool // email, message -> success
    
    @State private var email: String = ""
    @State private var content: String = ""
    @State private var alertSendFeedback: Bool = false
    @Environment(\.presentationMode) private var mode
    
    var isButtonDisabled: Bool {
        email.isEmpty || content.isEmpty
    }
    
    var body: some View {
        Form {
            Section(header: Text("이메일 주소")) {
                TextField("이메일", text: $email)
            }
            Section(header: Text("문의 내용"), footer: Text("불편한 점이나 버그를 제보해주세요.")) {
                TextEditor(text: $content)
                    .frame(minHeight: 300)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("개발자 괴롭히기")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    alertSendFeedback = true
                } label: {
                    Text("전송")
                }
                .disabled(isButtonDisabled)
            }
        }
        .alert("개발자 괴롭히기", isPresented: $alertSendFeedback) {
            Button("취소", role: .cancel, action: {})
            Button("전송", role: .none, action: {
                Task {
                    let success = await sendFeedback(email, content)
                    if success {
                        mode.wrappedValue.dismiss()
                    }
                }
            })
        } message: {
            Text("피드백을 전송하시겠습니까?")
        }
    }
}

struct UserSupportScene_Previews: PreviewProvider {
    static var previews: some View {
        UserSupportView { email, message in
            return true
        }
    }
}
