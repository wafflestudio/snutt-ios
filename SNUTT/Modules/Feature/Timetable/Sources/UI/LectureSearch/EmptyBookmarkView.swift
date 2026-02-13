//
//  EmptyBookmarkView.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI

struct EmptyBookmarkList: View {
    var body: some View {
        VStack(alignment: .center) {
            Text(TimetableStrings.searchBookmarkEmptyTitle)
                .font(.system(size: 17, weight: .bold))
            Spacer().frame(height: 6)
            Text(TimetableStrings.searchBookmarkEmptyDescription)
                .font(.system(size: 17, weight: .regular))
                .multilineTextAlignment(.center)
        }
        .frame(maxHeight: .infinity)
        .padding(.horizontal, 40)
        .foregroundColor(.white.opacity(0.8))
    }
}
