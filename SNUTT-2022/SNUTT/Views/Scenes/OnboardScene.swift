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
    @State private var pushToFeedbackView = false
    @Binding var pushToTimetableScene: Bool

    @Namespace private var launchScreenAnimation
    @State private var isActivated = false
    private let logoId = "Logo"

    var body: some View {
        ZStack {
            if isActivated {
                GeometryReader { proxy in
                    VStack(spacing: 0) {
                        Spacer()

                        Logo(orientation: .vertical)
                            .matchedGeometryEffect(id: logoId, in: launchScreenAnimation)
                        
                        Spacer().frame(height: proxy.size.height * 0.16)

                        VStack(spacing: 0) {
                            VStack(spacing: 14) {
                                Button {
                                    pushToLoginScene = true
                                } label: {
                                    Text("로그인")
                                        .font(.system(size: 15, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(.vertical, 12)
                                        .frame(maxWidth: .infinity)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                                .foregroundColor(STColor.cyan)
                                        )
                                }
                                .padding(.horizontal, 20)
                                
                                Button {
                                    pushToSignUpScene = true
                                } label: {
                                    Text("회원가입")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(STColor.darkerGray)
                                }
                            }
                            
                            Spacer().frame(height: proxy.size.height * 0.07)

                            HStack(spacing: 10) {
                                Rectangle()
                                    .fill(STColor.gray20)
                                    .frame(height: 1)
                                Text("SNS 계정으로 계속하기")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(STColor.gray20)
                                    .fixedSize(horizontal: true, vertical: false)
                                Rectangle()
                                    .fill(STColor.gray20)
                                    .frame(height: 1)
                            }
                            
                            Spacer().frame(height: 24)

                            HStack(spacing: 12) {
                                Button {
                                    viewModel.performKakaoSignIn()
                                } label: {
                                    Image("sns.kakao")
                                }
                                Button {
                                    viewModel.performGoogleSignIn()
                                } label: {
                                    Image("sns.google")
                                }
                                Button {
                                    viewModel.performFacebookSignIn()
                                } label: {
                                    Image("sns.facebook")
                                }
                                Button {
                                    viewModel.performAppleSignIn()
                                } label: {
                                    Image("sns.apple")
                                }
                            }

                            Spacer().frame(height: proxy.size.height * 0.06)
                            
                            Button {
                                pushToFeedbackView = true
                            } label: {
                                Text("로그인/회원가입에 문제가 생겼나요?")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(STColor.gray2)
                            }
                        }
                        .padding(.horizontal, 12)
                        
                        Spacer().frame(height: proxy.size.height * 0.05)
                    }
                    .transition(.scale(scale: 1))
                }
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
                
                NavigationLink(destination: UserSupportView(email: nil, sendFeedback: viewModel.sendFeedback(email:message:)), isActive: $pushToFeedbackView) { EmptyView() }
            }
        )
        .onLoad {
            withAnimation(.easeInOut(duration: 0.7).delay(0.1)) {
                isActivated = true
            }
        }
    }
}

#if DEBUG
    struct OnboardScene_Previews: PreviewProvider {
        static var previews: some View {
            OnboardScene(viewModel: .init(container: .preview), pushToTimetableScene: .constant(true))
        }
    }
#endif
