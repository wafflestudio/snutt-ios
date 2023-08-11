//
//  FriendsScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2023/07/15.
//

import SwiftUI
import ReactNativeKit

struct FriendsScene: View {
    var viewModel: FriendsViewModel
    @State private var bundleUrl: URL?

    var body: some View {
        let _ = debugChanges()
#if FEATURE_RN_FRIENDS
        Group {
            if let token = viewModel.accessToken, let bundleUrl {
                RNFriendsView(accessToken: token, bundleUrl: bundleUrl)
            } else {
                ProgressView()
            }
        }
        .task {
//            bundleUrl = URL(string: "http://localhost:8081/index.bundle?platform=ios")!
            bundleUrl = await viewModel.fetchReactNativeBundleUrl()
        }
#else
        WIPFriendsView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(STColor.systemBackground)
#endif
    }
}

#if FEATURE_RN_FRIENDS
struct RNFriendsView: UIViewRepresentable {
    let accessToken: String
    let bundleUrl: URL
    let moduleName = "friends"

    func makeUIView(context _: Context) -> UIView {
        var props = AppMetadata.asDictionary()
        props["x-access-token"] = accessToken
        return makeReactView(bundleURL: bundleUrl, moduleName: moduleName, initialProperties: props)
    }

    func updateUIView(_: UIView, context _: Context) { }
}
#endif
