//
//  UserSupportScene.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

struct UserSupportScene: View {
    let viewModel: OnboardViewModel

    @State private var email = ""
    @State private var message = ""
    @State private var showSuccessAlert = false
    @State private var isLoading = false

    @FocusState private var focusedField: Field?
    @Environment(\.errorAlertHandler) private var errorAlertHandler
    @Environment(\.dismiss) private var dismiss

    private enum Field: Hashable {
        case email
        case message
    }

    var isSubmitButtonEnabled: Bool {
        !message.isEmpty && !isLoading
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Spacer().frame(height: 22)

            AnimatableTextField(
                label: AuthStrings.feedbackEmailLabel,
                placeholder: AuthStrings.feedbackEmailPlaceholder,
                keyboardType: .emailAddress,
                text: $email
            )
            .focused($focusedField, equals: .email)
            .onSubmit {
                focusedField = .message
            }

            VStack(alignment: .leading, spacing: 8) {
                Text(AuthStrings.feedbackMessageLabel)
                    .font(.system(size: 14))
                    .foregroundColor(Color(uiColor: .secondaryLabel))

                TextEditor(text: $message)
                    .font(.system(size: 14))
                    .frame(minHeight: 200)
                    .padding(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(
                                message.isEmpty
                                    ? Color(uiColor: .quaternaryLabel) : SharedUIComponentsAsset.cyan.swiftUIColor,
                                lineWidth: 1
                            )
                    )
                    .focused($focusedField, equals: .message)
                    .overlay(alignment: .topLeading) {
                        if message.isEmpty {
                            Text(AuthStrings.feedbackMessagePlaceholder)
                                .font(.system(size: 14))
                                .foregroundColor(Color(uiColor: .placeholderText))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 16)
                                .allowsHitTesting(false)
                        }
                    }
            }

            Spacer().frame(height: 12)

            ProminentButton(label: AuthStrings.feedbackButton, isEnabled: isSubmitButtonEnabled) {
                Task {
                    await submit()
                }
            }

            Spacer()
        }
        .onAppear {
            focusedField = .email
        }
        .navigationTitle(AuthStrings.feedbackTitle)
        .padding(.horizontal, 20)
        .alert(AuthStrings.feedbackSuccess, isPresented: $showSuccessAlert) {
            Button(AuthStrings.findidButton) {
                dismiss()
            }
        }
    }

    private func submit() {
        errorAlertHandler.withAlert {
            isLoading = true
            defer { isLoading = false }

            let emailToSend = email.isEmpty ? nil : email
            try await viewModel.sendFeedback(email: emailToSend, message: message)

            focusedField = nil
            showSuccessAlert = true
        }
    }
}

#Preview {
    NavigationStack {
        UserSupportScene(viewModel: .init())
    }
}
