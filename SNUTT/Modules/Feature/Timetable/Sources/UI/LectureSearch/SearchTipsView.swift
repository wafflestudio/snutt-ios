//
//  SearchTipsView.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import SwiftUI

struct SearchTipsView: View {
    var body: some View {
        VStack(spacing: 10) {
            Spacer()

            Image(systemName: "magnifyingglass")
                .font(.system(size: 80))

            Text(TimetableStrings.searchTipsTitle)
                .font(.system(size: 20, weight: .bold))
                .padding(.top, 20)

            Spacer()
                .frame(height: 5)

            VStack(spacing: 5) {
                Text(TimetableStrings.searchTipsCombinationTitle)
                    .font(.system(size: 16, weight: .bold))
                Text(TimetableStrings.searchTipsCombinationExample)
                    .font(.system(size: 16))
            }

            Spacer()
                .frame(height: 5)

            VStack(spacing: 5) {
                Text(TimetableStrings.searchTipsAbbreviationTitle)
                    .font(.system(size: 16, weight: .bold))
                Text(TimetableStrings.searchTipsAbbreviationExample)
                    .font(.system(size: 16))
            }

            Spacer()
                .frame(height: 5)

            VStack(spacing: 5) {
                Text(TimetableStrings.searchTipsLocationTitle)
                    .font(.system(size: 16, weight: .bold))
                Text(TimetableStrings.searchTipsLocationExample)
                    .font(.system(size: 16))
            }

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .foregroundColor(.white.opacity(0.9))
    }
}

#Preview {
    SearchTipsView()
}
