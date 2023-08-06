//
//  STColor.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/03/30.
//

import Foundation
import SwiftUI

struct STColor {
    static let cyan: Color = .init("cyan")

    /// Used in banner.
    static let secondaryCyan: Color = .init("cyan.secondary")
    static let red: Color = .init(hex: "#E54459")

    static let vacancyBlue: Color = .init(hex: "#446CC2")
    static let vacancyRed: Color = .init(hex: "#ED6C58")
    static let vacancyRedBackground: Color = vacancyRed.opacity(0.05)

    /// RGB 196-196-196 /
    /// Hex #C4C4C4
    static let gray: Color = .init(hex: "#C4C4C4")

    static let disabled: Color = .init(uiColor: .label.withAlphaComponent(0.6))

    static let navBackground: Color = .init("nav.background")
    static let tabBackground: Color = .init("tab.background")

    static let groupForeground: Color = .init("group.foreground")
    static let groupBackground: Color = .init("group.background")
    static let searchBarBackground: Color = .init("searchbar.background")
    static let searchListBackground: Color = .init("searchlist.background")
    static let searchListForeground: Color = .init("searchlist.foreground")
    static let sheetBackground: Color = .init("sheet.background")
    static let whiteTranslucent: Color = .init("white.translucent")
    static let buttonPressed: Color = .init("button.pressed")

    #if WIDGET
        static let systemBackground: Color = .init("widget.background")
    #else
        static let systemBackground: Color = .init("system.background")
    #endif
}

extension Color {
    init(hex: UInt64, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 08) & 0xFF) / 255,
            blue: Double((hex >> 00) & 0xFF) / 255,
            opacity: alpha
        )
    }

    init(hex: String, alpha: Double = 1) {
        var str: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        str = str.replacingOccurrences(of: "#", with: "")
        str = str.replacingOccurrences(of: "0X", with: "")

        // for aRGB
        if str.count == 8 {
            str = String(str.suffix(6))
        }

        // fallback
        if str.count != 6 {
            self.init(.init(LectureColor.temporary.bg))
            return
        }

        var rgbValue: UInt64 = 0
        Scanner(string: str).scanHexInt64(&rgbValue)

        self.init(hex: rgbValue, alpha: alpha)
    }

    func toHex() -> String {
        let uiColor = UIColor(self)
        guard let components = uiColor.cgColor.components, components.count >= 3 else {
            return ""
        }

        let red = lroundf(Float(components[0]) * 255)
        let green = lroundf(Float(components[1]) * 255)
        let blue = lroundf(Float(components[2]) * 255)

        return String(format: "#%02X%02X%02X", red, green, blue)
    }
}
