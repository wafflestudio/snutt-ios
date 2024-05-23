//
//  AuthState.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Dependencies
import Foundation
import Spyable
import Combine

@Spyable
public protocol AuthState: Sendable, ObservableObject, AnyObject {
    var isAuthenticated: Bool { get }
    var isAuthenticatedPublisher: AnyPublisher<Bool, Never> { get }
    func set(_ type: AuthStateType, value: String)
    func get(_ type: AuthStateType) -> String?
    func clear()
}

public enum AuthStateType: String, Sendable {
    case userID, accessToken
}

extension AuthStateSpy: @unchecked Sendable {}

public enum AuthStateKey: TestDependencyKey {
    public static let testValue: any AuthState = AuthStateSpy()
    public static let previewValue: any AuthState = {
        let spy = AuthStateSpy()
        let subject = CurrentValueSubject<Bool, Never>(false)
        spy.underlyingIsAuthenticated = false
        spy.setValueClosure = { [weak spy] _, _ in
            spy?.underlyingIsAuthenticated = true
            subject.value = true
        }
        spy.underlyingIsAuthenticatedPublisher = subject.eraseToAnyPublisher()
        return spy
    }()
}

extension DependencyValues {
    public var authState: any AuthState {
        get { self[AuthStateKey.self] }
        set { self[AuthStateKey.self] = newValue }
    }
}
