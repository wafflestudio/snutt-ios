//
//  LectureDiaryColors.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI
import UIKit

extension Color {
    // MARK: Background

    static var sceneBackground: Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? .black : SharedUIComponentsAsset.lightField.color })
    }

    static var cardBackground: Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? SharedUIComponentsAsset.groupBackground.color : .white })
    }

    static var summaryCardBackground: Color {
        Color(
            UIColor {
                $0.userInterfaceStyle == .dark
                    ? SharedUIComponentsAsset.groupBackground.color : SharedUIComponentsAsset.neutral98.color
            }
        )
    }

    static var confirmBackground: Color {
        Color(UIColor { $0.userInterfaceStyle == .dark ? SharedUIComponentsAsset.neutral5.color : .white })
    }

    // MARK: Foreground

    static var subtitleForeground: Color {
        Color(
            UIColor {
                $0.userInterfaceStyle == .dark
                    ? SharedUIComponentsAsset.gray30.color : SharedUIComponentsAsset.alternative.color
            }
        )
    }

    static var emptyDescriptionForeground: Color {
        Color(
            UIColor {
                $0.userInterfaceStyle == .dark
                    ? SharedUIComponentsAsset.gray30.color : UIColor.label.withAlphaComponent(0.5)
            }
        )
    }

    static var lectureTitleForeground: Color {
        Color(
            UIColor {
                $0.userInterfaceStyle == .dark
                    ? SharedUIComponentsAsset.assistive.color : SharedUIComponentsAsset.alternative.color
            }
        )
    }

    static var questionLabel: Color {
        Color(
            UIColor {
                $0.userInterfaceStyle == .dark
                    ? SharedUIComponentsAsset.alternative.color : SharedUIComponentsAsset.assistive.color
            }
        )
    }

    static var answerLabel: Color {
        Color(
            UIColor {
                $0.userInterfaceStyle == .dark
                    ? SharedUIComponentsAsset.assistive.color : SharedUIComponentsAsset.darkerGray.color
            }
        )
    }

    static var enabledButtonLabel: Color {
        Color(
            UIColor {
                $0.userInterfaceStyle == .dark
                    ? SharedUIComponentsAsset.darkMint1.color : SharedUIComponentsAsset.darkMint2.color
            }
        )
    }

    static var disabledButtonLabel: Color {
        Color(UIColor { _ in SharedUIComponentsAsset.gray30.color })
    }

    static var charCountForeground: Color {
        Color(
            UIColor {
                $0.userInterfaceStyle == .dark
                    ? SharedUIComponentsAsset.darkerGray.color : SharedUIComponentsAsset.alternative.color
            }
        )
    }

    // MARK: Components - OptionChip

    static var selectedOptionChipLabel: Color {
        Color(
            UIColor {
                $0.userInterfaceStyle == .dark
                    ? SharedUIComponentsAsset.darkMint1.color : SharedUIComponentsAsset.darkMint2.color
            }
        )
    }

    static var unselectedOptionChipLabel: Color {
        Color(
            UIColor {
                $0.userInterfaceStyle == .dark
                    ? SharedUIComponentsAsset.assistive.color : SharedUIComponentsAsset.darkerGray.color
            }
        )
    }

    static var optionChipBackground: Color {
        Color(
            UIColor {
                $0.userInterfaceStyle == .dark
                    ? SharedUIComponentsAsset.darkMint2.color : SharedUIComponentsAsset.cyan.color
            }
        ).opacity(0.08)
    }

    // MARK: Components - SemesterChip

    static var unselectedSemesterChipLabel: Color {
        Color(
            UIColor {
                $0.userInterfaceStyle == .dark
                    ? SharedUIComponentsAsset.assistive.color : SharedUIComponentsAsset.darkerGray.color
            }
        )
    }

    static var selectedSemesterChipBackground: Color {
        Color(
            UIColor {
                $0.userInterfaceStyle == .dark
                    ? SharedUIComponentsAsset.darkMint1.color : SharedUIComponentsAsset.cyan.color
            }
        )
    }

    static var unselectedSemesterChipBackground: Color {
        Color(
            UIColor {
                $0.userInterfaceStyle == .dark
                    ? SharedUIComponentsAsset.neutral5.color : SharedUIComponentsAsset.neutral98.color
            }
        )
    }

    // MARK: Components - Etc

    static var capsuleBorder: Color {
        Color(
            UIColor {
                $0.userInterfaceStyle == .dark
                    ? SharedUIComponentsAsset.gray30.color.withAlphaComponent(0.4)
                    : SharedUIComponentsAsset.border.color
            }
        )
    }

    static var questionDivider: Color {
        Color(
            UIColor {
                $0.userInterfaceStyle == .dark
                    ? SharedUIComponentsAsset.alternative.color.withAlphaComponent(0.4)
                    : SharedUIComponentsAsset.lightLine.color
            }
        )
    }

    static var extraSectionDivider: Color {
        Color(
            UIColor {
                $0.userInterfaceStyle == .dark
                    ? SharedUIComponentsAsset.gray30.color.withAlphaComponent(0.4)
                    : SharedUIComponentsAsset.lightLine.color
            }
        )
    }
}
