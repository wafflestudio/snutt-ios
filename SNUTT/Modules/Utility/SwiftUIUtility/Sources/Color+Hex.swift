//
//  Color+Hex.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//
import SwiftUI

extension Color {
    public init(hex: UInt64, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 08) & 0xFF) / 255,
            blue: Double((hex >> 00) & 0xFF) / 255,
            opacity: alpha
        )
    }

    public init(hex: String, alpha: Double = 1) {
        var str: String = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()

        str = str.replacingOccurrences(of: "#", with: "")
        str = str.replacingOccurrences(of: "0X", with: "")

        // for aRGB
        if str.count == 8 {
            str = String(str.suffix(6))
        }

        // fallback
        if str.count != 6 {
            self.init(Color.clear)
            return
        }

        var rgbValue: UInt64 = 0
        Scanner(string: str).scanHexInt64(&rgbValue)

        self.init(hex: rgbValue, alpha: alpha)
    }

    public func toHex() -> String {
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
