//
//  SignUpScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/10/01.
//

import SwiftUI

struct SignUpScene: View {
    @ObservedObject var viewModel: ViewModel

    @State private var id: String = ""
    @State private var password: String = ""
    @State private var password2: String = ""
    @State private var email: String = ""

    var isButtonDisabled: Bool {
        id.isEmpty || password.isEmpty || password2.isEmpty || password != password2
    }

    var body: some View {
        VStack {
            VStack(spacing: 15) {
                AnimatedTextField(label: "아이디", placeholder: "아이디를 입력하세요.", text: $id, shouldFocusOn: true)
                AnimatedTextField(label: "비밀번호", placeholder: "비밀번호를 입력하세요.", text: $password, secure: true)
                AnimatedTextField(label: "비밀번호 확인", placeholder: "비밀번호를 한번 더 입력하세요.", text: $password2, secure: true)
                AnimatedTextField(label: "이메일", placeholder: "(선택) 이메일 주소를 입력하세요.", text: $email)
            }

            Spacer()

            Button {
                Task {
                    await viewModel.registerWith(id: id, password: password, email: email)
                    resignFirstResponder()
                }
            } label: {
                Text("가입하기")
                    .padding(.vertical, 5)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(STColor.cyan)
            .disabled(isButtonDisabled)
            .animation(.customSpring, value: isButtonDisabled)
        }
        .padding()
        .navigationTitle("계정 만들기")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension SignUpScene {
    class ViewModel: BaseViewModel, ObservableObject {
        func registerWith(id: String, password: String, email: String) async {
            // TODO: Validation
            do {
                try await services.authService.registerWithId(id: id, password: password, email: email.isEmpty ? nil : email)
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }
    }
}

#if DEBUG
    struct SignUpScene_Previews: PreviewProvider {
        static var previews: some View {
            NavigationView {
                SignUpScene(viewModel: .init(container: .preview))
            }
        }
    }
#endif
