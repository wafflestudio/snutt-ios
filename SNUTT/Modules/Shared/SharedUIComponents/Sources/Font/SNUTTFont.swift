//
//  SNUTTFont.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI
import UIKit

public struct SNUTTFont {
    public static let bold17: UIFont = .systemFont(ofSize: 17, weight: .bold)

    public static let semibold16: UIFont = .systemFont(ofSize: 16, weight: .semibold)
    public static let regular16: UIFont = .systemFont(ofSize: 16)

    public static let semibold15: UIFont = .systemFont(ofSize: 15, weight: .semibold)
    public static let regular15: UIFont = .systemFont(ofSize: 15)

    public static let bold14: UIFont = .systemFont(ofSize: 14, weight: .bold)
    public static let semibold14: UIFont = .systemFont(ofSize: 14, weight: .semibold)
    public static let medium14: UIFont = .systemFont(ofSize: 14, weight: .medium)
    public static let regular14: UIFont = .systemFont(ofSize: 14)

    public static let regular13: UIFont = .systemFont(ofSize: 13)

    public static let regular12: UIFont = .systemFont(ofSize: 12)

    public static let bold11: UIFont = .systemFont(ofSize: 11, weight: .bold)
    public static let regular11: UIFont = .systemFont(ofSize: 11)
}

extension UIFont {
    public var font: Font {
        Font(self as CTFont)
    }
}

extension Text {
    /// `percentage` : 100 if 100%
    func lineHeight(with font: UIFont, percentage: CGFloat) -> some View {
        let roundedSpacing = ((font.pointSize * (percentage - 100) / 100) * 0.5)
        return self
            .font(font.font)
            .lineSpacing(roundedSpacing.rounded(.up) + 1)
            .padding(.vertical, roundedSpacing.rounded(.down))
    }
}
