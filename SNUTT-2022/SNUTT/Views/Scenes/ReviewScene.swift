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
            eventSignal?.send(.colorSchemeChange(to: colorScheme))
        }
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
        }

        func getPreloadedWebView(isMain: Bool) -> WebViewPreloadManager {
            if isMain {
                return appState.review.preloadedMain
            } else {
                return appState.review.preloadedDetail
            }
        }
    }
}
