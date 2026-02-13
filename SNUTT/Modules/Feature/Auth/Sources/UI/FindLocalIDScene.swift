//
//  FindLocalIDScene.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

struct FindLocalIDScene: View {
    let viewModel: OnboardViewModel

    @State private var email = ""
    @State private var showSuccessAlert = false
    @State private var isLoading = false

    @FocusState private var isFocused: Bool
    @Environment(\.errorAlertHandler) private var errorAlertHandler
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Spacer().frame(height: 22)

            Text(AuthStrings.findidDescription)
                .font(.system(size: 17, weight: .bold))
                .fixedSize(horizontal: false, vertical: true)

            Spacer().frame(height: 8)

            AnimatableTextField(
                label: AuthStrings.findidEmailLabel,
                placeholder: AuthStrings.findidEmailPlaceholder,
                keyboardType: .emailAddress,
                submitLabel: .done,
                text: $email
            )
            .focused($isFocused)
            .onSubmit {
                submit()
            }

            Spacer().frame(height: 12)

            ProminentButton(label: AuthStrings.findidButton, isEnabled: !email.isEmpty && !isLoading) {
                submit()
            }

            Spacer()
        }
        .onAppear {
            isFocused = true
        }
        .navigationTitle(AuthStrings.findidTitle)
        .padding(.horizontal, 20)
        .alert(AuthStrings.findidSuccessTitle, isPresented: $showSuccessAlert) {
            Button(AuthStrings.findidButton) {
                dismiss()
            }
        } message: {
            Text(AuthStrings.findidSuccessMessage(email))
        }
    }

    private func submit() {
        errorAlertHandler.withAlert {
            isLoading = true
            defer { isLoading = false }

            try await viewModel.findLocalID(email: email)

            isFocused = false
            showSuccessAlert = true
        }
    }
}

#Preview {
    NavigationStack {
        FindLocalIDScene(viewModel: .init())
    }
}
