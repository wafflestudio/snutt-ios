//
//  LiveDependencies.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import APIClientInterface
import Auth
import AuthInterface
import Dependencies
import Timetable
import TimetableInterface

extension APIClientKey: @retroactive DependencyKey {
    public static let liveValue: any APIProtocol = APIClientProvider().apiClient()
}

extension TimetableRepositoryKey: @retroactive DependencyKey {
    public static let liveValue: any TimetableRepository = TimetableAPIRepository()
}

extension AuthRepositoryKey: @retroactive DependencyKey {
    public static let liveValue: any AuthRepository = AuthAPIRepository()
}

extension AuthUseCaseKey: @retroactive DependencyKey {
    public static let liveValue: any AuthUseCaseProtocol = AuthUseCase()
}

extension AuthStateKey: @retroactive DependencyKey {
    public static let liveValue: any AuthState = AuthUserState()
    public static let testValue: any AuthState = AuthUserState()
}

extension AuthSecureRepositoryKey: @retroactive DependencyKey {
    public static let liveValue: any AuthSecureRepository = AuthKeychainRepository()
}
