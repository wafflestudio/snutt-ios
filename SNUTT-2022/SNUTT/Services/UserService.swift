//
//  UserService.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/09.
//

import Foundation

protocol UserServiceProtocol {}

struct UserService: UserServiceProtocol {
    let appState: AppState
    let webRepositories: AppEnvironment.WebRepositories
}

struct FakeUserService: UserServiceProtocol {}
