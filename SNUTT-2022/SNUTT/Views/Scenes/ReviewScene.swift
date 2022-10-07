//
//  ReviewScene.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/25.
//

import Combine
import SwiftUI

enum WebViewEventType {
    case reload
    case colorSchemeChange(to: ColorScheme)
}


struct ReviewScene: View {
    @ObservedObject var viewModel: ViewModel
    @Binding var detailId: String
    
    var eventSignal: PassthroughSubject<WebViewEventType, Never>
    
    @Environment(\.colorScheme) var colorScheme

    init(viewModel: ViewModel, detailId: Binding<String> = .constant(""), webViewEventSignal: PassthroughSubject<WebViewEventType, Never>? = nil) {
        self.viewModel = viewModel
        _detailId = detailId
        self.eventSignal = webViewEventSignal ?? .init()
    }

    private var reviewUrl: URL {
        if !detailId.isEmpty {
            return WebViewType.reviewDetail(id: detailId).url
        } else {
            return WebViewType.review.url
        }
    }

    var body: some View {
        ZStack {
            ReviewWebView(url: reviewUrl, accessToken: viewModel.accessToken, connectionState: $viewModel.connectionState, eventSignal: eventSignal, initialColorScheme: colorScheme)
                .navigationBarHidden(true)
                .edgesIgnoringSafeArea(.all)

            if viewModel.connectionState == .error {
                WebErrorView(refresh: {
                    eventSignal.send(.reload)
                })
                .navigationTitle("강의평")
                .navigationBarTitleDisplayMode(.inline)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(uiColor: .systemBackground))
            }
        }
        .onChange(of: colorScheme) { newValue in
            eventSignal.send(.colorSchemeChange(to: newValue))
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
    }
}
