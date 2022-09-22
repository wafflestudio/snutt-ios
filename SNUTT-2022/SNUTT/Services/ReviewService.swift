//
//  ReviewService.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/26.
//

import Foundation

protocol ReviewServiceProtocol {
    func changeConnectionState(to state: WebViewState.Connection)
}

struct ReviewService: ReviewServiceProtocol {
    var appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }

    func changeConnectionState(to state: WebViewState.Connection) {
        DispatchQueue.main.async {
            appState.webView.connection = state
        }
    }
}

class FakeReviewService: ReviewServiceProtocol {
    func changeConnectionState(to _: WebViewState.Connection) {}
}
