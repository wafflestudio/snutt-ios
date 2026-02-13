//
//  LiveDependencies.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import APIClientInterface
import Analytics
import AnalyticsInterface
import Auth
import AuthInterface
import Configs
import ConfigsInterface
import Dependencies
import Reviews
import ReviewsInterface
import Themes
import ThemesInterface
import Timetable
import TimetableInterface
import Vacancy
import VacancyInterface

extension APIClientKey: @retroactive DependencyKey {
    public static let liveValue: any APIClientInterface.APIProtocol = APIClientProvider().apiClient()
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
}

extension AuthSecureRepositoryKey: @retroactive DependencyKey {
    public static let liveValue: any AuthSecureRepository = AuthKeychainRepository()
}

extension TimetableUIProviderKey: @retroactive DependencyKey {
    public static let liveValue: any TimetableUIProvidable = TimetableUIProvider()
}

extension ConfigsRepositoryKey: @retroactive DependencyKey {
    public static let liveValue: any ConfigsRepository = ConfigsAPIRepository()
}

extension VacancyRepositoryKey: @retroactive DependencyKey {
    public static let liveValue: any VacancyRepository = VacancyAPIRepository()
}

extension ThemeUIProviderKey: @retroactive DependencyKey {
    public static let liveValue: any ThemeUIProvidable = ThemeUIProvider()
}

extension AuthUIProviderKey: @retroactive DependencyKey {
    public static let liveValue: any AuthUIProvidable = AuthUIProvider()
}

extension ReviewsUIProviderKey: @retroactive DependencyKey {
    public static let liveValue: any ReviewsUIProvidable = ReviewsUIProvider()
}

extension ThemeRepositoryKey: @retroactive DependencyKey {
    public static let liveValue: any ThemeRepository = ThemeAPIRepository()
}

extension SocialAuthServiceProviderKey: @retroactive DependencyKey {
    public static let liveValue: any SocialAuthServiceProvider = LiveSocialAuthServiceProvider()
}

extension AnalyticsSDKKey: @retroactive DependencyKey {
    public static let liveValue: any AnalyticsSDK = FirebaseAnalyticsSDK()
}

extension AnalyticsLoggerKey: @retroactive DependencyKey {
    public static let liveValue: any AnalyticsLogger = FirebaseAnalyticsLogger()
}
