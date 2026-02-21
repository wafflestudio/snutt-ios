//
//  LiveDependencies.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import AppReviewPromptInterface
import Dependencies
import Foundation

extension AppReviewServiceKey: @retroactive DependencyKey {
    public static let liveValue: any AppReviewService = AppReviewPromptUseCase()
    public static let previewValue: any AppReviewService = AppReviewServiceSpy()
}

private enum AppReviewPromptRepositoryKey: DependencyKey {
    static let liveValue: any AppReviewPromptRepository = AppReviewPromptUserDefaultsRepository()
}

private enum AppReviewRequesterKey: DependencyKey {
    static let liveValue: any AppReviewRequester = AppReviewStoreKitRequester()
}

private enum AppReviewStoreURLHandlerKey: DependencyKey {
    static let liveValue: any AppReviewStoreURLHandler = AppReviewStoreURLHandlerLive()
}

extension DependencyValues {
    var appReviewPromptRepository: any AppReviewPromptRepository {
        get { self[AppReviewPromptRepositoryKey.self] }
        set { self[AppReviewPromptRepositoryKey.self] = newValue }
    }

    var appReviewRequester: any AppReviewRequester {
        get { self[AppReviewRequesterKey.self] }
        set { self[AppReviewRequesterKey.self] = newValue }
    }

    var appReviewStoreURLHandler: any AppReviewStoreURLHandler {
        get { self[AppReviewStoreURLHandlerKey.self] }
        set { self[AppReviewStoreURLHandlerKey.self] = newValue }
    }

}
