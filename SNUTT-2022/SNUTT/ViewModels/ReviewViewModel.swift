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

    @Published var state: WebViewState.Connection = .success
    @Published var reload: Bool = false

    init(container: DIContainer) {
        self.container = container

        webViewState.$shouldReloadWebView
            .assign(to: &$reload)

        webViewState.$connection
            .assign(to: &$state)
    }

    func changeConnectionState(to state: WebViewState.Connection) {
        webViewState.connection = state
    }

    func shouldReloadWebView(_ reload: Bool) {
        if reload {
            changeConnectionState(to: .success)
        }
        webViewState.shouldReloadWebView = reload
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

    private var webViewState: WebViewState {
        appState.webView
    }
}
