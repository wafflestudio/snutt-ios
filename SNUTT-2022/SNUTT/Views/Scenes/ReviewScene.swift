//
//  ReviewScene.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/06/25.
//

import SwiftUI

struct ReviewScene: View {
    // for test
    @ObservedObject var viewModel: ReviewViewModel

    var body: some View {
        ReviewWebView(request: URLRequest(url: SNUTTWebView.review.url), viewModel: viewModel)
            .navigationBarHidden(true)
        let _ = debugChanges()
    }
}

//struct ReviewScene_Previews: PreviewProvider {
//    static var previews: some View {
//        ReviewScene()
//    }
//}
