//
//  ReviewScene.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/25.
//

import SwiftUI
import Combine

struct ReviewScene: View {
    @ObservedObject var viewModel: ViewModel
    @Binding var detailId: String
    var reloadSignal: PassthroughSubject<Void, Never>
    
    init(viewModel: ViewModel, detailId: Binding<String> = .constant(""), reloadSignal: PassthroughSubject<Void, Never>? = nil) {
        self.viewModel = viewModel
        self._detailId = detailId
        self.reloadSignal = reloadSignal ?? .init()
    }
    
    private var reviewUrl: URL {
        if !detailId.isEmpty {
            return WebViewType.reviewDetail(id: detailId).url
        } else {
            return WebViewType.review.url
        }
    }
    
    var body: some View {
        switch viewModel.connectionState {
        case .success:
            ReviewWebView(url: reviewUrl, accessToken: viewModel.accessToken, connectionState: $viewModel.connectionState, reloadSignal: reloadSignal)
                .navigationBarHidden(true)
                .edgesIgnoringSafeArea(.bottom)
        case .error:
            WebErrorView(refresh: {
                reloadSignal.send()
            })
            .navigationTitle("강의평")
            .navigationBarTitleDisplayMode(.inline)
        }
        let _ = debugChanges()
    }
}

extension ReviewScene {
    class ViewModel: BaseViewModel, ObservableObject {
        @Published var accessToken: String = ""
        @State var connectionState: WebViewConnectionState = .success
        
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
