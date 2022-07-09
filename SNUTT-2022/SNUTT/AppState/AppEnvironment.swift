//
//  AppEnvironment.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/09.
//

import Foundation
import Alamofire

struct AppEnvironment {
    let container: DIContainer
}

extension AppEnvironment {
    struct Services {
        let timetableService: TimetableService
        let userService: UserService
    }
}

extension AppEnvironment {
    struct WebRepositories {
        let timetableRepository: TimetableRepositoryProtocol
        let userRepository: UserRepositoryProtocol
    }
    
    struct DBRepositories {
    }
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
        return Session(interceptor: Interceptor(authStorage: Storage()), eventMonitors: [Logger()])
    }
    
    private static func configuredWebRepositories(session: Session) -> WebRepositories {
        let timetableRepository = TimetableRepository(session: session)
        let userRepository = UserRepository(session: session)
        return .init(timetableRepository: timetableRepository, userRepository: userRepository)
    }
    
    // unused for now
    private static func configuredDBRepositories(appState: AppState) -> DBRepositories {
        return .init()
    }
    
    private static func configuredServices(appState: AppState, webRepositories: WebRepositories, dbRepositories: DBRepositories) -> Services {
        let timetableService = TimetableService(appState: appState, webRepositories: webRepositories)
        let userService = UserService(appState: appState, webRepositories: webRepositories)
        return .init(timetableService: timetableService, userService: userService)
    }
}
