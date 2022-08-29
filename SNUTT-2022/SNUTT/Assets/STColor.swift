//
//  STColor.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/03/30.
//

import Foundation
import SwiftUI

struct STColor {
    static let cyan: Color = .init(hex: 0x1BD0C8)

    static let disabled: Color = .init(uiColor: .label.withAlphaComponent(0.6))

    static let navBackground: Color = .init("nav.background")
    static let tabBackground: Color = .init("tab.background")

    static let groupForeground: Color = .init("group.foreground")
    static let groupBackground: Color = .init("group.background")
    static let searchBarBackground: Color = .init("searchbar.background")
    static let searchListBackground: Color = .init("searchlist.background")
    static let searchListForeground: Color = .init("searchlist.foreground")
    static let sheetBackground: Color = .init("sheet.background")
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

        if str.count != 6 {
            self.init(uiColor: .gray)
            return
        }

        var rgbValue: UInt64 = 0
        Scanner(string: str).scanHexInt64(&rgbValue)

        self.init(hex: rgbValue, alpha: alpha)
    }

    func toHex() -> String {
        return UIColor(self).toHex()
    }
}

extension UIColor {
    convenience init(hex: UInt64, alpha: Double = 1) {
        self.init(.init(hex: hex, alpha: alpha))
    }

    convenience init(hex: String, alpha: Double = 1) {
        self.init(.init(hex: hex, alpha: alpha))
    }

    func toHex() -> String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0

        getRed(&r, green: &g, blue: &b, alpha: &a)

        let rgb = Int(r * 255) << 16 | Int(g * 255) << 8 | Int(b * 255) << 0

        return String(format: "#%06x", rgb)
    }
}
