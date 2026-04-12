//
//  UserSupportScene.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI

struct UserSupportScene: View {
    @State private(set) var viewModel: UserSupportViewModel
    @FocusState private var isFocused: Bool
    @Environment(\.dismiss) private var dismiss

    init(viewModel: UserSupportViewModel = .init()) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        Form {
            Section {
                TextField(SettingsStrings.feedbackEmailPlaceholder, text: $viewModel.email)
                    .foregroundColor(viewModel.hasEmail ? .secondary : .primary)
                    .disabled(viewModel.hasEmail)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
            } header: {
                Text(SettingsStrings.feedbackEmailHeader)
                    .font(.system(size: 13))
            }

            Section {
                TextEditor(text: $viewModel.content)
                    .frame(minHeight: 300)
                    .focused($isFocused)
            } header: {
                Text(SettingsStrings.feedbackContentHeader)
                    .font(.system(size: 13))
            } footer: {
                Text(SettingsStrings.feedbackContentFooter)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(SettingsStrings.feedback)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                if viewModel.isLoading {
                    ProgressView()
                } else {
                    Button {
                        viewModel.showSendConfirmation = true
                    } label: {
                        Text(SettingsStrings.feedbackSend)
                    }
                    .disabled(viewModel.isButtonDisabled)
                }
            }

            ToolbarItemGroup(placement: .keyboard) {
                Spacer()

                Button(SettingsStrings.feedbackDone) {
                    isFocused = false
                }
            }
        }
        .alert(SettingsStrings.feedback, isPresented: $viewModel.showSendConfirmation) {
            Button(SettingsStrings.feedbackCancel, role: .cancel, action: {})
            Button(SettingsStrings.feedbackSend, role: .none) {
                Task {
                    let success = await viewModel.sendFeedback()
                    if success {
                        dismiss()
                    }
                }
            }
        } message: {
            Text(SettingsStrings.feedbackSendConfirmation)
        }
    }
}

#Preview {
    NavigationStack {
        UserSupportScene()
    }
}
