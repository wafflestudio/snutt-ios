//
//  SharedUIColors.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI
import UIKit

extension Color {
    // MARK: Background

    static var enabledRectButtonBackground: Color {
        Color(
            UIColor {
                $0.userInterfaceStyle == .dark
                    ? SharedUIComponentsAsset.darkMint1.color : SharedUIComponentsAsset.cyan.color
            }
        )
    }

    static var disabledRectButtonBackground: Color {
        Color(
            UIColor {
                $0.userInterfaceStyle == .dark
                    ? SharedUIComponentsAsset.darkerGray.color : SharedUIComponentsAsset.neutral95.color
            }
        )
    }

    // MARK: Foreground

    static var disabledRectButtonLabel: Color {
        Color(
            UIColor {
                $0.userInterfaceStyle == .dark
                    ? SharedUIComponentsAsset.neutral50.color : SharedUIComponentsAsset.assistive.color
            }
        )
    }
}
