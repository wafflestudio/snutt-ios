//
//  FriendEditDisplayNameSheet.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

struct FriendEditDisplayNameSheet: View {
    let friend: Friend
    let viewModel: FriendMenuViewModel

    @State private var displayName: String
    @FocusState private var isFocused: Bool
    @State private var isLoading = false
    @Environment(\.errorAlertHandler) private var errorAlertHandler
    @Environment(\.dismiss) private var dismiss

    init(friend: Friend, viewModel: FriendMenuViewModel) {
        self.friend = friend
        self.viewModel = viewModel
        _displayName = State(initialValue: friend.displayName ?? "")
    }

    private var isDisplayNameValid: Bool {
        !displayName.isEmpty && displayName.count <= 10
    }

    private var isConfirmDisabled: Bool {
        !isDisplayNameValid || displayName == (friend.displayName ?? "") || isLoading
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
                            try await viewModel.updateFriendDisplayName(friend, displayName: displayName)
                        }
                        dismiss()
                    },
                    isConfirmDisabled: isConfirmDisabled
                )

                VStack(alignment: .leading, spacing: 8) {
                    AnimatableTextField(
                        label: FriendsStrings.friendEditNameLabel,
                        placeholder: "",
                        text: $displayName
                    )
                    .focused($isFocused)
                    .onAppear {
                        isFocused = true
                    }

                    Text(FriendsStrings.friendEditNameHelper)
                        .font(.system(size: 12))
                        .foregroundColor(Color(uiColor: .secondaryLabel))

                    Text(
                        FriendsStrings.friendOriginalNicknameLabel("\(friend.nickname)#\(friend.tag)")
                    )
                    .font(.system(size: 12))
                    .foregroundColor(Color(uiColor: .secondaryLabel))
                    .padding(.top, 4)
                }
                .padding(.horizontal)

                Spacer()
            }
        }
        .presentationDetents([.height(200)])
        .observeErrors()
    }
}

#Preview {
    FriendEditDisplayNameSheet(
        friend: Friend(
            id: "1",
            userId: "user1",
            nickname: "홍길동",
            tag: "1234",
            displayName: nil,
        ),
        viewModel: .init(friendsViewModel: .init())
    )
}
