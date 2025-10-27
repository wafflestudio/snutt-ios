//
//  VerificationCodeScene.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

struct VerificationCodeScene: View {
    let viewModel: OnboardViewModel
    let email: String
    let mode: OnboardDetailSceneTypes.VerificationMode
    let localID: String?

    @State private var verificationCode = ""
    @State private var showHelpAlert = false
    @State private var timeOut = false
    @State private var isLoading = false

    @FocusState private var isFocused: Bool
    @Environment(\.errorAlertHandler) private var errorAlertHandler

    private var codeLength: Int {
        mode == .signup ? 6 : 8
    }

    private var placeholder: String {
        mode == .signup ? AuthStrings.verificationCodePlaceholderSignup : AuthStrings.verificationCodePlaceholderReset
    }

    private var keyboardType: UIKeyboardType {
        mode == .signup ? .numberPad : .asciiCapable
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 48) {
            Text(AuthStrings.verificationCodeDescription(email))
                .font(.system(size: 17, weight: .bold))
                .fixedSize(horizontal: false, vertical: true)

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    AnimatableTextField(
                        label: AuthStrings.verificationCodeLabel,
                        placeholder: placeholder,
                        keyboardType: keyboardType,
                        submitLabel: .done,
                        text: $verificationCode
                    )
                    .focused($isFocused)
                    .onSubmit {
                        submit()
                    }

                    Spacer().frame(width: 8)

                    TimerView(
                        initialRemainingTime: 180,
                        onRestart: {
                            errorAlertHandler.withAlert {
                                try await viewModel.sendVerificationCode(email: email)
                            }
                        },
                        onTimeout: {
                            timeOut = true
                        }
                    )
                }

                if timeOut {
                    Text(AuthStrings.verificationCodeTimeout)
                        .font(.system(size: 13))
                        .foregroundColor(SharedUIComponentsAsset.red.swiftUIColor)
                }
            }

            VStack(spacing: 20) {
                ProminentButton(
                    label: AuthStrings.verificationCodeButton,
                    isEnabled: verificationCode.count == codeLength && !timeOut && !isLoading
                ) {
                    submit()
                }

                if mode == .resetPassword {
                    Button {
                        showHelpAlert = true
                    } label: {
                        Text(AuthStrings.verificationCodeHelpButton)
                            .foregroundStyle(SharedUIComponentsAsset.assistive.swiftUIColor)
                            .font(.system(size: 14, weight: .medium))
                    }
                }
            }

            Spacer()
        }
        .onAppear {
            isFocused = true
        }
        .navigationTitle(AuthStrings.verificationCodeTitle)
        .navigationBarTitleDisplayMode(.inline)
        .padding(.horizontal, 20)
        .padding(.top, 44)
        .alert("", isPresented: $showHelpAlert) {
            Button(AuthStrings.findidButton) {}
        } message: {
            Text(AuthStrings.verificationCodeHelpMessage)
        }
    }

    private func submit() {
        errorAlertHandler.withAlert {
            isLoading = true
            defer { isLoading = false }

            if let localID {
                try await viewModel.checkVerificationCode(code: verificationCode, localID: localID)
                viewModel.paths.append(.enterNewPassword(localID: localID, verificationCode: verificationCode))
            } else {
                // For signup - verification is handled elsewhere
                // Just navigate forward
            }

            isFocused = false
        }
    }
}

#Preview {
    NavigationStack {
        VerificationCodeScene(
            viewModel: .init(),
            email: "test@snu.ac.kr",
            mode: .resetPassword,
            localID: "testuser"
        )
    }
}
