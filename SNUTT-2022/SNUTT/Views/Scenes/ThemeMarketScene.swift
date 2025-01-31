//
//  ThemeMarketScene.swift
//  SNUTT
//
//  Created by 이채민 on 1/30/25.
//

import Combine
import SwiftUI

struct ThemeMarketScene: View {
    @ObservedObject var viewModel: ViewModel

    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        eventSignal?.send(.colorSchemeChange(to: viewModel.preferredColorScheme))
    }

    private var eventSignal: PassthroughSubject<ThemeMarketViewEventType, Never>? {
        viewModel.getPreloadedWebView().eventSignal
    }

    private var themeMarketUrl: URL = WebViewType.themeMarket.url

    var body: some View {
        ZStack {
            ThemeMarketView(preloadedWebView: viewModel.getPreloadedWebView())
                .navigationTitle("테마 마켓")
                .navigationBarTitleDisplayMode(.inline)
                .background(STColor.systemBackground)

            if viewModel.connectionState == .error {
                WebErrorView(refresh: {
                    eventSignal?.send(.reload(url: themeMarketUrl))
                })
                .navigationTitle("테마 마켓")
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

extension ThemeMarketScene {
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

        func getPreloadedWebView() -> ThemeMarketViewPreloadManager {
            let webviewManager = appState.theme.preloaded

            // make sure the webview has all required cookies
            if let accessToken = appState.user.accessToken {
                webviewManager.webView?.setCookies(cookies: NetworkConfiguration.getCookiesFrom(accessToken: accessToken, type: "theme"))
            }

            return webviewManager
        }
    }
}
