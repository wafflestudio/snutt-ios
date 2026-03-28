//
//  FriendMenuContentView.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

struct FriendMenuContentView: View {
    @State private var viewModel: FriendMenuViewModel
    init(friendsViewModel: FriendsViewModel) {
        _viewModel = .init(initialValue: .init(friendsViewModel: friendsViewModel))
    }

    @Environment(\.sheetDismiss) private var dismiss
    @Environment(\.errorAlertHandler) private var errorAlertHandler

    @State private var selectedFriendForOptions: Friend?

    var body: some View {
        VStack(spacing: 0) {
            logoView

            Divider()
                .padding(.horizontal, 10)

            segmentedControl
                .padding(.horizontal, 15)
                .padding(.top, 20)

            addFriendButton
                .padding(.horizontal, 15)
                .padding(.top, 12)

            Divider()
                .padding(.horizontal, 15)
                .padding(.top, 6)

            contentView
        }
        .sheet(item: $selectedFriendForOptions) { friend in
            FriendManageOptionSheet(friend: friend, viewModel: viewModel)
        }
    }

    private var logoView: some View {
        HStack {
            Logo(orientation: .horizontal)
                .padding(.vertical)
            Spacer()
            AnimatableButton(
                animationOptions: .impact().scale(0.9).backgroundColor(touchDown: .black.opacity(0.1)),
                layoutOptions: [.respectIntrinsicHeight, .respectIntrinsicWidth]
            ) {
                dismiss()
            } configuration: { _ in
                var configuration = UIButton.Configuration.plain()
                configuration.image = FriendsAsset.xmark.image
                return configuration
            }
        }
        .padding(.horizontal, 20)
    }

    private var segmentedControl: some View {
        Picker("Tab Selection", selection: $viewModel.selectedTab) {
            Text(FriendsStrings.friendMenuTabActive).tag(FriendMenuViewModel.Tab.active)
            Text(FriendsStrings.friendMenuTabRequested).tag(FriendMenuViewModel.Tab.requested)
        }
        .pickerStyle(.segmented)
    }

    private var addFriendButton: some View {
        Button {
            viewModel.friendsViewModel.isRequestSheetPresented = true
        } label: {
            HStack {
                Text(FriendsStrings.friendAddButton)
                Spacer()
                FriendsAsset.menuFriendAdd.swiftUIImage
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 24, height: 24)
            }
            .foregroundStyle(Color.secondary)
            .font(.footnote)
            .padding(.horizontal, 5)
        }
    }

    @ViewBuilder
    private var contentView: some View {
        switch viewModel.selectedTab {
        case .active:
            friendsListView(
                loadState: viewModel.activeFriendsLoadState,
                emptyTitle: FriendsStrings.friendActiveEmptyTitle,
                emptyDescription: FriendsStrings.friendActiveEmptyDescription
            ) { friends in
                ForEach(friends) { friend in
                    ActiveFriendRow(
                        friend: friend,
                        isSelected: viewModel.friendsViewModel.selectedFriend?.id == friend.id,
                        onSelect: {
                            dismiss()
                            try await viewModel.selectFriend(friend)
                        },
                        onEllipsisPressed: {
                            selectedFriendForOptions = friend
                        }
                    )
                }
            }
        case .requested:
            friendsListView(
                loadState: viewModel.requestedFriendsLoadState,
                emptyTitle: FriendsStrings.friendRequestedEmptyTitle,
                emptyDescription: FriendsStrings.friendRequestedEmptyDescription
            ) { friends in
                ForEach(friends) { friend in
                    RequestedFriendRow(
                        friend: friend,
                        viewModel: viewModel
                    )
                }
            }
        }
    }

    @ViewBuilder
    private func friendsListView<Content: View>(
        loadState: FriendsLoadState,
        emptyTitle: String,
        emptyDescription: String,
        @ViewBuilder content: @escaping ([Friend]) -> Content
    ) -> some View {
        VStack(spacing: 0) {
            switch loadState {
            case .loading, .failed:
                FriendListLoadingView()
            case let .loaded(friends) where friends.isEmpty:
                FriendListEmptyView(title: emptyTitle, description: emptyDescription)
            case let .loaded(friends):
                ScrollView {
                    VStack(spacing: 0) {
                        content(friends)
                    }
                    .padding(.top, 12)
                    .animation(.defaultSpring, value: friends.count)
                }
            }
        }
        .animation(.defaultSpring, value: loadState == .loading)
    }

}

// MARK: - ActiveFriendRow

private struct ActiveFriendRow: View {
    let friend: Friend
    let isSelected: Bool
    let onSelect: () async throws -> Void
    let onEllipsisPressed: () -> Void

    @State private var isLoading = false
    @Environment(\.errorAlertHandler) private var errorAlertHandler

    var body: some View {
        HStack(spacing: 0) {
            Button {
                performLoading(isLoading: $isLoading, errorAlertHandler: errorAlertHandler, action: onSelect)
            } label: {
                HStack(spacing: 8) {
                    FriendNameLabel(friend: friend)

                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.7)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
            }

            Spacer()

            Button {
                onEllipsisPressed()
            } label: {
                FriendsAsset.menuEllipsis.swiftUIImage
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30)
                    .opacity(0.5)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 5)
        .background(isSelected ? Color.black.opacity(0.1) : Color.clear)
        .animation(.defaultSpring, value: isSelected)
    }
}

// MARK: - RequestedFriendRow

private struct RequestedFriendRow: View {
    let friend: Friend
    let viewModel: FriendMenuViewModel

    var body: some View {
        HStack(spacing: 12) {
            FriendNameLabel(friend: friend)
            Spacer()

            HStack(spacing: 8) {
                FriendRequestActionButton(
                    title: FriendsStrings.friendRequestDecline,
                    style: .bordered
                ) {
                    try await viewModel.declineFriend(friend)
                }

                FriendRequestActionButton(
                    title: FriendsStrings.friendRequestAccept,
                    style: .borderedProminent
                ) {
                    try await viewModel.acceptFriend(friend)
                }
            }
            .layoutPriority(2)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }
}

#Preview {
    let viewModel = FriendsViewModel()
    FriendMenuContentView(friendsViewModel: viewModel)
}
