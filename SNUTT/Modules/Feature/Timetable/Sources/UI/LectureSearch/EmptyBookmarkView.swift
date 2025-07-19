//
//  EmptyBookmarkView.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI

struct EmptyBookmarkList: View {
    var body: some View {
        VStack(alignment: .center) {
            Text("추가한 관심강좌가 없습니다.")
                .font(.system(size: 17, weight: .bold))
            Spacer().frame(height: 6)
            Text("고민되는 강의를 관심강좌에 추가하여\n관리해보세요.")
                .font(.system(size: 17, weight: .regular))
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 40)
        .foregroundColor(.white.opacity(0.8))
    }
}
