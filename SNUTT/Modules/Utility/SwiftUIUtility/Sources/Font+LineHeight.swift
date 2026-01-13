//
//  Font+LineHeight.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI
import UIKit

extension View {
    /// `percentage` : 100 if 100%
    public func lineHeight(with font: UIFont, percentage: CGFloat) -> some View {
        if #available(iOS 26.0, *) {
            return
                self
                .font(Font(font))
                .lineHeight(.multiple(factor: percentage / 100))
        } else {
            let extra = font.pointSize * (percentage - 100) / 100
            let spacing = (extra * 0.5)
            return
                self
                .font(Font(font))
                .lineSpacing(spacing.rounded(.up))
                .padding(.vertical, spacing.rounded(.down))
        }
    }
}
