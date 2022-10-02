//
//  OnboardScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/24.
//

import AuthenticationServices
import FacebookLogin
import SwiftUI

struct OnboardScene: View {
    @ObservedObject var viewModel: ViewModel
    
    @State private var pushToSignUpScene = false
    @State private var pushToLoginScene = false
    
    @Namespace private var launchScreenAnimation
    @State private var isActivated = false
    private let logoId = "Logo"
    
    var body: some View {
        ZStack {
            if isActivated {
                VStack(spacing: 15) {
                    Spacer()
                    
                    Logo(orientation: .vertical)
                        .matchedGeometryEffect(id: logoId, in: launchScreenAnimation)
                    
                    Spacer()
                    
                    VStack {
                        SignInButton(label: "로그인") {
                            pushToLoginScene = true
                            
                        }
                        SignInButton(label: "가입하기") {
                            pushToSignUpScene = true
                        }
                        
                        
                        SignInButton(label: "Facebook으로 계속하기", imageName: "facebook") {
                            viewModel.performFacebookSignIn()
                        }
                        
                        SignInButton(label: "Apple로 계속하기", imageName: "apple") {
                            viewModel.performAppleSignIn()
                        }
                    }
                    .padding(.horizontal, 20)
                    Spacer()
                        .frame(height: 20)
                }
                .transition(.scale(scale: 1))
            } else {
                VStack {
                    Spacer()
                    Logo(orientation: .vertical)
                        .matchedGeometryEffect(id: logoId, in: launchScreenAnimation)
                    Spacer()
                }
                .ignoresSafeArea()
                .transition(.scale(scale: 1))
            }
        }
        .navigationBarHidden(true)
        .background(
            Group {
                NavigationLink(destination: SignUpScene(viewModel: .init(container: viewModel.container)), isActive: $pushToSignUpScene) { EmptyView() }
                NavigationLink(destination: LoginScene(viewModel: .init(container: viewModel.container)), isActive: $pushToLoginScene) { EmptyView() }
            }
        )
        .onLoad {
            withAnimation(.easeInOut(duration: 0.7).delay(0.1)) {
                isActivated = true
            }
        }
    }
}

struct SignInButton: View {
    let label: String
    var imageName: String? = nil
    var borderColor: Color = Color(uiColor: .tertiaryLabel)
    var fontColor: Color = Color(uiColor: .label)
    var action: (() -> Void)? = nil
    
    var body: some View {
        Button {
            action?()
        } label: {
            Text(label)
                .font(.system(size: 17, weight: .semibold))
                .frame(maxWidth: .infinity)
                .foregroundColor(fontColor)
                .contentShape(Rectangle())
                .padding(.vertical, 10)
                .overlay(HStack {
                    if let imageName = imageName {
                        Image(imageName)
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding()
                    }
                    Spacer()
                })
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(borderColor, lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

extension OnboardScene {
    class ViewModel: BaseViewModel, ObservableObject {
        func performFacebookSignIn() {
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
                      let fbToken = result.token?.tokenString
                else {
                    self.services.globalUIService.presentErrorAlert(error: .NO_FB_ID_OR_TOKEN)
                    return
                }
                
                Task {
                    await self.loginWithFacebook(id: fbUserId, token: fbToken)
                }
            }
        }
        
        private func loginWithFacebook(id: String, token: String) async {
            do {
                try await services.authService.loginWithFacebook(id: id, token: token)
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }
        
        
    }
}


extension OnboardScene.ViewModel: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        Task {
            await loginWithApple(successResult: authorization)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        services.globalUIService.presentErrorAlert(error: .WRONG_APPLE_TOKEN)
    }
    
    func performAppleSignIn() {
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.performRequests()
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

#if DEBUG
struct OnboardScene_Previews: PreviewProvider {
    static var previews: some View {
        OnboardScene(viewModel: .init(container: .preview))
    }
}
#endif
