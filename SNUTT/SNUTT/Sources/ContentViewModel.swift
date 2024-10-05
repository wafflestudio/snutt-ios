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

class ContentViewModel: ObservableObject {
    private let authState: any AuthState
    @Published private(set) var isAuthenticated: Bool
    @Published var selectedTab: TabItem = .timetable

    init() {
        @Dependency(\.authState) var authState
        self.authState = authState
        isAuthenticated = authState.isAuthenticated
        authState.isAuthenticatedPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$isAuthenticated)
    }
}
