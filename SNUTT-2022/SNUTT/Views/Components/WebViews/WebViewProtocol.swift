//
//  WebViewProtocol.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/10/01.
//

import Combine
import SwiftUI
import WebKit

protocol WebView: UIViewRepresentable {
    var url: URL { get set }
    var urlRequest: URLRequest { get }
    func makeUIView(context: Context) -> WKWebView
    func updateUIView(_ uiView: WKWebView, context: Context)
}

extension WebView {
    var urlRequest: URLRequest {
        URLRequest(url: url)
    }
}

extension WKWebView {
    convenience init(cookies: [HTTPCookie]) {
        let dataStore = WKWebsiteDataStore.nonPersistent()
        let configuration = WKWebViewConfiguration()
        for cookie in cookies {
            dataStore.httpCookieStore.setCookie(cookie)
        }
        configuration.websiteDataStore = dataStore
        self.init(frame: .zero, configuration: configuration)
    }

    func setCookie(name: String, value: String) {
        guard let cookie = NetworkConfiguration.getCookie(name: name, value: value) else { return }
        configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
    }
}
