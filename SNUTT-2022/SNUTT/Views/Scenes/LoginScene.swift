//
//  LoginScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/10/02.
//

import SwiftUI

struct LoginScene: View {
    @ObservedObject var viewModel: ViewModel

    @State private var id: String = ""
    @State private var password: String = ""

    var isButtonDisabled: Bool {
        id.isEmpty || password.isEmpty
    }

    var body: some View {
        VStack {
            VStack(spacing: 15) {
                AnimatedTextField(label: "아이디", placeholder: "아이디를 입력하세요.", text: $id, shouldFocusOn: true)
                AnimatedTextField(label: "비밀번호", placeholder: "비밀번호를 입력하세요.", text: $password, secure: true)
            }

            Spacer()

            Button {
                Task {
                    await viewModel.loginWithId(id: id, password: password)
                    resignFirstResponder()
                }
            } label: {
                Text("로그인")
                    .padding(.vertical, 5)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(STColor.cyan)
            .disabled(isButtonDisabled)
            .animation(.customSpring, value: isButtonDisabled)
        }
        .padding()
        .navigationTitle("로그인")
        .navigationBarTitleDisplayMode(.inline)
    }
}

extension LoginScene {
    class ViewModel: BaseViewModel, ObservableObject {
        func loginWithId(id: String, password: String) async {
            do {
                try await services.authService.loginWithId(id: id, password: password)
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }
    }
}

struct LoginScene_Previews: PreviewProvider {
    static var previews: some View {
        LoginScene(viewModel: .init(container: .preview))
    }
}
