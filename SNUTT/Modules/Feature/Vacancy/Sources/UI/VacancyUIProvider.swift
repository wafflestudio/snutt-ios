//
//  VacancyUIProvider.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import VacancyInterface

public struct VacancyUIProvider: VacancyUIProvidable {
    public init() {}
    public func makeVacancyScene() -> VacancyScene {
        VacancyScene()
    }
}
