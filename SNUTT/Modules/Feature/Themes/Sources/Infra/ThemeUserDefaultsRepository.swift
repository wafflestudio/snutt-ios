//
//  ThemeUserDefaultsRepository.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Dependencies
import DependenciesUtility
import Foundation
import ThemesInterface

struct ThemeUserDefaultsRepository: ThemeLocalRepository {
    @Dependency(\.userDefaults) private var userDefaults
    @Dependency(\.widgetReloader) private var widgetReloader

    func loadAvailableThemes() -> [Theme] {
        guard let data = userDefaults.data(forKey: Keys.availableThemes.rawValue),
            let themes = try? JSONDecoder().decode([Theme].self, from: data)
        else { return [] }
        return themes
    }

    func storeAvailableThemes(_ themes: [Theme]) {
        guard let data = try? JSONEncoder().encode(themes) else { return }
        userDefaults.set(data, forKey: Keys.availableThemes.rawValue)
        widgetReloader.reloadAll()
    }

    private enum Keys: String {
        case availableThemes
    }
}
