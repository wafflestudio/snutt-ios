//
//  ReviewViewModel.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/25.
//

import Combine
import Foundation

class ReviewViewModel: BaseViewModel, ObservableObject {
    @Published private var _state: WebViewState.Connection = .success

    private var reviewDetailId: String

    init(container: DIContainer, reviewDetailId: String) {
        self.reviewDetailId = reviewDetailId
        super.init(container: container)

        appState.webView.$connection.assign(to: &$_state)
    }

    var connectionState: WebViewState.Connection {
        get { appState.webView.connection }
        set { services.reviewService.changeConnectionState(to: newValue) }
    }

    var request: URLRequest {
        if reviewDetailId.isEmpty {
            return URLRequest(url: WebViewType.review.url)
        } else {
            return URLRequest(url: WebViewType.reviewDetail(id: reviewDetailId).url)
        }
    }

    var apiKey: String? {
        appState.user.apiKey
    }

    var token: String? {
        appState.user.accessToken
    }
}
