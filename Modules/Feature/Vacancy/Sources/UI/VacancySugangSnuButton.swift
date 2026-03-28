//
//  VacancySugangSnuButton.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

struct VacancySugangSnuButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: {
            action()
        }) {
            Text(VacancyStrings.sugangSiteButton)
                .font(.system(size: 14, weight: .bold))
                .foregroundColor(.white)
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .background(SharedUIComponentsAsset.cyan.swiftUIColor)
        }
        .background(SharedUIComponentsAsset.systemBackground.swiftUIColor)
        .buttonStyle(.plain)
        .clipShape(Capsule())
        .shadow(color: .black.opacity(0.1), radius: 5)
    }
}

#Preview {
    VacancySugangSnuButton(action: {})
}
