//
//  UserService.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/09.
//

import Foundation

protocol UserServiceProtocol {
    var userLocalId: String? { get }
    var token: String? { get }
    var fbName: String? { get }
    func fetchUser() async throws
    func cache(user: UserDto)
}

struct UserService: UserServiceProtocol, LocalCachable {
    var local: SNUTTDefaultsContainer = SNUTTDefaultsContainer()
    
    let appState: AppState
    let webRepositories: AppEnvironment.WebRepositories
    
    var userRepository: UserRepositoryProtocol {
        webRepositories.userRepository
    }

    init(appState: AppState, webRepositories: AppEnvironment.WebRepositories) {
        self.appState = appState
        self.webRepositories = webRepositories
    }

    var userLocalId: String? {
        userRepository.userLocalId
    }
    
    var token: String? {
        userRepository.token
    }

    var fbName: String? {
        userRepository.fbName
    }
    
    func fetchUser() async throws {
        let userDto = try await userRepository.getUser()
        let user = User(from: userDto)
        cache(user: userDto)
        updateState(to: user)
        
    }
    
    func cache(user: UserDto) {
        userRepository.cache(user: user)
    }
    
    private func updateState(to user: User) {
        DispatchQueue.main.async {
            appState.user.current = user
        }
    }
}

class FakeUserService: UserServiceProtocol {
    var userLocalId: String?
    var token: String?
    var fbName: String?
    func fetchUser() {}
    func cache(user: UserDto) {}
}
