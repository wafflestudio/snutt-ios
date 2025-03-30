//
//  LoginScene.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import MemberwiseInit
import SharedUIComponents
import SwiftUI

@MemberwiseInit
struct LoginScene: View {
    @Init(.internal) private let viewModel: OnboardViewModel
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
                Task {
                    await submit()
                }
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
    }

    private func submit() async {
        await errorAlertHandler.withAlert {
            try await viewModel.loginWithLocalId(localID: localID, localPassword: localPassword)
            focusedField = nil
        }
    }
}

private struct UnderlineButton: View {
    let label: String
    let action: () -> Void

    private enum Design {
        static let fontColor = UIColor.secondaryLabel
    }

    var body: some View {
        AnimatableButton(
            animationOptions: .identity.scale(0.95),
            layoutOptions: [.respectIntrinsicWidth, .respectIntrinsicHeight]
        ) {
            action()
        } configuration: { _ in
            var configuration = UIButton.Configuration.plain()
            configuration.baseBackgroundColor = SharedUIComponentsAsset.cyan.color
            configuration.baseForegroundColor = Design.fontColor
            let attributes: [NSAttributedString.Key: Any] = [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .underlineColor: Design.fontColor,
                .font: UIFont.systemFont(ofSize: 14),
            ]
            configuration.contentInsets = .zero
            configuration.attributedTitle = .init(label, attributes: AttributeContainer(attributes))
            return configuration
        }
    }
}

private struct ProminentButton: View {
    let label: String
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        AnimatableButton(
            animationOptions: .identity.impact().backgroundColor(touchDown: .black.opacity(0.05)).scale(0.97),
            layoutOptions: [.respectIntrinsicHeight, .expandHorizontally]
        ) {
            action()
        } configuration: { button in
            button.isEnabled = isEnabled
            var configuration = UIButton.Configuration.plain()
            configuration.attributedTitle = .init(
                label,
                attributes: .init().font(.systemFont(ofSize: 17, weight: .semibold))
            )
            configuration.cornerStyle = .large
            configuration.baseForegroundColor = .white
            configuration.contentInsets = .init(top: 10, leading: 10, bottom: 10, trailing: 10)
            configuration.background.backgroundColor = isEnabled ? SharedUIComponentsAsset.cyan
                .color : .tertiarySystemFill
            return configuration
        }
    }
}

@MainActor private func view() -> some View {
    LoginScene(viewModel: .init())
}

#Preview {
    view()
}
