//
//  FriendRequestByNicknameSheet.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

struct FriendRequestByNicknameSheet: View {
    let viewModel: FriendRequestViewModel

    @State private var nickname: String = ""
    @FocusState private var isFocused: Bool
    @Environment(\.errorAlertHandler) private var errorAlertHandler
    @Environment(\.dismiss) private var dismiss

    private var isNicknameValid: Bool {
        viewModel.validateNickname(nickname)
    }

    private var isConfirmDisabled: Bool {
        !isNicknameValid
    }

    private var validationMessage: String? {
        if nickname.isEmpty {
            return FriendsStrings.friendRequestNicknameValidationMessage
        } else if !isNicknameValid {
            return FriendsStrings.friendRequestNicknameValidationMessage
        }
        return nil
    }

    var body: some View {
        GeometryReader { _ in
            VStack(spacing: 20) {
                SheetTopBar(
                    cancel: {
                        dismiss()
                    },
                    confirm: {
                        await errorAlertHandler.withAlert {
                            try await viewModel.requestFriend(nickname: nickname)
                            dismiss()
                            // TODO: Show success alert
                        }
                    },
                    isConfirmDisabled: isConfirmDisabled
                )

                VStack(alignment: .leading, spacing: 8) {
                    AnimatableTextField(
                        label: FriendsStrings.friendRequestNicknameLabel,
                        placeholder: FriendsStrings.friendRequestNicknamePlaceholder,
                        text: $nickname
                    )
                    .focused($isFocused)
                    .onAppear {
                        isFocused = true
                    }

                    if let message = validationMessage {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.system(size: 12))
                            Text(message)
                                .font(.system(size: 12))
                        }
                        .foregroundColor(
                            nickname.isEmpty
                                ? Color(uiColor: .secondaryLabel)
                                : Color(uiColor: .systemRed)
                        )
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
        }
        .presentationDetents([.height(160)])
        .observeErrors()
    }
}

#Preview {
    FriendRequestByNicknameSheet(viewModel: .init(friendsViewModel: .init()))
}
