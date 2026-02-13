//
//  LiveDependencies.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies
import ThemesInterface

extension ThemeLocalRepositoryKey: @retroactive DependencyKey {
    public static let liveValue: any ThemeLocalRepository = ThemeUserDefaultsRepository()
}
