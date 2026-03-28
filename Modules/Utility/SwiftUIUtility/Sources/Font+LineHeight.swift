//
//  Font+LineHeight.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI
import UIKit

extension View {
    /// `lineHeightMultiple` : 1 if 100%
    public func font(_ font: UIFont, lineHeightMultiple: CGFloat) -> some View {
        if #available(iOS 26.0, *) {
            return
                self
                .font(Font(font))
                .lineHeight(.multiple(factor: lineHeightMultiple))
        } else {
            let extra = font.pointSize * lineHeightMultiple
            let spacing = (extra * 0.5)
            return
                self
                .font(Font(font))
                .lineSpacing(spacing.rounded(.up))
                .padding(.vertical, spacing.rounded(.down))
        }
    }
}
