//
//  FriendsGuidePopup.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

struct FriendsGuidePopup: View {
    var body: some View {
        ImageGuidePopup(
            guideImages: [
                FriendsAsset.friendGuide1.image,
                FriendsAsset.friendGuide2.image,
                FriendsAsset.friendGuide3.image,
                FriendsAsset.friendGuide4.image,
                FriendsAsset.friendGuide5.image,
            ]
        )
    }
}

#Preview {
    FriendsGuidePopup()
}
