//
//  Theme.swift
//  SNUTT
//
//  Created by 이채민 on 2024/01/17.
//

import Foundation
import SwiftUI

struct Theme: Equatable, Identifiable {
    var id: String

    /// 제공 테마라면 그 종류 (커스텀 테마의 경우 .snutt로 저장)
    var theme: BasicTheme?

    var name: String

    var colors: [LectureColor]

    /// 사용자 생성 커스텀 테마
    var isCustom: Bool
    
    var status: ThemeStatus?
}

enum ThemeStatus: String, Codable {
    case basic = "BASIC"
    case downloaded = "DOWNLOADED"
    case published = "PUBLISHED"
}

extension Theme {
    init(from dto: ThemeDto) {
        id = dto.id ?? UUID().uuidString
        theme = .init(rawValue: dto.theme)
        name = dto.name
        colors = dto.colors?.map { .init(fg: Color(hex: $0.fg), bg: Color(hex: $0.bg)) } ?? []
        isCustom = dto.isCustom
        status = ThemeStatus(rawValue: dto.status)
    }

    init(rawValue: Int) {
        id = ""
        theme = BasicTheme(rawValue: rawValue)
        name = theme?.name ?? ""
        colors = theme?.getLectureColorList() ?? []
        isCustom = false
        status = .basic
    }
}
