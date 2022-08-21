//
//  UserService.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/09.
//

import Foundation

protocol UserServiceProtocol {
    func fetchUser() async throws
}

struct UserService: UserServiceProtocol {
    let appState: AppState
    let webRepositories: AppEnvironment.WebRepositories
    
    var localRepositories: AppEnvironment.LocalRepositories
    
    var userRepository: UserRepositoryProtocol {
        webRepositories.userRepository
    }
    
    var userDefaultsRepository: UserDefaultsRepositoryProtocol {
        localRepositories.userDefaultsRepository
    }

    func fetchUser() async throws {
        let userDto = try await userRepository.fetchUser()
        let user = User(from: userDto)
        userDefaultsRepository.set(String.self, key: .userLocalId, value: user.localId)
        userDefaultsRepository.set(String.self, key: .userFBName, value: user.fbName)
        updateState(to: user)
    }
    
    private func updateState(to user: User) {
        DispatchQueue.main.async {
            appState.user.current = user
        }
    }
}

class FakeUserService: UserServiceProtocol {
    func fetchUser() {}
}
