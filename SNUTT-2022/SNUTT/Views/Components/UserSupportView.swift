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
    @State private var hasEmail: Bool = false
    @State private var alertSendFeedback: Bool = false
    @State private var isLoading: Bool = false
    @FocusState private var isFocused: Bool
    @Environment(\.presentationMode) private var mode

    init(email: String?, sendFeedback: @escaping (String, String) async -> Bool) {
        self.sendFeedback = sendFeedback
        _email = .init(initialValue: email ?? "")
        if let email = email {
            _hasEmail = .init(initialValue: !email.isEmpty)
        }
    }

    var isButtonDisabled: Bool {
        email.isEmpty || content.isEmpty
    }

    var body: some View {
        Form {
            Section(header: Text("이메일 주소")) {
                TextField("이메일", text: $email)
                    .foregroundColor(hasEmail ? .secondary : .primary)
                    .disabled(hasEmail)
            }
            Section(header: Text("문의 내용"), footer: Text("불편한 점이나 버그를 제보해주세요.\n더 나은 SNUTT를 위한 아이디어도 환영해요.")) {
                TextEditor(text: $content)
                    .frame(minHeight: 300)
                    .focused($isFocused)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("개발자 괴롭히기")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if isLoading {
                    ProgressView()
                } else {
                    Button {
                        alertSendFeedback = true
                    } label: {
                        Text("전송")
                    }
                    .disabled(isButtonDisabled)
                }
            }

            ToolbarItemGroup(placement: .keyboard) {
                Spacer()

                Button("완료") {
                    isFocused = false
                }
            }
        }
        .analyticsScreen(.settingsSupport)
        .alert("개발자 괴롭히기", isPresented: $alertSendFeedback) {
            Button("취소", role: .cancel, action: {})
            Button("전송", role: .none, action: {
                isLoading = true
                Task {
                    let success = await sendFeedback(email, content)
                    if success {
                        mode.wrappedValue.dismiss()
                    }
                    isLoading = false
                }
            })
        } message: {
            Text("피드백을 전송하시겠습니까?")
        }
    }
}

struct UserSupportScene_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            UserSupportView(email: "snutt@wafflestudio.com") { _, _ in
                true
            }
        }
    }
}
