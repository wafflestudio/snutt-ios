//
//  ReviewScene.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/25.
//

import SwiftUI

struct ReviewScene: View {
    @ObservedObject var viewModel: ReviewViewModel

    var state: ConnectionState {
        viewModel.state
    }

    var body: some View {
        if case .success = state {
            ReviewWebView(request: URLRequest(url: SNUTTWebView.review.url), viewModel: viewModel)
                .navigationBarHidden(true)
        } else {
            WebErrorView(viewModel: viewModel)
                .navigationTitle("강의평")
                .navigationBarTitleDisplayMode(.inline)
        }
        let _ = debugChanges()
    }
}
