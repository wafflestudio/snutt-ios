//
//  ThemeDto.swift
//  SNUTT
//
//  Created by 이채민 on 2024/01/17.
//

import Foundation

struct ThemeDto: Codable {
    let id: String?
    let theme: Int
    let name: String
    let colors: [ThemeColorDto]?
    let isDefault: Bool
    let isCustom: Bool
}

struct ThemeColorDto: Codable {
    let bg: String
    let fg: String
}

extension ThemeColorDto {
    init(from model: LectureColor) {
        bg = model.bg.toHex()
        fg = model.fg.toHex()
    }
}

extension ThemeDto {
    init(from model: Theme) {
        id = model.id
        theme = model.theme?.rawValue ?? 0
        name = model.name
        colors = model.colors.map { ThemeColorDto(from: $0) }
        isDefault = false
        isCustom = model.isCustom
    }
}
