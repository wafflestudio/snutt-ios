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
    
    enum FocusedField {
        case email, content
    }
    
    @FocusState private var focusedField: FocusedField?
    
    @State var showEmailValidationError: Bool = false
    
    var body: some View {
        Form {
            Section(header: Text("이메일 주소"), footer: Group {
                if showEmailValidationError {
                    Text("유효한 이메일 형식이 아닙니다.")
                        .foregroundColor(.red)
                }
            }) {
                TextField("이메일", text: $email)
                    .focused($focusedField, equals: .email)
                    .onSubmit {
                        focusedField = .content
                    }
            }
            Section(header: Text("문의 내용"), footer: Text("불편한 점이나 버그를 제보해주세요.")) {
                TextEditor(text: $content)
                    .focused($focusedField, equals: .content)
                    .frame(minHeight: 200)
            }
        }
        .onChange(of: focusedField, perform: { newValue in
            if newValue == .content {
                showEmailValidationError = !Validation.check(email: email)
            }
        })
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
                    showEmailValidationError = !Validation.check(email: email)
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
        UserSupportView { _, _ in
            true
        }
    }
}
