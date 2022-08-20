//
//  WebView.swift
//  SNUTT
//
//  Created by 최유림 on 2022/08/21.
//

import SwiftUI
import WebKit

// TODO: 강의평 웹뷰를 위한 non-single webview
protocol WebView: UIViewRepresentable {
    var request: URLRequest { get set }
    func makeUIView(context: Context) -> WKWebView
    func updateUIView(_ uiView: WKWebView, context: Context)
}

struct SingleWebView: WebView {
    var request: URLRequest
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(request)
    }
}

// TODO: move to appropriate directory
enum SNUTTWebView {
    case developerInfo
    case termsOfService
    case privacyPolicy
    // TODO: add Review View
    
    private var baseURL: String {
        "https://snutt-api-dev.wafflestudio.com"
    }
    
    private var path: String {
        switch(self) {
        case .developerInfo:
            return "/member"
        case .termsOfService:
            return "/terms_of_service"
        case .privacyPolicy:
            return "/privacy_policy"
        }
    }
    
    var url: URL {
        URL(string: baseURL + path)!
    }
}
