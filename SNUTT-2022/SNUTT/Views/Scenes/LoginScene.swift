//
//  LoginScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/24.
//

import SwiftUI
import AuthenticationServices

struct LoginScene: View {
    @ObservedObject var viewModel: ViewModel

    @State private var id: String = "snuttiostest123"
    @State private var password: String = "snuttiostest123"

    var body: some View {
        VStack {
            TextField("아이디", text: $id)
            TextField("비밀번호", text: $password)
            Button {
                Task {
                    try! await viewModel.container.services.authService.loginWithId(id: id, password: password)
                }
            } label: {
                Text("로그인")
            }
            .buttonStyle(.borderedProminent)
            .tint(.blue)
            
            SignInWithAppleButton { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                Task {
                    await viewModel.loginWithApple(result: result)
                }
            }
        }
    }
}

extension LoginScene {
    class ViewModel: BaseViewModel, ObservableObject {
        
        func loginWithApple(result: Result<ASAuthorization, Error>) async {
            switch result {
            case .success(let success):
                await loginWithApple(successResult: success)
            case .failure:
                services.globalUIService.presentErrorAlert(error: .WRONG_APPLE_TOKEN)
            }
        }
        
        private func loginWithApple(successResult: ASAuthorization) async {
            guard let credentail = successResult.credential as? ASAuthorizationAppleIDCredential,
                  let tokenData = credentail.identityToken,
                  let token = String(data: tokenData, encoding: .utf8) else {
                services.globalUIService.presentErrorAlert(error: .WRONG_APPLE_TOKEN)
                return
            }
            do {
                try await services.authService.loginWithApple(token: token)
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }
        
    }
}

// struct LoginScene_Previews: PreviewProvider {
//    static var previews: some View {
//        LoginScene()
//    }
// }
