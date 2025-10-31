//
//  EnterNewPasswordScene.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

struct EnterNewPasswordScene: View {
    let viewModel: OnboardViewModel
    let localID: String
    let verificationCode: String

    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showAlert = false
    @State private var alertType: AlertType = .success
    @State private var timeOut = false
    @State private var isLoading = false

    @FocusState private var focusedField: Field?
    @Environment(\.errorAlertHandler) private var errorAlertHandler
    @Environment(\.dismiss) private var dismiss

    private enum Field: Hashable {
        case password
        case confirmPassword
    }

    private enum AlertType {
        case success
        case backConfirm
        case passwordMismatch
        case passwordInvalid
        case timeOut

        var title: String {
            switch self {
            case .success:
                return AuthStrings.findidButton
            case .backConfirm, .passwordMismatch, .passwordInvalid:
                return ""
            case .timeOut:
                return AuthStrings.newPasswordTimeoutTitle
            }
        }

        var message: String {
            switch self {
            case .success:
                return AuthStrings.newPasswordSuccess
            case .backConfirm:
                return AuthStrings.newPasswordBackConfirm
            case .passwordMismatch:
                return AuthStrings.newPasswordNotEqual
            case .passwordInvalid:
                return AuthStrings.newPasswordNotValid
            case .timeOut:
                return AuthStrings.newPasswordTimeoutMessage
            }
        }
    }

    var isButtonEnabled: Bool {
        !password.isEmpty && !confirmPassword.isEmpty && !isLoading
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 48) {
            VStack(alignment: .leading, spacing: 40) {
                Text(AuthStrings.newPasswordDescription)
                    .font(.system(size: 17, weight: .bold))
                    .fixedSize(horizontal: false, vertical: true)

                VStack(spacing: 24) {
                    HStack {
                        AnimatableTextField(
                            label: "",
                            placeholder: AuthStrings.newPasswordPlaceholder,
                            secure: true,
                            text: $password
                        )
                        .focused($focusedField, equals: .password)
                        .onSubmit {
                            focusedField = .confirmPassword
                        }

                        Spacer().frame(width: 8)

                        TimerView(
                            initialRemainingTime: 180,
                            onTimeout: {
                                timeOut = true
                            }
                        )
                    }

                    AnimatableTextField(
                        label: "",
                        placeholder: AuthStrings.newPasswordConfirmPlaceholder,
                        secure: true,
                        submitLabel: .done,
                        text: $confirmPassword
                    )
                    .focused($focusedField, equals: .confirmPassword)
                    .onSubmit {
                        submit()
                    }
                }
            }

            ProminentButton(label: AuthStrings.newPasswordButton, isEnabled: isButtonEnabled) {
                submit()
            }

            Spacer()
        }
        .onAppear {
            focusedField = .password
        }
        .navigationTitle(AuthStrings.newPasswordTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    alertType = .backConfirm
                    showAlert = true
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 17, weight: .semibold))
                        Text(AuthStrings.resetPasswordIdLabel)
                    }
                    .padding(.leading, -8)
                }
            }
        }
        .padding(.top, 44)
        .padding(.horizontal, 20)
        .alert(alertType.title, isPresented: $showAlert) {
            if alertType == .backConfirm {
                Button(AuthStrings.findidButton) {
                    dismiss()
                }
                Button(AuthStrings.alertCancel, role: .cancel) {}
            } else {
                Button(AuthStrings.findidButton) {
                    if alertType == .success {
                        // Pop to root
                        viewModel.paths.removeAll()
                    } else if alertType == .timeOut {
                        // Go back to verification code
                        if let index = viewModel.paths.lastIndex(where: {
                            if case .verificationCode = $0 { return true }
                            return false
                        }) {
                            viewModel.paths.removeLast(viewModel.paths.count - index - 1)
                        }
                    }
                }
            }
        } message: {
            Text(alertType.message)
        }
        .onChange(of: timeOut) { _, newValue in
            if newValue {
                alertType = .timeOut
                showAlert = true
            }
        }
    }

    private func submit() {
        guard password == confirmPassword else {
            alertType = .passwordMismatch
            showAlert = true
            return
        }

        guard Validation.check(password: password) else {
            alertType = .passwordInvalid
            showAlert = true
            return
        }

        errorAlertHandler.withAlert {
            isLoading = true
            defer { isLoading = false }

            try await viewModel.resetPassword(localID: localID, password: password, code: verificationCode)

            focusedField = nil
            alertType = .success
            showAlert = true
        }
    }
}

#Preview {
    NavigationStack {
        EnterNewPasswordScene(viewModel: .init(), localID: "testuser", verificationCode: "ABC12345")
    }
}
