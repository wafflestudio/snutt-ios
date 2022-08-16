//
//  UserService.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/09.
//

import Foundation

protocol UserServiceProtocol {
//    var accountSettingTitles: [[MenuType]] { get }
//    var mainSettingTitles: [[MenuType]] { get }
    var userLocalId: String? { get }
    var token: String? { get }
    var fbName: String? { get }
}

struct UserService: UserServiceProtocol {
    let appState: AppState
    let webRepositories: AppEnvironment.WebRepositories
    
    var userServiceRepository: UserRepositoryProtocol {
        webRepositories.userRepository
    }

    init(appState: AppState, webRepositories: AppEnvironment.WebRepositories) {
        self.appState = appState
        self.webRepositories = webRepositories
    }

    var userLocalId: String? {
        userServiceRepository.userLocalId
    }
    
    var token: String? {
        userServiceRepository.token
    }

    var fbName: String? {
        userServiceRepository.fbName
    }
}

class FakeUserService: UserServiceProtocol {
//    var accountSettingTitles: [[MenuType]] = []
//    var mainSettingTitles: [[MenuType]] = []
    var userLocalId: String?
    var token: String?
    var fbName: String?
}
