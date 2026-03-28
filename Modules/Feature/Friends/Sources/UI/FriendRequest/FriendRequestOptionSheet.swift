//
//  FriendRequestOptionSheet.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

struct FriendRequestOptionSheet: View {
    @State private var viewModel: FriendRequestViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.errorAlertHandler) private var errorAlertHandler

    @State private var isNicknameRequestPresented = false

    init(friendsViewModel: FriendsViewModel) {
        _viewModel = State(initialValue: FriendRequestViewModel(friendsViewModel: friendsViewModel))
    }

    var body: some View {
        ActionSheet {
            ActionSheetItem(
                image: Image(uiImage: FriendsAsset.sheetKakao.image),
                title: FriendsStrings.friendRequestOptionKakao
            ) {
                errorAlertHandler.withAlert {
                    try await viewModel.sendKakaoFriendRequest()
                    dismiss()
                }
            }
            ActionSheetItem(
                image: Image(uiImage: FriendsAsset.sheetNickname.image),
                title: FriendsStrings.friendRequestOptionNickname
            ) {
                isNicknameRequestPresented = true
            }
        }
        .sheet(isPresented: $isNicknameRequestPresented) {
            FriendRequestByNicknameSheet(viewModel: viewModel)
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
        FriendRequestOptionSheet(friendsViewModel: .init())
    }
}
