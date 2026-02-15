//
//  ThemeType.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

public enum ThemeType: Codable, Sendable, Equatable, Identifiable {
    public var id: String {
        switch self {
        case let .builtInTheme(theme):
            theme.id
        case let .customTheme(themeID):
            themeID
        }
    }

    /// 내장된 테마
    case builtInTheme(Theme)
    case customTheme(themeID: String)
}

extension Theme {
    public var type: ThemeType {
        if isCustom {
            .customTheme(themeID: id)
        } else {
            .builtInTheme(self)
        }
    }
}
