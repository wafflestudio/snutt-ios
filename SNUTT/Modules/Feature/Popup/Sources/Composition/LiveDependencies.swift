//
//  LiveDependencies.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Dependencies

struct PopupLocalRepositoryKey: DependencyKey {
    static let liveValue: any PopupLocalRepository = PopupUserDefaultsRepository()
}

struct PopupServerRepositoryKey: DependencyKey {
    static let liveValue: any PopupServerRepository = PopupAPIRepository()

    static let previewValue: any PopupServerRepository = {
        let spy = PopupServerRepositorySpy()
        spy.fetchPopupsReturnValue = [
            .init(key: "123", imageUri: "https://picsum.photos/200/300", hiddenDays: 3),
        ]
        return spy
    }()
}

extension DependencyValues {
    var popupLocalRepository: any PopupLocalRepository {
        get { self[PopupLocalRepositoryKey.self] }
        set { self[PopupLocalRepositoryKey.self] = newValue }
    }

    var popupServerRepository: any PopupServerRepository {
        get { self[PopupServerRepositoryKey.self] }
        set { self[PopupServerRepositoryKey.self] = newValue }
    }
}
