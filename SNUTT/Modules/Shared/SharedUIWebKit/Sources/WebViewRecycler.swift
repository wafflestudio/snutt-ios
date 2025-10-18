//
//  WebViewRecycler.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import DequeModule
import WebKit

/// Thread-safe singleton that manages a pool of pre-warmed WKWebView instances
/// to improve initial load performance.
@MainActor
public final class WebViewRecycler {
    public static let shared = WebViewRecycler()

    private var pool = Deque<RecyclableWebView>.init(minimumCapacity: 2)
    private let maxPoolSize = 5

    private init() {}

    /// Pre-warms the specified number of web view instances.
    /// - Parameter count: Number of web views to pre-warm
    public func prepare(count: Int = 2) {
        let targetCount = min(count, maxPoolSize)
        let needed = targetCount - pool.count

        guard needed > 0 else { return }
        for _ in 0..<needed {
            let webView = createPrewarmedWebView()
            pool.append(webView)
        }
    }

    /// Dequeues a recycled web view from the pool, or creates a new one if pool is empty.
    /// - Returns: A pre-warmed WKWebView instance ready for use
    func dequeue() -> RecyclableWebView {
        if let index = pool.firstIndex(where: { !$0.isInUse }) {
            let webView = pool.remove(at: index)
            webView.markAsInUse()
            return webView
        }
        return createPrewarmedWebView()
    }

    /// Enqueues a web view back into the pool after cleaning its state.
    /// - Parameter webView: The web view to recycle
    func enqueue(_ webView: RecyclableWebView) {
        guard webView.isInUse, pool.count < maxPoolSize else { return }
        webView.prepareForReuse()
        pool.append(webView)
    }

    private func createPrewarmedWebView() -> RecyclableWebView {
        let webView = RecyclableWebView(frame: .zero, configuration: WKWebViewConfiguration())
        UIView().addSubview(webView)  // to force the web view to load necessary resources
        webView.prewarm()
        webView.removeFromSuperview()
        return webView
    }
}

/// A recyclable WKWebView that can be reused from the pool.
final class RecyclableWebView: WKWebView {
    private(set) var isInUse = false

    override init(frame: CGRect, configuration: WKWebViewConfiguration) {
        super.init(frame: frame, configuration: configuration)
        isOpaque = false
        backgroundColor = .systemBackground
        scrollView.backgroundColor = .systemBackground
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    /// Pre-warms the web view by loading an empty HTML string.
    fileprivate func prewarm() {
        loadHTMLString("", baseURL: nil)
    }

    /// Marks the web view as currently in use.
    fileprivate func markAsInUse() {
        isInUse = true
    }

    /// Resets the web view to a clean state and marks it as available for reuse.
    fileprivate func prepareForReuse() {
        Task {
            await deleteAllCookies()
            isInUse = false
        }
        stopLoading()
        navigationDelegate = nil
        uiDelegate = nil
        scrollView.delegate = nil
        configuration.userContentController.removeAllScriptMessageHandlers()
        // Reset to blank page
        loadHTMLString("", baseURL: nil)
    }

    func setCookies(_ cookies: [HTTPCookie]) {
        cookies.forEach { cookie in
            configuration.websiteDataStore.httpCookieStore.setCookie(cookie)
        }
    }

    private func deleteAllCookies() async {
        let cookieStore = configuration.websiteDataStore.httpCookieStore
        for cookie in await cookieStore.allCookies() {
            await cookieStore.deleteCookie(cookie)
        }
    }
}
