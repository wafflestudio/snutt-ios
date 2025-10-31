//
//  FriendMenuComponents.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

// MARK: - FriendNameLabel

struct FriendNameLabel: View {
    let friend: Friend

    private enum Design {
        static let detailFont = Font.system(size: 15)
    }

    var body: some View {
        Text(friend.effectiveDisplayName)
            .font(Design.detailFont)
            .foregroundColor(Color(uiColor: .label))
    }
}

// MARK: - FriendListEmptyView

struct FriendListEmptyView: View {
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            SharedUIComponentsAsset.catError.swiftUIImage
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(Color(uiColor: .label))

            Text(description)
                .font(.system(size: 14))
                .foregroundColor(Color(uiColor: .secondaryLabel))
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            Spacer()
        }
        .padding()
    }
}

// MARK: - FriendListLoadingView

struct FriendListLoadingView: View {
    private let placeholderLengths = [20, 10, 18, 15]

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ForEach(Array(placeholderLengths.enumerated()), id: \.offset) { index, length in
                    HStack(spacing: 8) {
                        Text(String(repeating: "가", count: length))
                            .font(.system(size: 15))
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                }
            }
            .padding(.top, 12)
        }
        .redacted(reason: .placeholder)
    }
}

// MARK: - FriendRequestActionButton

struct FriendRequestActionButton<S: PrimitiveButtonStyle>: View {
    let title: String
    let style: S
    let action: () async throws -> Void

    @State private var isLoading = false
    @Environment(\.errorAlertHandler) private var errorAlertHandler

    var body: some View {
        Button {
            performLoading(isLoading: $isLoading, errorAlertHandler: errorAlertHandler, action: action)
        } label: {
            Group {
                if isLoading {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 20, weight: .black))
                        .symbolEffect(.variableColor.iterative, isActive: true)
                } else {
                    Text(title)
                        .font(.system(size: 13, weight: .semibold))
                }
            }
            .frame(maxHeight: 16)
            .lineLimit(1)
        }
        .buttonStyle(style)
        .disabled(isLoading)
    }
}

#Preview("FriendRequestActionButton") {
    VStack(spacing: 16) {
        HStack(spacing: 8) {
            FriendRequestActionButton(
                title: FriendsStrings.friendRequestDecline,
                style: .bordered
            ) {
                try await Task.sleep(for: .seconds(2))
            }
            FriendRequestActionButton(
                title: FriendsStrings.friendRequestAccept,
                style: .borderedProminent
            ) {
                try await Task.sleep(for: .seconds(2))
            }
        }
    }
    .padding()
}
