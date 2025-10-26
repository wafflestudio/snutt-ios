//
//  ResetPasswordScene.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

struct ResetPasswordScene: View {
    let viewModel: OnboardViewModel

    @State private var localID = ""
    @State private var email = ""
    @State private var maskedEmail = ""
    @State private var currentStep: Step = .enterID
    @State private var isLoading = false

    @FocusState private var focusedField: Field?
    @Environment(\.errorAlertHandler) private var errorAlertHandler

    private enum Step {
        case enterID
        case enterEmail

        var navigationTitle: String {
            AuthStrings.resetPasswordTitle
        }
    }

    private enum Field: Hashable {
        case localID
        case email
    }

    private var titleText: String {
        switch currentStep {
        case .enterID:
            return AuthStrings.resetPasswordIdTitle
        case .enterEmail:
            return AuthStrings.resetPasswordEmailTitle
        }
    }

    private var buttonLabel: String {
        switch currentStep {
        case .enterID:
            return AuthStrings.findidButton
        case .enterEmail:
            return AuthStrings.resetPasswordCodeButton
        }
    }

    private var isButtonEnabled: Bool {
        switch currentStep {
        case .enterID:
            return !localID.isEmpty && !isLoading
        case .enterEmail:
            return !email.isEmpty && !isLoading
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 40) {
                Text(titleText)
                    .font(.system(size: 17, weight: .bold))
                    .fixedSize(horizontal: false, vertical: true)

                AnimatableTextField(
                    label: AuthStrings.resetPasswordIdLabel,
                    placeholder: AuthStrings.resetPasswordIdPlaceholder,
                    text: $localID
                )
                .focused($focusedField, equals: .localID)
                .disabled(currentStep == .enterEmail)
                .onSubmit {
                    if currentStep == .enterID {
                        submit()
                    }
                }

                if currentStep == .enterEmail {
                    VStack(alignment: .leading, spacing: 12) {
                        AnimatableTextField(
                            label: AuthStrings.resetPasswordEmailLabel,
                            placeholder: AuthStrings.resetPasswordEmailPlaceholder,
                            keyboardType: .emailAddress,
                            submitLabel: .done,
                            text: $email
                        )
                        .focused($focusedField, equals: .email)
                        .onSubmit {
                            submit()
                        }

                        Text(maskedEmail)
                            .font(.system(size: 15))
                            .foregroundStyle(SharedUIComponentsAsset.alternative.swiftUIColor)
                    }
                }
            }

            Spacer().frame(height: 48)

            VStack(spacing: 20) {
                ProminentButton(label: buttonLabel, isEnabled: isButtonEnabled) {
                    submit()
                }

                if currentStep == .enterEmail {
                    Button {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentStep = .enterID
                            maskedEmail = ""
                            email = ""
                            focusedField = .localID
                        }
                    } label: {
                        Text(AuthStrings.resetPasswordNotMyEmail)
                            .foregroundStyle(SharedUIComponentsAsset.assistive.swiftUIColor)
                            .font(.system(size: 14, weight: .medium))
                    }
                }
            }

            Spacer()
        }
        .navigationTitle(currentStep.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .padding(.top, 44)
        .padding(.horizontal, 20)
        .onAppear {
            currentStep = .enterID
            focusedField = .localID
        }
    }

    private func submit() {
        errorAlertHandler.withAlert {
            isLoading = true
            defer { isLoading = false }

            if currentStep == .enterID {
                let linkedEmail = try await viewModel.getLinkedEmail(localID: localID)
                focusedField = nil

                withAnimation(.easeInOut(duration: 0.3)) {
                    maskedEmail = linkedEmail
                    currentStep = .enterEmail
                    focusedField = .email
                }
            } else {
                try await viewModel.sendVerificationCode(email: email)
                viewModel.paths.append(.verificationCode(email: email, mode: .resetPassword, localID: localID))
            }
        }
    }
}

#Preview {
    NavigationStack {
        ResetPasswordScene(viewModel: .init())
    }
}
