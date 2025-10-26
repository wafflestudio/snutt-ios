//
//  ChangePasswordScene.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

public struct ChangePasswordScene: View {
    let onChangePassword: (String, String) async throws -> Void

    @State private var oldPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @FocusState private var focusedField: TextFieldType?
    @State private var isSuccessAlertPresented = false

    @Environment(\.errorAlertHandler) private var errorAlertHandler
    @Environment(\.dismiss) private var dismiss

    public init(onChangePassword: @escaping (String, String) async throws -> Void) {
        self.onChangePassword = onChangePassword
    }

    private enum TextFieldType: Hashable {
        case oldPassword
        case newPassword
        case confirmPassword
    }

    var isSubmitButtonEnabled: Bool {
        !oldPassword.isEmpty && !newPassword.isEmpty && !confirmPassword.isEmpty && newPassword == confirmPassword
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            AnimatableTextField(
                label: AuthStrings.changePasswordOld,
                placeholder: AuthStrings.onboardLoginLocalPasswordPlaceHolder,
                secure: true,
                text: $oldPassword
            )
            .focused($focusedField, equals: .oldPassword)
            .onSubmit {
                focusedField = .newPassword
            }

            AnimatableTextField(
                label: AuthStrings.changePasswordNew,
                placeholder: AuthStrings.attachLocalIDPasswordPlaceholder,
                secure: true,
                text: $newPassword
            )
            .focused($focusedField, equals: .newPassword)
            .onSubmit {
                focusedField = .confirmPassword
            }

            AnimatableTextField(
                label: AuthStrings.changePasswordConfirm,
                placeholder: AuthStrings.attachLocalIDPasswordConfirmPlaceholder,
                secure: true,
                submitLabel: .done,
                text: $confirmPassword
            )
            .focused($focusedField, equals: .confirmPassword)
            .onSubmit {
                submit()
            }

            Spacer().layoutPriority(1)

            ProminentButton(label: AuthStrings.alertSave, isEnabled: isSubmitButtonEnabled) {
                submit()
            }
        }
        .onAppear {
            focusedField = .oldPassword
        }
        .padding()
        .navigationTitle(AuthStrings.changePasswordTitle)
        .alert(AuthStrings.changePasswordSuccess, isPresented: $isSuccessAlertPresented) {
            Button(AuthStrings.alertConfirm) {
                dismiss()
            }
        }
    }

    private func submit() {
        errorAlertHandler.withAlert {
            try await onChangePassword(oldPassword, newPassword)
            focusedField = nil
            isSuccessAlertPresented = true
        }
    }
}

#Preview {
    ChangePasswordScene(onChangePassword: { _, _ in })
}
