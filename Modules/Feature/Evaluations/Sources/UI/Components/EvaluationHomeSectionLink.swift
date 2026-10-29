//
//  EvaluationHomeSectionLink.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

struct EvaluationHomeSectionLink: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 8) {
                Spacer(minLength: 0)

                Text(title)
                    .font(.system(size: 13, weight: .medium))
                Image(systemName: "chevron.right")
                    .font(.system(size: 11, weight: .semibold))

                Spacer(minLength: 0)
            }
            .foregroundStyle(Color(uiColor: .tertiaryLabel))
            .padding(.horizontal, 20)
            .frame(height: 54)
            .contentShape(Rectangle())
        }
        .buttonStyle(.animatable())
    }
}

#Preview {
    EvaluationHomeSectionLink(title: "강의평 전체보기", action: {})
        .background(Color(uiColor: .systemBackground))
}
