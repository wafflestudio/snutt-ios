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
                        .frame(height: 200)

                    Logo(orientation: .vertical)
                        .matchedGeometryEffect(id: logoId, in: launchScreenAnimation)

                    VStack {
                        Spacer()

                        Button {
                            pushToLoginScene = true
                        } label: {
                            Text("로그인")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, maxHeight: 41)
                                .background(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .foregroundColor(STColor.cyan)
                                )
                        }
                        .padding(.horizontal, 32)

                        Button {
                            pushToSignUpScene = true
                        } label: {
                            Text("회원가입")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.init(uiColor: .label))
                                .padding(.top, 12)
                                .padding(.bottom, 40)
                        }

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
                        .padding(.bottom, 24)

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

                        Spacer()
                    }
                    .padding(.horizontal, 12)
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

#if DEBUG
    struct OnboardScene_Previews: PreviewProvider {
        static var previews: some View {
            OnboardScene(viewModel: .init(container: .preview), pushToTimetableScene: .constant(true))
        }
    }
#endif
