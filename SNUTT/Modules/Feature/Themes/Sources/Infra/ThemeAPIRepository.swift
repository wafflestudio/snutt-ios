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

    public func updateTheme(theme: Theme) async throws -> Theme {
        try await apiClient.modifyTheme(
            path: .init(themeId: theme.id),
            body: .json(
                theme.toPayload()
            )
        ).ok.body.json.toTheme()
    }

    public func createTheme(theme: Theme) async throws -> Theme {
        try await apiClient.addTheme(
            body: .json(
                theme.toPayload()
            )
        ).ok.body.json.toTheme()
    }
}

extension Theme {
    fileprivate func toPayload() -> Components.Schemas.TimetableThemeAddRequestDto {
        .init(
            colors: colors.map { .init(bg: $0.bgHex, fg: $0.fgHex) },
            name: name,
        )
    }
}

extension Theme.Status {
    fileprivate func toPayload() -> Components.Schemas.TimetableThemeDto.statusPayload {
        switch self {
        case .builtIn: .BASIC
        case .customDownloaded: .DOWNLOADED
        case .customPrivate: .PRIVATE
        case .customPublished: .PUBLISHED
        }
    }
}

extension Components.Schemas.TimetableThemeDto {
    fileprivate func toTheme() throws -> Theme {
        let colors: [LectureColor] =
            colors?.map { color in
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
        let status: Theme.Status =
            switch self.status {
            case .BASIC: .builtIn
            case .DOWNLOADED: .customDownloaded
            case .PRIVATE: .customPrivate
            case .PUBLISHED: .customPublished
            }
        return try .init(
            id: require(id),
            name: name,
            colors: colors,
            status: status
        )
    }
}
