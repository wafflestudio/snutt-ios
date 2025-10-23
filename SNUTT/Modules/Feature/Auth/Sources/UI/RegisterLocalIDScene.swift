//
//  RegisterLocalIDScene.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import FoundationUtility
import SharedUIComponents
import SwiftUI

struct RegisterLocalIDScene: View {
    let viewModel: OnboardViewModel

    @State private var localID = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var emailUserName = ""

    @State private var showCompletionAlert = false
    @State private var isLoading = false

    @FocusState private var focusedField: TextFieldType?
    @Environment(\.errorAlertHandler) private var errorAlertHandler
    @Environment(\.dismiss) private var dismiss

    private enum TextFieldType: Hashable {
        case localID
        case password
        case confirmPassword
        case email
    }

    private let emailDomain = "@snu.ac.kr"

    private var emailFullAddress: String {
        emailUserName + emailDomain
    }

    var isSubmitButtonEnabled: Bool {
        !localID.isEmpty && !password.isEmpty && !confirmPassword.isEmpty && !emailUserName.isEmpty && !isLoading
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            AnimatableTextField(
                label: AuthStrings.signupIdLabel,
                placeholder: AuthStrings.signupIdPlaceholder,
                text: $localID
            )
            .focused($focusedField, equals: .localID)
            .onSubmit {
                focusedField = .password
            }

            AnimatableTextField(
                label: AuthStrings.signupPasswordLabel,
                placeholder: AuthStrings.signupPasswordPlaceholder,
                secure: true,
                text: $password
            )
            .focused($focusedField, equals: .password)
            .onSubmit {
                focusedField = .confirmPassword
            }

            AnimatableTextField(
                label: AuthStrings.signupPasswordConfirmLabel,
                placeholder: AuthStrings.signupPasswordConfirmPlaceholder,
                secure: true,
                text: $confirmPassword
            )
            .focused($focusedField, equals: .confirmPassword)
            .onSubmit {
                focusedField = .email
            }

            HStack(alignment: .bottom, spacing: 4) {
                AnimatableTextField(
                    label: AuthStrings.signupEmailLabel,
                    placeholder: AuthStrings.signupEmailPlaceholder,
                    keyboardType: .emailAddress,
                    submitLabel: .done,
                    text: $emailUserName
                )
                .focused($focusedField, equals: .email)
                .onSubmit {
                    Task {
                        await submit()
                    }
                }

                Text(emailDomain)
                    .font(.system(size: 17))
                    .foregroundColor(Color(uiColor: .secondaryLabel))
                    .padding(.bottom, 12)
            }

            Spacer().layoutPriority(1)

            NavigationLink(value: OnboardDetailSceneTypes.termsOfService) {
                Text(AuthStrings.signupTermsAgreement.asMarkdown())
                    .font(.caption)
                    .foregroundColor(Color(uiColor: .label.withAlphaComponent(0.3)))
            }

            ProminentButton(label: AuthStrings.signupButton, isEnabled: isSubmitButtonEnabled) {
                Task {
                    await submit()
                }
            }
        }
        .onAppear {
            focusedField = .localID
        }
        .padding()
        .navigationTitle(AuthStrings.signupTitle)
        .alert(AuthStrings.signupCompletionTitle, isPresented: $showCompletionAlert) {
            Button(AuthStrings.alertConfirm) {
                viewModel.paths.append(.emailVerification(email: emailFullAddress))
            }
        } message: {
            Text(AuthStrings.signupCompletionMessage)
        }
    }

    private func submit() async {
        await errorAlertHandler.withAlert {
            // Validate inputs
            guard password == confirmPassword else {
                throw ValidationError.passwordMismatch
            }

            guard Validation.check(password: password) else {
                throw ValidationError.passwordInvalid
            }

            guard Validation.check(email: emailFullAddress) else {
                throw ValidationError.emailInvalid
            }

            isLoading = true
            defer { isLoading = false }

            try await viewModel.registerWithLocalID(
                localID: localID,
                localPassword: password,
                email: emailFullAddress
            )

            focusedField = nil

            // Show completion alert
            showCompletionAlert = true
        }
    }
}

enum ValidationError: LocalizedError {
    case passwordMismatch
    case passwordInvalid
    case emailInvalid

    var errorDescription: String? {
        switch self {
        case .passwordMismatch:
            return AuthStrings.errorPasswordMismatch
        case .passwordInvalid:
            return AuthStrings.errorPasswordInvalid
        case .emailInvalid:
            return AuthStrings.errorEmailInvalid
        }
    }
}

#Preview {
    NavigationStack {
        RegisterLocalIDScene(viewModel: .init())
            .navigationDestination(for: OnboardDetailSceneTypes.self) { type in
                switch type {
                case .termsOfService:
                    RegisterTermsOfServiceView()
                default: EmptyView()
                }
            }
    }
}
