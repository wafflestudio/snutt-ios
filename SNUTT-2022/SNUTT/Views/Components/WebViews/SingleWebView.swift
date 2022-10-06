//
//  SingleWebView.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/10/01.
//

import Foundation
import WebKit

struct SingleWebView: WebView {
    var url: URL

    var urlRequest: URLRequest {
        URLRequest(url: url)
    }

    func makeUIView(context _: Context) -> WKWebView {
        let webview = WKWebView()
        webview.load(urlRequest)
        return webview
    }

    func updateUIView(_: WKWebView, context _: Context) {}
}
