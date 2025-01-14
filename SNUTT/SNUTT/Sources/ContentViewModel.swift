//
//  ContentViewModel.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import AuthInterface
import Combine
import Dependencies
import Foundation

@Observable
@MainActor
class ContentViewModel {
    private let authState: any AuthState
    private(set) var isAuthenticated: Bool
    var selectedTab: TabItem = .timetable
    private var cancellables: Set<AnyCancellable> = []

    init() {
        authState = Dependency(\.authState).wrappedValue
        isAuthenticated = authState.isAuthenticated
        authState.isAuthenticatedPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.isAuthenticated = $0
            }
            .store(in: &cancellables)
    }
}
