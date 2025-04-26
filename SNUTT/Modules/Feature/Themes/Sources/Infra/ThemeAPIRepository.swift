//
//  ThemeAPIRepository.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import APIClientInterface
import Dependencies
import ThemesInterface

public struct ThemeAPIRepository: ThemeRepository {
    @Dependency(\.apiClient) private var apiClient

    public init() {}

    public func fetchThemes() async throws -> [Theme] {
        try await Task.sleep(for: .seconds(3))
        return try await apiClient.getThemes(query: .init(state: "")).ok.body.json
            .compactMap { dto in
                try? dto.toTheme()
            }
    }
}

extension Components.Schemas.TimetableThemeDto {
    fileprivate func toTheme() throws -> Theme {
        let colors: [LectureColor] = colors?.map { color in
            if let fg = color.fg, let bg = color.bg {
                LectureColor(fgHex: fg, bgHex: bg)
            } else {
                LectureColor.temporary
            }
        } ?? []
        if !isCustom {
            return switch theme {
            case ._0: .snutt
            case ._1: .fall
            case ._2: .modern
            case ._3: .cherryBlossom
            case ._4: .ice
            case ._5: .lawn
            }
        }
        return try .init(
            id: require(id),
            name: name,
            colors: colors,
            isCustom: isCustom
        )
    }
}
