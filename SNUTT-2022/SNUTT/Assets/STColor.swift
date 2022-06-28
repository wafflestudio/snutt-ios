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
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}
