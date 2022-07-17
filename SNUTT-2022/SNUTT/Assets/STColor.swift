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
}
