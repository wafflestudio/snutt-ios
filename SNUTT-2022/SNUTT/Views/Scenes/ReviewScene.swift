//
//  ReviewScene.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/25.
//

import SwiftUI

struct ReviewScene: View {
    @ObservedObject var viewModel: ReviewViewModel

    var body: some View {
        switch viewModel.state {
        case .success:
            ReviewWebView(request: viewModel.request, viewModel: viewModel)
                .navigationBarHidden(true)
                .ignoresSafeArea(.keyboard)
        case .error:
            WebErrorView(viewModel: viewModel)
                .navigationTitle("강의평")
                .navigationBarTitleDisplayMode(.inline)
        }
        let _ = debugChanges()
    }
}
