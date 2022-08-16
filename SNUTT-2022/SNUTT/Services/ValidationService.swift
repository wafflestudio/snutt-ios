//
//  ValidationService.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/16.
//

import Foundation

protocol ValidationServiceProtocol {
    func isValid(id: String) -> Bool
    func isValid(password: String) -> Bool
    func isValid(email: String) -> Bool
    func isValid(id: String, password: String, check: String) -> Bool
    func isValid(password: String, check: String) -> Bool
}

struct ValidationService: ValidationServiceProtocol {
    let appState: AppState
    let webRepositories: AppEnvironment.WebRepositories
    
    var userServiceRepository: UserRepositoryProtocol {
        webRepositories.userRepository
    }

    init(appState: AppState, webRepositories: AppEnvironment.WebRepositories) {
        self.appState = appState
        self.webRepositories = webRepositories
    }
    
    func isValid(id: String) -> Bool {
        guard let _ = id.range(of: "^[a-z0-9]{4,32}$", options: [.regularExpression, .caseInsensitive]) else {
            return false
        }
        return true
    }
    
    func isValid(password: String) -> Bool {
        guard let _ = password.range(of: "^(?=.*\\d)(?=.*[a-z])\\S{6,20}$", options: [.regularExpression, .caseInsensitive]) else {
            return false
        }
        return true
    }
    
    func isValid(email: String) -> Bool {
        guard let _ = email.range(of: "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}", options: [.regularExpression, .caseInsensitive]) else {
            return false
        }
        return true
    }
    
    func isValid(id: String, password: String, check: String) -> Bool {
        return true
    }
    
    func isValid(password: String, check: String) -> Bool {
        return password == check
    }
}

class FakeValidationService: ValidationServiceProtocol {
    func isValid(id: String) -> Bool { return true }
    func isValid(password: String) -> Bool { return true }
    func isValid(email: String) -> Bool { return true }
    func isValid(id: String, password: String, check: String) -> Bool { return true }
    func isValid(password: String, check: String) -> Bool { return true }
}
