//
//  ReviewService.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/26.
//

import Foundation

protocol ReviewServiceProtocol {
    func changeConnectionState(to state: WebViewState.Connection)
    func resetReviewId()
    func shouldReloadWebView(_ reload: Bool)
}

struct ReviewService: ReviewServiceProtocol {
    var appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }

    func changeConnectionState(to state: WebViewState.Connection) {
        appState.webView.connection = state
    }
    
    func resetReviewId() {
        DispatchQueue.main.async {
            appState.webView.detailLectureId = ""
            appState.webView.reloadWebView = true
        }
    }

    func shouldReloadWebView(_ reload: Bool) {
        if reload {
            changeConnectionState(to: .success)
        }
        appState.webView.reloadWebView = reload
    }
}

class FakeReviewService: ReviewServiceProtocol {
    func changeConnectionState(to _: WebViewState.Connection) {}
    func resetReviewId() {}
    func shouldReloadWebView(_: Bool) {}
}
