//
//  AppEnvironment.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/09.
//

import Alamofire
import Foundation
import SwiftUI

struct AppEnvironment {
    let container: DIContainer
}

extension AppEnvironment {
    struct Services {
        let timetableService: TimetableServiceProtocol
        let userService: UserServiceProtocol
        let lectureService: LectureServiceProtocol
        let searchService: SearchServiceProtocol
        let appService: AppServiceProtocol
        let courseBookService: CourseBookServiceProtocol
    }
}

extension AppEnvironment {
    struct WebRepositories {
        let timetableRepository: TimetableRepositoryProtocol
        let userRepository: UserRepositoryProtocol
        let lectureRepository: LectureRepositoryProtocol
        let searchRepository: SearchRepositoryProtocol
        let courseBookRepository: CourseBookRepositoryProtocol
    }

    struct DBRepositories {}
}

extension AppEnvironment {
    static func bootstrap() -> Self {
        let appState = AppState()
        let session = configuredSession()
        let webRepos = configuredWebRepositories(session: session)
        let dbRepos = configuredDBRepositories(appState: appState)
        let services = configuredServices(appState: appState, webRepositories: webRepos, dbRepositories: dbRepos)
        let container = DIContainer(appState: appState, services: services)
        return .init(container: container)
    }

    private static func configuredSession() -> Session {
        let storage = Storage()
        storage.accessToken = "c7f446a2..."
        storage.apiKey = "eyJ0eXAiO..."
        return Session(interceptor: Interceptor(authStorage: storage), eventMonitors: [Logger()])
    }

    private static func configuredWebRepositories(session: Session) -> WebRepositories {
        let timetableRepository = TimetableRepository(session: session)
        let userRepository = UserRepository(session: session)
        let lectureRepository = LectureRepository(session: session)
        let searchRepository = SearchRepository(session: session)
        let courseBookRepository = CourseBookRepository(session: session)
        return .init(timetableRepository: timetableRepository,
                     userRepository: userRepository,
                     lectureRepository: lectureRepository,
                     searchRepository: searchRepository,
                     courseBookRepository: courseBookRepository)
    }

    // unused for now
    private static func configuredDBRepositories(appState _: AppState) -> DBRepositories {
        return .init()
    }

    private static func configuredServices(appState: AppState, webRepositories: WebRepositories, dbRepositories _: DBRepositories) -> Services {
        let timetableService = TimetableService(appState: appState, webRepositories: webRepositories)
        let userService = UserService(appState: appState, webRepositories: webRepositories)
        let lectureService = LectureService(appState: appState, webRepositories: webRepositories)
        let searchService = SearchService(appState: appState, webRepositories: webRepositories)
        let appService = AppService(appState: appState)
        let courseBookService = CourseBookService(appState: appState, webRepositories: webRepositories)
        return .init(timetableService: timetableService,
                     userService: userService,
                     lectureService: lectureService,
                     searchService: searchService,
                     appService: appService,
                     courseBookService: courseBookService)
    }
}

private struct AppEnvironmentKey: EnvironmentKey {
    static let defaultValue: DIContainer? = nil
}

extension EnvironmentValues {
    var dependencyContainer: DIContainer? {
        get { self[AppEnvironmentKey.self] }
        set { self[AppEnvironmentKey.self] = newValue }
    }
}

#if DEBUG
    extension AppEnvironment.Services {
        static func preview(appState: AppState) -> Self {
            .init(timetableService: FakeTimetableService(),
                  userService: FakeUserService(),
                  lectureService: FakeLectureService(),
                  searchService: FakeSearchService(),
                  appService: AppService(appState: appState),
                  courseBookService: FakeCourseBookService())
        }
    }
#endif
