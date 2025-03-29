//
//  ConfigsRepository.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Dependencies
import Foundation

@Spyable
public protocol ConfigsRepository: Sendable {
    func fetchConfigs() async throws -> ConfigsModel
}

public enum ConfigsRepositoryKey: TestDependencyKey {
    public static let testValue: any ConfigsRepository = {
        let spy = ConfigsRepositorySpy()
        var model = ConfigsModel.empty
        model.vacancySugangSnuUrl?.url = URL(string: "https://sugang.snu.ac.kr/sugang/cc/cc100InterfaceSrch.action")!
        spy.fetchConfigsReturnValue = model
        return spy
    }()
}

extension DependencyValues {
    public var configsRepository: any ConfigsRepository {
        get { self[ConfigsRepositoryKey.self] }
        set { self[ConfigsRepositoryKey.self] = newValue }
    }
}
