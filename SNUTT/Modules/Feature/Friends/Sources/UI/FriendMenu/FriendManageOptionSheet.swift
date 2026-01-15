//
//  FriendManageOptionSheet.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI
import SwiftUIUtility

struct FriendManageOptionSheet: View {
    let friend: Friend
    let viewModel: FriendMenuViewModel

    @Environment(\.dismiss) private var dismiss
    @Environment(\.errorAlertHandler) private var errorAlertHandler

    @State private var isEditNamePresented = false
    @State private var showDeleteConfirmation = false

    var body: some View {
        GeometryReader { _ in
            VStack {
                Spacer()
                ManageOptionButton(option: .editName) {
                    isEditNamePresented = true
                }

                ManageOptionButton(option: .delete) {
                    showDeleteConfirmation = true
                }

                Spacer()
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 5)
            .presentationDetents([.height(150)])
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

private struct ManageOptionButton: View {
    let option: ManageOption
    let action: () async -> Void

    var body: some View {
        AnimatableButton(
            animationOptions: .backgroundColor(touchDown: .label.opacity(0.05)).scale(0.99),
            layoutOptions: [.expandHorizontally, .respectIntrinsicHeight]
        ) {
            Task {
                await action()
            }
        } configuration: { button in
            var config = UIButton.Configuration.plain()
            config.image = option.image
            config.title = option.text
            config.imagePadding = 10
            config.baseForegroundColor = .label
            button.contentHorizontalAlignment = .leading
            config.background.cornerRadius = 10
            return config
        }
    }
}

extension ManageOptionButton {
    enum ManageOption {
        case editName
        case delete

        var image: UIImage {
            switch self {
            case .editName: return FriendsAsset.sheetEdit.image
            case .delete: return FriendsAsset.sheetTrash.image
            }
        }

        var text: String {
            switch self {
            case .editName: return FriendsStrings.friendManageEditName
            case .delete: return FriendsStrings.friendManageDelete
            }
        }
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
