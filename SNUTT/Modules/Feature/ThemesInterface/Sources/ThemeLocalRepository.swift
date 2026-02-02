//
//  ThemeLocalRepository.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Dependencies
import Spyable

@Spyable
public protocol ThemeLocalRepository: Sendable {
    func loadAvailableThemes() -> [Theme]
    func storeAvailableThemes(_ themes: [Theme])
}

public enum ThemeLocalRepositoryKey: TestDependencyKey {
    public static let testValue: any ThemeLocalRepository = {
        let spy = ThemeLocalRepositorySpy()
        spy.loadAvailableThemesReturnValue = [.snutt, .fall, .modern]
        return spy
    }()
}

extension DependencyValues {
    public var themeLocalRepository: any ThemeLocalRepository {
        get { self[ThemeLocalRepositoryKey.self] }
        set { self[ThemeLocalRepositoryKey.self] = newValue }
    }
}
