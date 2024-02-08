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

    /// 기본 테마: 앞으로 생성되는 시간표에 모두 적용
    var isDefault: Bool

    /// 사용자 생성 커스텀 테마
    var isCustom: Bool
}

extension Theme {
    init(from dto: ThemeDto) {
        id = dto.id ?? UUID().uuidString
        theme = .init(rawValue: dto.theme)
        name = dto.name
        colors = dto.colors?.map { .init(fg: Color(hex: $0.fg), bg: Color(hex: $0.bg)) } ?? []
        isDefault = dto.isDefault
        isCustom = dto.isCustom
    }

    init(rawValue: Int) {
        id = ""
        theme = BasicTheme(rawValue: rawValue)
        name = theme?.name ?? ""
        colors = theme?.getLectureColorList() ?? []
        isDefault = false
        isCustom = false
    }
}
