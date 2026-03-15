//
//  RoundedRectButton.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI

public struct RoundedRectButton: View {
    private let label: String
    private let tracking: CGFloat
    private let type: ButtonType
    private let action: () -> Void

    @Environment(\.isEnabled) private var isEnabled

    public init(
        label: String,
        tracking: CGFloat = 0,
        type: ButtonType,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.tracking = tracking
        self.type = type
        self.action = action
    }

    public var body: some View {
        Button {
            action()
        } label: {
            Text(label)
                .tracking(tracking)
                .foregroundStyle(
                    isEnabled
                        ? .white
                        : Color.disabledRectButtonLabel
                )
                .font(type.font)
                .padding(.vertical, type.verticalPadding)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: type.cornerRadius)
                        .fill(
                            isEnabled
                                ? Color.enabledRectButtonBackground
                                : Color.disabledRectButtonBackground
                        )
                )
        }
    }
}

extension RoundedRectButton {
    public enum ButtonType {
        case max
        case medium

        var cornerRadius: CGFloat { 6 }

        var font: Font {
            switch self {
            case .max: .system(size: 16, weight: .bold)
            case .medium: .system(size: 15, weight: .bold)
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
