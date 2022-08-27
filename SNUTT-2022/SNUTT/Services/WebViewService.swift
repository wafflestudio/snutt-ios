//
//  WebViewService.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/26.
//

import Foundation

protocol WebViewServiceProtocol {
    func getDetail(lectureId: String)
    func changeConnectionState(to state: WebViewState.Connection)
    func shouldReloadWebView(_ reload: Bool)
}

struct WebViewService: WebViewServiceProtocol {
    var appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }

    func changeConnectionState(to state: WebViewState.Connection) {
        appState.webView.connection = state
    }

    func shouldReloadWebView(_ reload: Bool) {
        if reload {
            changeConnectionState(to: .success)
        }
        appState.webView.shouldReloadWebView = reload
    }

    func getDetail(lectureId: String) {
        appState.webView.detailLectureId = lectureId
    }
}

class FakeWebViewService: WebViewServiceProtocol {
    func getDetail(lectureId _: String) {}
    func changeConnectionState(to _: WebViewState.Connection) {}
    func shouldReloadWebView(_: Bool) {}
}
