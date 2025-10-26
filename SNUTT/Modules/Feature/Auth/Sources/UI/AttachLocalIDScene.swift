//
//  AttachLocalIDScene.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

public struct AttachLocalIDScene: View {
    let onAttach: (String, String) async throws -> Void

    @State private var localID = ""
    @State private var localPassword = ""
    @State private var confirmPassword = ""
    @FocusState private var focusedField: TextFieldType?
    @State private var isSuccessAlertPresented = false

    @Environment(\.errorAlertHandler) private var errorAlertHandler
    @Environment(\.dismiss) private var dismiss

    public init(onAttach: @escaping (String, String) async throws -> Void) {
        self.onAttach = onAttach
    }

    private enum TextFieldType: Hashable {
        case localID
        case localPassword
        case confirmPassword
    }

    var isSubmitButtonEnabled: Bool {
        !localID.isEmpty && !localPassword.isEmpty && !confirmPassword.isEmpty && localPassword == confirmPassword
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            AnimatableTextField(
                label: AuthStrings.attachLocalIDIdLabel,
                placeholder: AuthStrings.attachLocalIDIdPlaceholder,
                text: $localID
            )
            .focused($focusedField, equals: .localID)
            .onSubmit {
                focusedField = .localPassword
            }

            AnimatableTextField(
                label: AuthStrings.attachLocalIDPasswordLabel,
                placeholder: AuthStrings.attachLocalIDPasswordPlaceholder,
                secure: true,
                text: $localPassword
            )
            .focused($focusedField, equals: .localPassword)
            .onSubmit {
                focusedField = .confirmPassword
            }

            AnimatableTextField(
                label: AuthStrings.attachLocalIDPasswordConfirmLabel,
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

            ProminentButton(label: AuthStrings.attachLocalIDButton, isEnabled: isSubmitButtonEnabled) {
                submit()
            }
        }
        .onAppear {
            focusedField = .localID
        }
        .padding()
        .navigationTitle(AuthStrings.attachLocalIDTitle)
        .alert(AuthStrings.attachLocalIDSuccess, isPresented: $isSuccessAlertPresented) {
            Button(AuthStrings.alertConfirm) {
                dismiss()
            }
        }
    }

    private func submit() {
        errorAlertHandler.withAlert {
            try await onAttach(localID, localPassword)
            focusedField = nil
            isSuccessAlertPresented = true
        }
    }
}
