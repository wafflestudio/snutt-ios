//
//  WIPFriendsView.swift
//  SNUTT
//
//  Created by 최유림 on 2023/08/05.
//

import SwiftUI

// *Will be deprecated*
struct WIPFriendsView: View {
    var body: some View {
        VStack(alignment: .center) {
            Image("waffle.cat")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 72)

            Spacer().frame(height: 24)

            Text("친구기능 개발 중...")
                .font(STFont.title)

            Spacer().frame(height: 8)

            Text("Coming Soon!")
                .font(STFont.detailLabel)
        }
        .foregroundColor(.secondary)
        .navigationTitle("친구 시간표")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct EmptyFriendsView_Previews: PreviewProvider {
    static var previews: some View {
        WIPFriendsView()
    }
}
