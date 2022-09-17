//
//  ReviewService.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/26.
//

import Foundation

protocol ReviewServiceProtocol {
    func changeConnectionState(to state: WebViewState.Connection)
    func setDetailId(_ id: String)
    func shouldReloadWebView(_ reload: Bool)

    // will be moved to GlobalUIService.swift
    func setSelectedTab(_ tab: TabType)
}

struct ReviewService: ReviewServiceProtocol {
    var appState: AppState

    init(appState: AppState) {
        self.appState = appState
    }

    func changeConnectionState(to state: WebViewState.Connection) {
        appState.webView.connection = state
    }

    func setDetailId(_ id: String) {
        appState.webView.detailLectureId = id
        setSelectedTab(.review)
        shouldReloadWebView(true)
    }

    func shouldReloadWebView(_ reload: Bool) {
        if reload {
            changeConnectionState(to: .success)
        }
        appState.webView.reloadWebView = reload
    }

    // will be moved to GlobalUIService.swift
    func setSelectedTab(_ tab: TabType) {
        DispatchQueue.main.async {
            appState.tab.selected = tab
        }
    }
}

class FakeReviewService: ReviewServiceProtocol {
    func changeConnectionState(to _: WebViewState.Connection) {}
    func setDetailId(_: String) {}
    func shouldReloadWebView(_: Bool) {}

    func setSelectedTab(_: TabType) {}
}
