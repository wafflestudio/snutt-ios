//
//  SyllabusWebView.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Combine
import QuickLook
import SnapKit
import SwiftUI
import UIKit
import UIKitUtility
import WebKit

struct SyllabusWebView: UIViewControllerRepresentable {
    let lectureTitle: String
    let url: URL

    func makeUIViewController(context _: UIViewControllerRepresentableContext<Self>) -> UIViewController {
        let webViewController = SyllabusWebViewController(entryURL: url)
        let navigationController = UINavigationController(rootViewController: webViewController)
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        webViewController.navigationItem.rightBarButtonItem = .init(
            systemItem: .close,
            primaryAction: .init(handler: { [weak navigationController] _ in
                navigationController?.dismiss(animated: true)
            })
        )
        webViewController.title = lectureTitle
        return navigationController
    }

    func updateUIViewController(_: UIViewController, context _: UIViewControllerRepresentableContext<Self>) {}
}

final class SyllabusWebViewController: UIViewController {
    private enum Constants {
        static let referer = "https://sugang.snu.ac.kr/sugang/cc/cc100InterfaceExcel.action"
    }

    private enum Design {
        static let bottomViewHeight = 50.0
    }

    private let entryURL: URL
    private lazy var webView: WKWebView = {
        let config = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInset = .init(top: 0, left: 0, bottom: Design.bottomViewHeight, right: 0)
        webView.navigationDelegate = self
        return webView
    }()

    private var cancellables = Set<AnyCancellable>()
    private let bottomView = WebBottomNavigationView()
    private var downloadLocalURLs = [WKDownload: URL]()

    init(entryURL: URL) {
        self.entryURL = entryURL
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable) required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindBottomButtons()
        initialLoad()
    }

    private func setupView() {
        view.addSubview(webView)
        view.addSubview(bottomView)
        webView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        bottomView.snp.makeConstraints { make in
            make.leading.trailing.bottom.equalToSuperview()
            make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-Design.bottomViewHeight)
        }
    }

    private func initialLoad() {
        var request = URLRequest(url: entryURL)
        request.setValue(Constants.referer, forHTTPHeaderField: "Referer")
        webView.load(request)
    }

    private func bindBottomButtons() {
        bottomView.buttonDidPressPublisher
            .sink { [weak self] button in
                guard let self else { return }
                switch button {
                case .back:
                    webView.goBack()
                case .forward:
                    webView.goForward()
                case .reload:
                    webView.reload()
                case .safari:
                    UIApplication.shared.open(entryURL)
                }
            }
            .store(in: &cancellables)
        webView.publisher(for: \.canGoBack)
            .sink { [weak self] canGoBack in
                guard let self else { return }
                bottomView.button(for: .back).isEnabled = canGoBack
            }
            .store(in: &cancellables)
        webView.publisher(for: \.canGoForward)
            .sink { [weak self] canGoForward in
                guard let self else { return }
                bottomView.button(for: .forward).isEnabled = canGoForward
            }
            .store(in: &cancellables)
        webView.publisher(for: \.estimatedProgress)
            .sink { [weak self] progress in
                guard let self else { return }
                bottomView.progressView.setProgress(progress)
            }
            .store(in: &cancellables)
    }
}

extension SyllabusWebViewController: WKNavigationDelegate {
    func webView(_: WKWebView, decidePolicyFor _: WKNavigationAction) async -> WKNavigationActionPolicy {
        .allow
    }

    func webView(
        _: WKWebView,
        decidePolicyFor navigationResponse: WKNavigationResponse
    ) async -> WKNavigationResponsePolicy {
        guard let mimeType = navigationResponse.response.mimeType else { return .cancel }
        return mimeType == "text/html" ? .allow : .download
    }

    func webView(_: WKWebView, navigationResponse _: WKNavigationResponse, didBecome download: WKDownload) {
        download.delegate = self
    }
}

extension SyllabusWebViewController: WKDownloadDelegate {
    func download(
        _ download: WKDownload,
        decideDestinationUsing _: URLResponse,
        suggestedFilename: String
    ) async -> URL? {
        let percentDecoded = suggestedFilename.removingPercentEncoding ?? suggestedFilename
        let fileManager = FileManager.default
        let url = fileManager.temporaryDirectory.appendingPathComponent(percentDecoded)
        try? fileManager.removeItem(at: url)
        downloadLocalURLs[download] = url
        return url
    }

    func downloadDidFinish(_ download: WKDownload) {
        guard let localURL = downloadLocalURLs.removeValue(forKey: download) else { return }
        let previewController = SyllabusFilePreviewController(item: localURL as any QLPreviewItem)
        present(previewController, animated: true)
    }
}

#Preview {
    SyllabusWebView(
        lectureTitle: "수강스누",
        url: URL(
            string:
                "https://sugang.snu.ac.kr/sugang/cc/cc103.action?openSchyy=2024&openShtmFg=U000200002&openDetaShtmFg=U000300002&sbjtCd=M3500.002000&ltNo=001&sbjtSubhCd=000"
        )!

    )
    .ignoresSafeArea(edges: .bottom)
}

#Preview {
    SyllabusWebView(lectureTitle: "네이버", url: URL(string: "https://naver.com")!)
        .ignoresSafeArea(edges: .bottom)
}
