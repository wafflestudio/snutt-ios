//
//  SNUTTFont.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI

extension String {
    // FIXME: `ResetPasswordScene` 진행할 때
    /// `percentage` : 100 if 100%
    func lineHeight(size: CGFloat, percentage: CGFloat) -> some View {
        let attributedString = AttributedString(self)
        var mutableAttributedString = NSMutableAttributedString(attributedString)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = size * (percentage / 100.0)
        
        mutableAttributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: .init(location: .zero, length: mutableAttributedString.length))
        
        return Text(AttributedString(mutableAttributedString))
    }
}
