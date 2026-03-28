//
//  FriendManageOptionSheet.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import AuthInterface
import SharedUIComponents
import SwiftUI

struct FriendManageOptionSheet: View {
    let friend: Friend
    let viewModel: FriendMenuViewModel

    @Environment(\.dismiss) private var dismiss
    @Environment(\.errorAlertHandler) private var errorAlertHandler

    @State private var isEditNamePresented = false
    @State private var showDeleteConfirmation = false

    var body: some View {
        ActionSheet {
            ActionSheetItem(
                image: Image(uiImage: FriendsAsset.sheetEdit.image),
                title: FriendsStrings.friendManageEditName
            ) {
                isEditNamePresented = true
            }
            ActionSheetItem(
                image: Image(uiImage: FriendsAsset.sheetTrash.image),
                title: FriendsStrings.friendManageDelete,
                role: .destructive
            ) {
                showDeleteConfirmation = true
            }
        }
        .sheet(isPresented: $isEditNamePresented) {
            FriendEditDisplayNameSheet(friend: friend, viewModel: viewModel)
        }
        .alert(
            FriendsStrings.friendDeleteConfirmationTitle,
            isPresented: $showDeleteConfirmation
        ) {
            Button(SharedUIComponentsStrings.alertCancel, role: .cancel) {}
            Button(FriendsStrings.friendManageDelete, role: .destructive) {
                errorAlertHandler.withAlert {
                    dismiss()
                    try await viewModel.deleteFriend(friend)
                }
            }
        } message: {
            Text(FriendsStrings.friendDeleteConfirmationMessage)
        }
        .observeErrors()
    }
}

#Preview {
    @Previewable @State var isPresented = true
    ZStack {
        Color.gray
        Button("Present") {
            isPresented = true
        }
        .buttonStyle(.borderedProminent)
    }
    .ignoresSafeArea()
    .sheet(isPresented: $isPresented) {
        FriendManageOptionSheet(
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
}
