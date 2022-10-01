//
//  ReviewViewModel.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/25.
//

import Combine
import Foundation
import SwiftUI

class ReviewViewModel: BaseViewModel, ObservableObject {
    override init(container: DIContainer) {
        super.init(container: container)
    }

    var state: WebViewState.Connection {
        webViewState.connection
    }

    var reload: Bool {
        webViewState.reloadWebView
    }

    var detailId: String {
        webViewState.detailLectureId
    }

    var request: URLRequest {
        if detailId.isEmpty {
            return URLRequest(url: SNUTTWebView.review.url)
        } else {
            return URLRequest(url: SNUTTWebView.reviewDetail(id: detailId).url)
        }
    }

    func changeConnectionState(to state: WebViewState.Connection) {
        reviewService.changeConnectionState(to: state)
    }

    func shouldReloadWebView(_ reload: Bool) {
        reviewService.shouldReloadWebView(reload)
    }

    var apiKey: String? {
        appState.user.apiKey
    }

    var token: String? {
        appState.user.accessToken
    }

    private var webViewState: WebViewState {
        appState.webView
    }

    private var reviewService: ReviewServiceProtocol {
        container.services.reviewService
    }
}
