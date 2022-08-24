//
//  ReviewViewModel.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/25.
//

import Combine
import Foundation
import SwiftUI

class ReviewViewModel: ObservableObject {
    var container: DIContainer

    @Published var state: ConnectionState = .success
    @Published var reload: Bool = false

    init(container: DIContainer) {
        self.container = container

        system.$shouldReloadWebView
            .assign(to: &$reload)

        system.$connectionState
            .assign(to: &$state)
    }

    func fail() {
        system.connectionState = .error
    }

    func success() {
        system.connectionState = .success
    }

    func shouldReload() {
        success()
        system.shouldReloadWebView = true
    }

    func reloadDone() {
        system.shouldReloadWebView = false
    }

    var apiKey: String? {
        appState.user.apiKey
    }

    var token: String? {
        appState.user.token
    }

    var snuevWebUrl: String? {
        appState.setting.snuevWebUrl
    }

    private var appState: AppState {
        container.appState
    }

    private var system: System {
        appState.system
    }
}
