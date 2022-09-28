//
//  LoginScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/24.
//

import AuthenticationServices
import SwiftUI
import FacebookLogin

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
            
            Button {
                viewModel.loginWithFacebook()
            } label: {
                Text("페이스북으로 로그인")
            }

        }
    }
}

extension LoginScene {
    class ViewModel: BaseViewModel, ObservableObject {
        func loginWithApple(result: Result<ASAuthorization, Error>) async {
            switch result {
            case let .success(success):
                await loginWithApple(successResult: success)
            case .failure:
                services.globalUIService.presentErrorAlert(error: .WRONG_APPLE_TOKEN)
            }
        }
        
        func loginWithFacebook() {
            LoginManager().logIn(permissions: [Permission.publicProfile.name], from: nil) { result, error in
                
                if error != nil {
                    self.services.globalUIService.presentErrorAlert(error: .NO_FB_ID_OR_TOKEN)
                    return
                }
                
                guard let result = result else {
                    self.services.globalUIService.presentErrorAlert(error: .NO_FB_ID_OR_TOKEN)
                    return
                }
                
                if result.isCancelled {
                    return
                }
                
                guard let fbUserId = result.token?.userID,
                      let fbToken = result.token?.tokenString else {
                    self.services.globalUIService.presentErrorAlert(error: .NO_FB_ID_OR_TOKEN)
                    return
                }
                
                Task {
                    await self.loginWithFacebook(id: fbUserId, token: fbToken)
                }
            }
        }
        
        private func loginWithFacebook(id:String,token:String) async {
            do {
                try await services.authService.loginWithFacebook(id: id, token: token)
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }
        
        private func loginWithApple(successResult: ASAuthorization) async {
            guard let credentail = successResult.credential as? ASAuthorizationAppleIDCredential,
                  let tokenData = credentail.identityToken,
                  let token = String(data: tokenData, encoding: .utf8)
            else {
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

#if DEBUG
 struct LoginScene_Previews: PreviewProvider {
    static var previews: some View {
        LoginScene(viewModel: .init(container: .preview))
    }
 }
#endif
