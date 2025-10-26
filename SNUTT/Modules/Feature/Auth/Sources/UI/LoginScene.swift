//
//  LoginScene.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import MemberwiseInit
import SharedUIComponents
import SwiftUI

struct LoginScene: View {
    let viewModel: OnboardViewModel
    @State private var localID = ""
    @State private var localPassword = ""
    @FocusState private var focusedField: TextFieldType?
    @Environment(\.errorAlertHandler) private var errorAlertHandler

    private enum TextFieldType: Hashable {
        case localID
        case localPassword
    }

    var isSubmitButtonEnabled: Bool {
        !localID.isEmpty && !localPassword.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            AnimatableTextField(
                label: AuthStrings.onboardLoginLocalID,
                placeholder: AuthStrings.onboardLoginLocalIDPlaceholder,
                text: $localID
            )
            .focused($focusedField, equals: TextFieldType.localID)
            .onSubmit {
                focusedField = .localPassword
            }
            AnimatableTextField(
                label: AuthStrings.onboardLoginLocalPassword,
                placeholder: AuthStrings.onboardLoginLocalPasswordPlaceHolder,
                secure: true,
                submitLabel: .done,
                text: $localPassword
            )
            .focused($focusedField, equals: TextFieldType.localPassword)
            .onSubmit {
                submit()
            }

            HStack {
                UnderlineButton(label: AuthStrings.onboardLoginFindLocalIDButton) {
                    viewModel.paths.append(.findLocalID)
                }
                Divider()
                UnderlineButton(label: AuthStrings.onboardLoginResetLocalPasswordButton) {
                    viewModel.paths.append(.resetLocalPassword)
                }
            }
            Spacer().layoutPriority(1)
            ProminentButton(label: AuthStrings.onboardLoginButton, isEnabled: isSubmitButtonEnabled) {
                Task {
                    await submit()
                }
            }
        }
        .onAppear {
            focusedField = .localID
        }
        .padding()
        .navigationTitle(AuthStrings.onboardLoginButton)
        // prevent unintentional calls during transitions
        .analyticsScreen(.login, condition: !viewModel.authState.isAuthenticated)
    }

    private func submit() {
        errorAlertHandler.withAlert {
            try await viewModel.loginWithLocalId(localID: localID, localPassword: localPassword)
            focusedField = nil
        }
    }
}

#Preview {
    LoginScene(viewModel: .init())
}
