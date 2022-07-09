//
//  UserService.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/09.
//

import Foundation

protocol UserServiceProtocol {}

class UserService: UserServiceProtocol {
    let appState: AppState
    let webRepositories: AppEnvironment.WebRepositories
    
    init(appState: AppState, webRepositories: AppEnvironment.WebRepositories) {
        self.appState = appState
        self.webRepositories = webRepositories
    }
}

class FakeUserService: UserServiceProtocol {
    
}
