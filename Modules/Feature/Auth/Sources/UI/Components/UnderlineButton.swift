//
//  UnderlineButton.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

struct UnderlineButton: View {
    let label: String
    let action: () -> Void

    private enum Design {
        static let fontColor = UIColor.secondaryLabel
    }

    var body: some View {
        Button {
            action()
        } label: {
            Text(label)
                .font(.system(size: 14))
                .foregroundStyle(Color(Design.fontColor))
                .underline(color: Color(Design.fontColor))
        }
        .buttonStyle(.animatable)
    }
}
