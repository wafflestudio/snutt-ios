//
//  ChangeNicknameView.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import FoundationUtility
import SharedUIComponents
import SwiftUI

struct ChangeNicknameView: View {
    let viewModel: MyAccountViewModel

    @State private var new: String = ""
    @State private var isNicknameChanged: Bool = false

    @FocusState private var isFocused: Bool

    private var isButtonDisabled: Bool {
        new.isEmpty || new.count > 10 || (viewModel.previousNickname == new)
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.errorAlertHandler) private var errorAlertHandler

    var body: some View {
        List {
            Section {
                HStack(spacing: 0) {
                    TextField("", text: $new, prompt: Text(viewModel.previousNickname))
                        .font(.system(size: 16))
                        .focused($isFocused)

                    if isFocused {
                        Button {
                            new = ""
                            isFocused = false
                        } label: {
                            Image("xbutton")
                                .resizable()
                                .frame(width: 30, height: 30)
                        }
                    }

                    Spacer().frame(width: 2)

                    Text("#NNNN")
                        .font(.system(size: 16))
                        .foregroundColor(Color(uiColor: UIColor.tertiaryLabel))
                }
            } header: {
                Text(SettingsStrings.accountNicknameChangeHeader)
                    .font(.system(size: 12))
            } footer: {
                VStack(alignment: .leading) {
                    Spacer().frame(height: 8)

                    Text(SettingsStrings.accountNicknameChangeFooter)

                    Spacer().frame(height: 30)

                    Text(SettingsStrings.accountNicknameChangeRules.asMarkdown())
                        .lineSpacing(4)
                }
                .font(.system(size: 12))
            }
        }
        .navigationTitle(Text(SettingsStrings.accountNicknameChange))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    errorAlertHandler.withAlert {
                        try await viewModel.changeNickname(to: new)
                        isNicknameChanged = true
                    }
                } label: {
                    Text(SettingsStrings.save)
                }
                .disabled(isButtonDisabled)
            }
        }
        .alert(SettingsStrings.accountNicknameChangeSuccess, isPresented: $isNicknameChanged) {
            Button(SettingsStrings.confirm) {
                dismiss()
            }
        }
        .animation(.defaultSpring, value: isFocused)
    }
}

extension MyAccountViewModel {
    var previousNickname: String {
        switch loadState {
        case .loaded(let user):
            user.nickname.nickname
        case .loading:
            ""
        }
    }
}
