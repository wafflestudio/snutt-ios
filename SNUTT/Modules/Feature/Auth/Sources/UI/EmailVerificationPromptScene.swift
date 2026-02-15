//
//  EmailVerificationPromptScene.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

struct EmailVerificationPromptScene: View {
    let viewModel: OnboardViewModel
    let email: String

    @Environment(\.errorAlertHandler) private var errorAlertHandler
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Text(AuthStrings.emailVerificationDescription(email))
                .font(.system(size: 17, weight: .bold))
                .fixedSize(horizontal: false, vertical: true)

            Text(AuthStrings.emailVerificationInfo)
                .font(.system(size: 14, weight: .regular))

            Spacer()

            VStack(spacing: 12) {
                ProminentButton(label: AuthStrings.emailVerificationButton) {
                    sendVerificationCode()
                }

                ProminentButton(
                    label: AuthStrings.emailVerificationLater,
                    backgroundColor: SharedUIComponentsAsset.assistive.swiftUIColor
                ) {
                    dismiss()
                }
            }
        }
        .navigationTitle(AuthStrings.emailVerificationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .padding(.horizontal, 20)
        .padding(.top, 27)
    }

    private func sendVerificationCode() {
        errorAlertHandler.withAlert {
            try await viewModel.sendVerificationCode(email: email)
            viewModel.paths.append(.verificationCode(email: email, mode: .signup, localID: nil))
        }
    }
}

#Preview {
    NavigationStack {
        EmailVerificationPromptScene(viewModel: .init(), email: "penggggg@snu.ac.kr")
    }
}
