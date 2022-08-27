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

    init(container: DIContainer) {
        self.container = container
    }

    var state: WebViewState.Connection {
        webViewState.connection
    }

    var reload: Bool {
        webViewState.shouldReloadWebView
    }

    func changeConnectionState(to state: WebViewState.Connection) {
        webViewService.changeConnectionState(to: state)
    }

    func shouldReloadWebView(_ reload: Bool) {
        webViewService.shouldReloadWebView(reload)
    }

    func getDetail(lectureId: String) {
        container.services.webViewService.getDetail(lectureId: lectureId)
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

    private var webViewService: WebViewServiceProtocol {
        container.services.webViewService
    }
}
