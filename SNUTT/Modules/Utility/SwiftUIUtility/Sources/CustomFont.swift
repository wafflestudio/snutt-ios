//
//  CustomFont.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI
import UIKit

public enum CustomFont {
    case bold17
    case bold16
    case regular16
    case bold15
    case semibold15
    case regular15
    case bold14
    case semibold14
    case medium14
    case regular14
    case semibold13
    case medium13
    case regular13
    case bold12
    case regular12
    case bold11
    case regular11

    public var uiFont: UIFont {
        switch self {
        case .bold17:
            return .systemFont(ofSize: 17, weight: .bold)
        case .bold16:
            return .systemFont(ofSize: 16, weight: .bold)
        case .regular16:
            return .systemFont(ofSize: 16, weight: .regular)
        case .bold15:
            return .systemFont(ofSize: 15, weight: .bold)
        case .semibold15:
            return .systemFont(ofSize: 15, weight: .semibold)
        case .regular15:
            return .systemFont(ofSize: 15, weight: .regular)
        case .bold14:
            return .systemFont(ofSize: 14, weight: .bold)
        case .semibold14:
            return .systemFont(ofSize: 14, weight: .semibold)
        case .medium14:
            return .systemFont(ofSize: 14, weight: .medium)
        case .regular14:
            return .systemFont(ofSize: 14, weight: .regular)
        case .semibold13:
            return .systemFont(ofSize: 13, weight: .semibold)
        case .medium13:
            return .systemFont(ofSize: 13, weight: .medium)
        case .regular13:
            return .systemFont(ofSize: 13, weight: .regular)
        case .bold12:
            return .systemFont(ofSize: 12, weight: .bold)
        case .regular12:
            return .systemFont(ofSize: 12, weight: .regular)
        case .bold11:
            return .systemFont(ofSize: 11, weight: .bold)
        case .regular11:
            return .systemFont(ofSize: 11, weight: .regular)
        }
    }

    public var font: Font {
        Font(uiFont)
    }
}

extension UIFont {
    public static func custom(_ style: CustomFont) -> UIFont {
        style.uiFont
    }
}

extension Font {
    public static func custom(_ style: CustomFont) -> Font {
        style.font
    }
}

extension View {
    /// `percentage` : 100 if 100%
    public func lineHeight(with font: CustomFont, percentage: CGFloat) -> some View {
        let extra = font.uiFont.pointSize * (percentage - 100) / 100
        let spacing = (extra * 0.5)

        return
            self
            .font(.custom(font))
            .lineSpacing(spacing.rounded(.up))
            .padding(.vertical, spacing.rounded(.down))
    }
}
