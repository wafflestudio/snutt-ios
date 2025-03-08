//
//  NewBadge.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI
import SharedUIComponents

struct NewBadge: View {
    var body: some View {
        Text("NEW!")
            .font(.system(size: 8, weight: .bold))
            .foregroundStyle(.white)
            .frame(width: 30, height: 14)
            .background(SharedUIComponentsAsset.cyan.swiftUIColor)
            .clipShape(.rect(cornerRadius: 3))
    }
}

#Preview {
    NewBadge()
}
