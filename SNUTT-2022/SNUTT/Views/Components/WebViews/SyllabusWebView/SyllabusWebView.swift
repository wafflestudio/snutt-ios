//
//  SyllabusWebView.swift
//  SNUTT
//
//  Created by 최유림 on 2022/10/11.
//

import Combine
import QuickLook
import SwiftUI
import UIKit
import WebKit

struct SyllabusWebView: UIViewControllerRepresentable {
    let lectureTitle: String
    @Binding var urlString: String

    func makeUIViewController(context _: UIViewControllerRepresentableContext<Self>) -> UIViewController {
        let webViewController = SyllabusWebViewController(entryURL: URL(string: urlString))
        let navigationController = UINavigationController(rootViewController: webViewController)
        var appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        navigationController.navigationBar.standardAppearance = appearance
        navigationController.navigationBar.scrollEdgeAppearance = appearance
        webViewController.navigationItem.rightBarButtonItem = .init(systemItem: .close, primaryAction: .init(handler: { [weak navigationController] _ in
            navigationController?.dismiss(animated: true)
        }))
        webViewController.title = lectureTitle
        return navigationController
    }

    func updateUIViewController(_: UIViewController, context _: UIViewControllerRepresentableContext<Self>) {}
}

final class SyllabusWebViewController: UIViewController {
    private enum Constants {
        static let homeURL = URL(string: "https://sugang.snu.ac.kr")!
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

    init(entryURL: URL?) {
        self.entryURL = entryURL ?? Constants.homeURL
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
        webView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.topAnchor),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -Design.bottomViewHeight),
        ])
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
                print("[progress] \(progress)")
            }
            .store(in: &cancellables)
    }
}

extension SyllabusWebViewController: WKNavigationDelegate {
    func webView(_: WKWebView, decidePolicyFor _: WKNavigationAction) async -> WKNavigationActionPolicy {
        return .allow
    }

    func webView(_: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse) async -> WKNavigationResponsePolicy {
        guard let mimeType = navigationResponse.response.mimeType else { return .cancel }
        if mimeType == "text/html" {
            return .allow
        }
        return .download
    }

    func webView(_: WKWebView, navigationResponse _: WKNavigationResponse, didBecome download: WKDownload) {
        download.delegate = self
    }
}

extension SyllabusWebViewController: WKDownloadDelegate {
    func download(_ download: WKDownload, decideDestinationUsing _: URLResponse, suggestedFilename: String) async -> URL? {
        let percentDecoded = suggestedFilename.removingPercentEncoding ?? suggestedFilename
        let fileManager = FileManager.default
        let url = fileManager.temporaryDirectory.appendingPathComponent(percentDecoded)
        try? fileManager.removeItem(at: url)
        downloadLocalURLs[download] = url
        return url
    }

    func downloadDidFinish(_ download: WKDownload) {
        guard let localURL = downloadLocalURLs.removeValue(forKey: download) else { return }
        let previewController = SyllabusFilePreviewController(item: localURL as QLPreviewItem)
        present(previewController, animated: true)
    }
}

extension UIControl {
    func addAction(
        for controlEvents: UIControl.Event = .touchUpInside,
        _ closure: @MainActor @escaping () -> Void
    ) {
        addAction(UIAction { (_: UIAction) in closure() }, for: controlEvents)
    }
}

@available(iOS 17.0, *)
#Preview {
    SyllabusWebView(lectureTitle: "수강스누", urlString: .constant("https://sugang.snu.ac.kr/sugang/cc/cc103.action?openSchyy=2024&openShtmFg=U000200002&openDetaShtmFg=U000300002&sbjtCd=M3500.002000&ltNo=001&sbjtSubhCd=000"))
        .ignoresSafeArea(edges: .bottom)
}

@available(iOS 17.0, *)
#Preview {
    SyllabusWebView(lectureTitle: "네이버", urlString: .constant("https://naver.com"))
        .ignoresSafeArea(edges: .bottom)
}
