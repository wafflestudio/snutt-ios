//
//  Theme.swift
//  SNUTT
//
//  Created by 이채민 on 2024/01/17.
//

import Foundation
import SwiftUI

struct Theme {
    var id: String
    var theme: BasicTheme?
    var name: String
    var colors: [LectureColor]
    var isDefault: Bool
    var isCustom: Bool
}

extension Theme {
    init(from dto: ThemeDto) {
        id = dto.id ?? UUID().uuidString
        theme = BasicTheme(rawValue: dto.theme)
        name = dto.name
        colors = dto.colors?.map { .init(fg: Color(hex: $0.fg), bg: Color(hex: $0.bg)) } ?? []
        isDefault = dto.isDefault
        isCustom = dto.isCustom
    }
}
