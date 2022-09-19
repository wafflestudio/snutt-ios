//
//  ReviewViewModel.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/25.
//

import Combine
import Foundation

class ReviewViewModel: BaseViewModel, ObservableObject {
    @Published private var _reload: Bool = false
    @Published private var _state: WebViewState.Connection = .success
    @Published private var _reviewDetailId: String = ""
    
    private var bag = Set<AnyCancellable>()
    
    override init(container: DIContainer) {
        super.init(container: container)
        
        appState.webView.$reloadWebView.assign(to: &$_reload)
        appState.webView.$connection.assign(to: &$_state)
        appState.webView.$detailLectureId.assign(to: &$_reviewDetailId)
    }

    var connectionState: WebViewState.Connection {
        get { appState.webView.connection }
        set { services.reviewService.changeConnectionState(to: newValue) }
    }

    var reload: Bool {
        get { appState.webView.reloadWebView }
        set { services.reviewService.shouldReloadWebView(newValue) }
    }
    
    var detailId: String {
        _reviewDetailId
    }

    var request: URLRequest {
        if detailId.isEmpty {
            return URLRequest(url: SNUTTWebView.review.url)
        } else {
            return URLRequest(url: SNUTTWebView.reviewDetail(id: detailId).url)
        }
    }

    var apiKey: String? {
        appState.user.apiKey
    }

    var token: String? {
        appState.user.token
    }
}
