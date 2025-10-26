//
//  FriendRequestOptionSheet.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI
import SwiftUIUtility

struct FriendRequestOptionSheet: View {
    @State private var viewModel: FriendRequestViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.errorAlertHandler) private var errorAlertHandler

    @State private var isNicknameRequestPresented = false

    init(friendsViewModel: FriendsViewModel) {
        _viewModel = State(initialValue: FriendRequestViewModel(friendsViewModel: friendsViewModel))
    }

    var body: some View {
        GeometryReader { _ in
            VStack {
                Spacer()
                RequestOptionButton(option: .kakao) {
                    errorAlertHandler.withAlert {
                        try await viewModel.sendKakaoFriendRequest()
                        dismiss()
                    }
                }

                RequestOptionButton(option: .nickname) {
                    isNicknameRequestPresented = true
                }

                Spacer()
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 5)
            .presentationDetents([.height(150)])
        }
        .sheet(isPresented: $isNicknameRequestPresented) {
            FriendRequestByNicknameSheet(viewModel: viewModel)
        }
        .observeErrors()
    }
}

private struct RequestOptionButton: View {
    let option: RequestOption
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

extension RequestOptionButton {
    enum RequestOption {
        case kakao
        case nickname

        var image: UIImage {
            switch self {
            case .kakao: return FriendsAsset.sheetKakao.image
            case .nickname: return FriendsAsset.sheetNickname.image
            }
        }

        var text: String {
            switch self {
            case .kakao: return FriendsStrings.friendRequestOptionKakao
            case .nickname: return FriendsStrings.friendRequestOptionNickname
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
        FriendRequestOptionSheet(friendsViewModel: .init())
    }
}
