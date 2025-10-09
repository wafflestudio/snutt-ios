//
//  ThemeRepository.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Dependencies
import Spyable

@Spyable
public protocol ThemeRepository: Sendable {
    func fetchThemes() async throws -> [Theme]
    func updateTheme(theme: Theme) async throws -> Theme
    func createTheme(theme: Theme) async throws -> Theme
}

public struct ThemeRepositoryKey: TestDependencyKey {
    public static let testValue: any ThemeRepository = {
        let spy = ThemeRepositorySpy()
        spy.fetchThemesReturnValue = [.preview1, .preview2, .preview3, .snutt, .cherryBlossom, .fall]
        spy.updateThemeThemeReturnValue = .preview1
        spy.createThemeThemeReturnValue = .preview1
        return spy
    }()
}

extension DependencyValues {
    public var themeRepository: any ThemeRepository {
        get { self[ThemeRepositoryKey.self] }
        set { self[ThemeRepositoryKey.self] = newValue }
    }
}
