//
//  ReviewScene.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/25.
//

import Combine
import SwiftUI

struct ReviewScene: View {
    @ObservedObject var viewModel: ViewModel
    @Binding var detailId: String?

    private var isMainWebView: Bool

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    init(viewModel: ViewModel, isMainWebView: Bool, detailId: Binding<String?> = .constant(nil)) {
        self.viewModel = viewModel
        _detailId = detailId
        self.isMainWebView = isMainWebView

        eventSignal?.send(.colorSchemeChange(to: viewModel.preferredColorScheme))
    }

    private var eventSignal: PassthroughSubject<WebViewEventType, Never>? {
        viewModel.getPreloadedWebView(isMain: isMainWebView).eventSignal
    }

    private var reviewUrl: URL {
        if let detailId = detailId {
            return WebViewType.reviewDetail(id: detailId).url
        } else {
            return WebViewType.review.url
        }
    }

    var body: some View {
        ZStack {
            ReviewWebView(preloadedWebView: viewModel.getPreloadedWebView(isMain: isMainWebView))
                .navigationBarHidden(true)
                .edgesIgnoringSafeArea(.bottom)
                .background(STColor.systemBackground)

            if viewModel.connectionState == .error {
                WebErrorView(refresh: {
                    eventSignal?.send(.reload(url: reviewUrl))
                })
                .navigationTitle("강의평")
                .navigationBarTitleDisplayMode(.inline)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(STColor.systemBackground)
            }
        }
        .onAppear {
            eventSignal?.send(.colorSchemeChange(to: viewModel.preferredColorScheme))
        }
        /// Respond to changes of preferred color scheme in `SettingScene`.
        .onChange(of: viewModel.preferredColorScheme) { newValue in
            eventSignal?.send(.colorSchemeChange(to: newValue))
        }
        /// Respond to changes of system color scheme.
        .onChange(of: colorScheme) { newValue in
            eventSignal?.send(.colorSchemeChange(to: newValue))
        }
        .onReceive(eventSignal ?? .init()) { signal in
            switch signal {
            case .success:
                viewModel.connectionState = .success
            case .error:
                viewModel.connectionState = .error
            case .close:
                dismiss()
            default:
                return
            }
        }

        let _ = debugChanges()
    }
}

extension ReviewScene {
    class ViewModel: BaseViewModel, ObservableObject {
        @Published var accessToken: String = ""
        @Published var connectionState: WebViewConnectionState = .success
        @Published var preferredColorScheme = UITraitCollection.current.userInterfaceStyle.toColorScheme()

        private var bag = Set<AnyCancellable>()

        override init(container: DIContainer) {
            super.init(container: container)
            appState.user.$accessToken.sink { newValue in
                if let token = newValue, !token.isEmpty {
                    self.connectionState = .success
                    self.accessToken = token
                } else {
                    self.connectionState = .error
                    self.accessToken = ""
                }
            }.store(in: &bag)

            appState.system.$preferredColorScheme.sink { newValue in
                if let newValue {
                    self.preferredColorScheme = newValue
                } else {
                    self.preferredColorScheme = UITraitCollection.current.userInterfaceStyle.toColorScheme()
                }
            }.store(in: &bag)
        }

        func getPreloadedWebView(isMain: Bool) -> WebViewPreloadManager {
            let webviewManager = isMain ? appState.review.preloadedMain : appState.review.preloadedDetail

            // make sure the webview has all required cookies
            if let accessToken = appState.user.accessToken {
                webviewManager.webView?.setCookies(cookies: NetworkConfiguration.getCookiesFrom(accessToken: accessToken))
            }

            return webviewManager
        }
    }
}
