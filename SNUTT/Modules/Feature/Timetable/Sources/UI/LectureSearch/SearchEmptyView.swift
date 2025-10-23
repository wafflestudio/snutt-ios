//
//  SearchEmptyView.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI

struct SearchEmptyView: View {
    var body: some View {
        VStack(spacing: 10) {
            Spacer()

            Image(systemName: "exclamationmark.circle")
                .font(.system(size: 80))

            Text(TimetableStrings.searchResultEmptyTitle)
                .font(.system(size: 20, weight: .bold))
                .padding(.top, 20)

            Text(TimetableStrings.searchResultEmptyDescription)
                .font(.system(size: 16))

            Spacer()
        }
        .foregroundColor(.white.opacity(0.8))
    }
}
