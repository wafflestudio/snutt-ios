//
//  LiveDependencies.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Dependencies
import Foundation

struct FriendsRepositoryKey: DependencyKey {
    static let liveValue: any FriendsRepository = FriendsAPIRepository()
    #if DEBUG
        static let previewValue: any FriendsRepository = FakeFriendsRepository()
    #endif
}

extension DependencyValues {
    var friendsRepository: any FriendsRepository {
        get { self[FriendsRepositoryKey.self] }
        set { self[FriendsRepositoryKey.self] = newValue }
    }
}

struct FriendsLocalRepositoryKey: DependencyKey {
    static let liveValue: any FriendsLocalRepository = FriendsUserDefaultsRepository()
    static let previewValue: any FriendsLocalRepository = FriendsLocalRepositorySpy()
}

extension DependencyValues {
    var friendsLocalRepository: any FriendsLocalRepository {
        get { self[FriendsLocalRepositoryKey.self] }
        set { self[FriendsLocalRepositoryKey.self] = newValue }
    }
}

extension KakaoShareServiceKey: DependencyKey {
    static let liveValue: any KakaoShareService = KakaoSDKShareService()

    static let previewValue: any KakaoShareService = {
        let spy = KakaoShareServiceSpy()
        spy.isKakaoTalkSharingAvailableReturnValue = false
        return spy
    }()
}
