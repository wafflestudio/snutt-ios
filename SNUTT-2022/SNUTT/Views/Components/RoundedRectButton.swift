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
    
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Button {
            action()
        } label: {
            Text(label)
                .tracking(tracking)
                .foregroundStyle(labelColor(disabled: disabled))
                .font(type.font)
                .padding(.vertical, type.verticalPadding)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: type.cornerRadius)
                        .fill(backgroundColor(disabled: disabled, colorScheme: colorScheme))
                )
                .drawingGroup()
        }
        .disabled(disabled)
    }
    
    private func labelColor(disabled: Bool) -> Color {
        disabled ? STColor.assistive : .white
    }
    
    private func backgroundColor(disabled: Bool, colorScheme: ColorScheme) -> Color {
        disabled
        ? (colorScheme == .dark ? STColor.darkerGray : STColor.neutral95)
        : (colorScheme == .dark ? STColor.darkMint1 : STColor.lightCyan)
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
