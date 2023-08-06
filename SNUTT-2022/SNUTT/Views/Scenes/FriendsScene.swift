//
//  FriendsScene.swift
//  SNUTT
//
//  Created by 최유림 on 2023/08/06.
//

import SwiftUI

// TODO: merge with RN-FriendsScene
struct FriendsScene: View {
    var body: some View {
        WIPFriendsView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(STColor.systemBackground)
    }
}

struct FriendsScene_Previews: PreviewProvider {
    static var previews: some View {
        FriendsScene()
    }
}
