//
//  LiveDependencies.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Dependencies
import Timetable
import TimetableInterface
import Auth
import AuthInterface
import APIClientInterface

extension APIClientKey: @retroactive DependencyKey {
    public static let liveValue: any APIProtocol = APIClientProvider().apiClient()
}

extension TimetableRepositoryKey: @retroactive DependencyKey {
    public static let liveValue: any TimetableRepository = TimetableAPIRepository()
}

extension AuthRepositoryKey: @retroactive DependencyKey {
    public static let liveValue: any AuthRepository = AuthAPIRepository()
}

extension AuthStateKey: @retroactive DependencyKey {
    public static let liveValue: any AuthState = AuthUserState()
    public static let testValue: any AuthState = AuthUserState()
}

extension AuthSecureRepositoryKey: @retroactive DependencyKey {
    public static let liveValue: any AuthSecureRepository = AuthKeychainRepository()
}
