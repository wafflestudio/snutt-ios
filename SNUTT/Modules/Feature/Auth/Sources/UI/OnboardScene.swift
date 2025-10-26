//
//  OnboardScene.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import MemberwiseInit
import SharedUIComponents
import SwiftUI

public struct OnboardScene: View {
    @State private var viewModel = OnboardViewModel()
    @Environment(\.errorAlertHandler) private var errorAlertHandler

    public init() {}

    public var body: some View {
        NavigationStack(path: $viewModel.paths) {
            GeometryReader { proxy in
                VStack(spacing: 0) {
                    Spacer()

                    Logo(orientation: .vertical)

                    Spacer().frame(height: proxy.size.height * 0.16)

                    VStack(spacing: 0) {
                        VStack(spacing: 8) {
                            ProminentButton(label: AuthStrings.onboardLoginButton) {
                                viewModel.paths.append(.loginLocal)
                            }

                            ProminentButton(
                                label: AuthStrings.onboardSignupButton,
                                font: .systemFont(ofSize: 14, weight: .semibold),
                                foregroundColor: SharedUIComponentsAsset.darkerGray.swiftUIColor,
                                backgroundColor: .clear
                            ) {
                                viewModel.paths.append(.registerLocal)
                            }
                        }
                        .padding(.horizontal, 20)

                        Spacer().frame(height: proxy.size.height * 0.07)

                        HStack(spacing: 10) {
                            Rectangle()
                                .fill(SharedUIComponentsAsset.assistive.swiftUIColor)
                                .frame(height: 1)
                            Text(AuthStrings.onboardSnsContinue)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(SharedUIComponentsAsset.assistive.swiftUIColor)
                                .fixedSize(horizontal: true, vertical: false)
                            Rectangle()
                                .fill(SharedUIComponentsAsset.assistive.swiftUIColor)
                                .frame(height: 1)
                        }

                        Spacer().frame(height: 24)

                        HStack(spacing: 12) {
                            SocialLoginButton(asset: AuthAsset.snsKakao.swiftUIImage) {
                                errorAlertHandler.withAlert {
                                    try await viewModel.loginWithSocialProvider(provider: .kakao)
                                }
                            }

                            SocialLoginButton(asset: AuthAsset.snsGoogle.swiftUIImage) {
                                errorAlertHandler.withAlert {
                                    try await viewModel.loginWithSocialProvider(provider: .google)
                                }
                            }

                            SocialLoginButton(asset: AuthAsset.snsFacebook.swiftUIImage) {
                                errorAlertHandler.withAlert {
                                    try await viewModel.loginWithSocialProvider(provider: .facebook)
                                }
                            }

                            SocialLoginButton(asset: AuthAsset.snsApple.swiftUIImage) {
                                errorAlertHandler.withAlert {
                                    try await viewModel.loginWithSocialProvider(provider: .apple)
                                }
                            }
                        }

                        Spacer().frame(height: proxy.size.height * 0.06)

                        ProminentButton(
                            label: AuthStrings.onboardFeedbackButton,
                            font: .systemFont(ofSize: 14, weight: .semibold),
                            foregroundColor: SharedUIComponentsAsset.gray2.swiftUIColor,
                            backgroundColor: .clear
                        ) {
                            viewModel.paths.append(.userSupport)
                        }
                        .padding(.horizontal, 20)
                    }
                    .padding(.horizontal, 12)

                    Spacer().frame(height: proxy.size.height * 0.05)
                }
            }
            .navigationBarHidden(true)
            .navigationDestination(for: OnboardDetailSceneTypes.self) { sceneType in
                switch sceneType {
                case .loginLocal:
                    LoginScene(viewModel: viewModel)
                case .registerLocal:
                    RegisterLocalIDScene(viewModel: viewModel)
                case .findLocalID:
                    FindLocalIDScene(viewModel: viewModel)
                case .resetLocalPassword:
                    ResetPasswordScene(viewModel: viewModel)
                case let .verificationCode(email, mode, localID):
                    VerificationCodeScene(viewModel: viewModel, email: email, mode: mode, localID: localID)
                case let .enterNewPassword(localID, verificationCode):
                    EnterNewPasswordScene(viewModel: viewModel, localID: localID, verificationCode: verificationCode)
                case let .emailVerification(email):
                    EmailVerificationPromptScene(viewModel: viewModel, email: email)
                case .userSupport:
                    UserSupportScene(viewModel: viewModel)
                case .termsOfService:
                    RegisterTermsOfServiceView()
                }
            }
        }
        .analyticsScreen(.onboard)
    }
}

private struct SocialLoginButton: View {
    let asset: Image
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            asset
                .resizable()
                .frame(width: 48, height: 48)
        }
    }
}

#Preview {
    OnboardScene()
}
