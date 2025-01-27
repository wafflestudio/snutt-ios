//
//  RoundedRectButton.swift
//  SNUTT
//
//  Created by 최유림 on 11/4/24.
//

import SwiftUI

struct RoundedRectButton: View {
    let label: String
    var tracking: CGFloat = 0
    let type: ButtonType

    let disabled: Bool
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Text(label)
                .tracking(tracking)
                .foregroundStyle(disabled ? STColor.assistive : .white)
                .font(type.font)
                .padding(.vertical, type.verticalPadding)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: type.cornerRadius)
                        .fill(disabled ? STColor.neutral95 : STColor.cyan)
                )
                .drawingGroup()
        }
        .disabled(disabled)
    }
}

extension RoundedRectButton {
    enum ButtonType {
        case max
        case medium

        var cornerRadius: CGFloat {
            return 6
        }

        var font: Font {
            switch self {
            case .max: STFont.bold16.font
            case .medium: STFont.bold15.font
            }
        }

        var verticalPadding: CGFloat {
            switch self {
            case .max: 14
            case .medium: 12
            }
        }
    }
}
