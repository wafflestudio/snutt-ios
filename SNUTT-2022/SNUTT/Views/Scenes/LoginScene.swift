//
//  LoginScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/10/02.
//

import SwiftUI

struct LoginScene: View {
    @ObservedObject var viewModel: ViewModel

    @State private var localId: String = ""
    @State private var localPassword: String = ""

    var isButtonDisabled: Bool {
        localId.isEmpty || localPassword.isEmpty
    }

    var body: some View {
        VStack {
            VStack(spacing: 15) {
                AnimatedTextField(label: "아이디", placeholder: "아이디를 입력하세요.", text: $localId, shouldFocusOn: true)
                AnimatedTextField(label: "비밀번호", placeholder: "비밀번호를 입력하세요.", text: $localPassword, secure: true)
            }

            Spacer()

            Button {
                Task {
                    await viewModel.loginWithLocalId(localId: localId, localPassword: localPassword)
                    resignFirstResponder()
                }
            } label: {
                Text("로그인")
                    .padding(.vertical, 5)
                    .font(.system(size: 17, weight: .semibold))
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
        func loginWithLocalId(localId: String, localPassword: String) async {
            do {
                try await services.authService.loginWithLocalId(localId: localId, localPassword: localPassword)
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }
    }
}

#if DEBUG
    struct LoginScene_Previews: PreviewProvider {
        static var previews: some View {
            LoginScene(viewModel: .init(container: .preview))
        }
    }
#endif
