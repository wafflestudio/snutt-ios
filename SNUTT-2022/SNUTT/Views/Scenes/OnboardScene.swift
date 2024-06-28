//
//  OnboardScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/24.
//

import SwiftUI

struct OnboardScene: View {
    @ObservedObject var viewModel: ViewModel

    @State private var pushToSignUpScene = false
    @State private var pushToLoginScene = false
    @Binding var pushToTimetableScene: Bool

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
                        
                        SignInButton(label: "Google로 계속하기", imageName: "apple") {
                                                   viewModel.performGoogleSignIn()
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
                NavigationLink(destination: SignUpView(registerLocalId: viewModel.registerWith(id:password:email:), sendVerificationCode: viewModel.sendVerificationCode(email:), checkVerificationCode: viewModel.submitVerificationCode(code:), pushToTimetableScene: $pushToTimetableScene), isActive: $pushToSignUpScene) { EmptyView() }

                NavigationLink(destination: LoginScene(viewModel: .init(container: viewModel.container), moveToTimetableScene: $pushToTimetableScene), isActive: $pushToLoginScene) { EmptyView() }
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
    var borderColor: Color = .init(uiColor: .tertiaryLabel)
    var fontColor: Color = .init(uiColor: .label)
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

#if DEBUG
    struct OnboardScene_Previews: PreviewProvider {
        static var previews: some View {
            OnboardScene(viewModel: .init(container: .preview), pushToTimetableScene: .constant(true))
        }
    }
#endif
