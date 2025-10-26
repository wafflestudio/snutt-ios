//
//  EmptyFriendView.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

struct EmptyFriendView: View {
    let onShowGuide: () -> Void

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
            SharedUIComponentsAsset.catError.swiftUIImage
            Text(FriendsStrings.friendEmptyMainTitle)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(Color(uiColor: .label))

            Text(FriendsStrings.friendEmptyMainDescription)
                .font(.system(size: 14))
                .foregroundColor(Color(uiColor: .secondaryLabel))
                .multilineTextAlignment(.center)
                .lineSpacing(4)

            Button {
                onShowGuide()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 14))
                    Text(FriendsStrings.friendEmptyGuide)
                        .font(.system(size: 14))
                }
                .foregroundColor(Color(uiColor: .secondaryLabel))
            }
            .underline()
            .padding(.top, 8)

            Spacer()
        }
        .padding()
    }
}

#Preview {
    EmptyFriendView {}
}
