//
//  STFont.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/03/30.
//

import SwiftUI
import UIKit

struct STFont {
    static let bold17: UIFont = .systemFont(ofSize: 17, weight: .bold)

    static let bold16: UIFont = .systemFont(ofSize: 16, weight: .bold)
    static let regular16: UIFont = .systemFont(ofSize: 16)

    static let bold15: UIFont = .systemFont(ofSize: 15, weight: .bold)
    static let semibold15: UIFont = .systemFont(ofSize: 15, weight: .semibold)
    static let regular15: UIFont = .systemFont(ofSize: 15)

    static let bold14: UIFont = .systemFont(ofSize: 14, weight: .bold)
    static let semibold14: UIFont = .systemFont(ofSize: 14, weight: .semibold)
    static let medium14: UIFont = .systemFont(ofSize: 14, weight: .medium)
    static let regular14: UIFont = .systemFont(ofSize: 14)

    static let regular13: UIFont = .systemFont(ofSize: 13)

    static let regular12: UIFont = .systemFont(ofSize: 12)

    static let bold11: UIFont = .systemFont(ofSize: 11, weight: .bold)
    static let regular11: UIFont = .systemFont(ofSize: 11)
}

extension UIFont {
    var font: Font {
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
