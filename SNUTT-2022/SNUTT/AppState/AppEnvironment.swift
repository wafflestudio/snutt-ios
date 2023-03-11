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
        let globalUIService: GlobalUIServiceProtocol
        let courseBookService: CourseBookServiceProtocol
        let authService: AuthServiceProtocol
        let notificationService: NotificationServiceProtocol
        let popupService: PopupServiceProtocol
        let etcService: EtcServiceProtocol
    }
}

extension AppEnvironment {
    struct WebRepositories {
        let timetableRepository: TimetableRepositoryProtocol
        let userRepository: UserRepositoryProtocol
        let lectureRepository: LectureRepositoryProtocol
        let searchRepository: SearchRepositoryProtocol
        let courseBookRepository: CourseBookRepositoryProtocol
        let reviewRepository: ReviewRepositoryProtocol
        let authRepository: AuthRepositoryProtocol
        let notificationRepository: NotificationRepositoryProtocol
        let popupRepository: PopupRepositoryProtocol
        let etcRepository: EtcRepositoryProtocol
    }

    struct LocalRepositories {
        let userDefaultsRepository: UserDefaultsRepositoryProtocol
    }
}

extension AppEnvironment {
    static func bootstrap() -> Self {
        let appState = AppState()
        let session = configuredSession(appState: appState)
        let webRepos = configuredWebRepositories(session: session)
        let dbRepos = configuredDBRepositories(appState: appState)
        let services = configuredServices(appState: appState, webRepositories: webRepos, localRepositories: dbRepos)
        let container = DIContainer(appState: appState, services: services)

        /// Listens to the FCM token sent from `AppDelegate` and forwards it to the server.
        NotificationCenter.default.addObserver(forName: Notification.Name("FCMToken"), object: nil, queue: .main) { notification in
            guard let fcmToken = notification.userInfo?["token"] as? String else { return }
            Task {
                try await services.userService.addDevice(fcmToken: fcmToken)
            }
            print("FCM Token: \(fcmToken)")
        }

        /// We need to load access token ASAP in order to determine which screen to show first.
        /// Note that this should run synchronously on the main thread.
        services.authService.loadAccessTokenDuringBootstrap()
        services.globalUIService.loadColorSchemeDuringBootstrap()
        services.timetableService.loadTimetableConfig()
        services.lectureService.fetchIsFirstBookmark()

        return .init(container: container)
    }

    private static func configuredSession(appState: AppState) -> Session {
        return Session(interceptor: Interceptor(userState: appState.user), eventMonitors: [Logger()])
    }

    private static func configuredWebRepositories(session: Session) -> WebRepositories {
        let timetableRepository = TimetableRepository(session: session)
        let userRepository = UserRepository(session: session)
        let lectureRepository = LectureRepository(session: session)
        let searchRepository = SearchRepository(session: session)
        let reviewRepository = ReviewRepository(session: session)
        let courseBookRepository = CourseBookRepository(session: session)
        let authRepository = AuthRepository(session: session)
        let notificationRepository = NotificationRepository(session: session)
        let popupRepository = PopupRepository(session: session)
        let etcRepository = EtcRepository(session: session)

        return .init(timetableRepository: timetableRepository,
                     userRepository: userRepository,
                     lectureRepository: lectureRepository,
                     searchRepository: searchRepository,
                     courseBookRepository: courseBookRepository,
                     reviewRepository: reviewRepository,
                     authRepository: authRepository,
                     notificationRepository: notificationRepository,
                     popupRepository: popupRepository,
                     etcRepository: etcRepository)
    }

    private static func configuredDBRepositories(appState _: AppState) -> LocalRepositories {
        let userDefaultsRepository = UserDefaultsRepository(storage: .shared)
        return .init(userDefaultsRepository: userDefaultsRepository)
    }

    private static func configuredServices(appState: AppState, webRepositories: WebRepositories, localRepositories: LocalRepositories) -> Services {
        let timetableService = TimetableService(appState: appState, webRepositories: webRepositories, localRepositories: localRepositories)
        let userService = UserService(appState: appState, webRepositories: webRepositories, localRepositories: localRepositories)
        let lectureService = LectureService(appState: appState, webRepositories: webRepositories, localRepositories: localRepositories)
        let searchService = SearchService(appState: appState, webRepositories: webRepositories)
        let globalUIService = GlobalUIService(appState: appState, localRepositories: localRepositories)
        let courseBookService = CourseBookService(appState: appState, webRepositories: webRepositories)
        let authService = AuthService(appState: appState, webRepositories: webRepositories, localRepositories: localRepositories)
        let notificationService = NotificationService(appState: appState, webRepositories: webRepositories)
        let popupService = PopupService(appState: appState, webRepositories: webRepositories, localRepositories: localRepositories)
        let etcService = EtcService(appState: appState, webRepositories: webRepositories)
        return .init(timetableService: timetableService,
                     userService: userService,
                     lectureService: lectureService,
                     searchService: searchService,
                     globalUIService: globalUIService,
                     courseBookService: courseBookService,
                     authService: authService,
                     notificationService: notificationService,
                     popupService: popupService,
                     etcService: etcService)
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
                  globalUIService: GlobalUIService(appState: appState, localRepositories: .init(userDefaultsRepository: UserDefaultsRepository(storage: .preview))),
                  courseBookService: FakeCourseBookService(),
                  authService: FakeAuthService(),
                  notificationService: FakeNotificationService(),
                  popupService: FakePopupService(),
                  etcService: FakeEtcService())
        }
    }
#endif
