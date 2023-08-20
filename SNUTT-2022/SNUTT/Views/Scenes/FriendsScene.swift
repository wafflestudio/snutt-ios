//
//  FriendsScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2023/07/15.
//

import ReactNativeKit
import SwiftUI

struct FriendsScene: View {
    #if FEATURE_RN_FRIENDS
        var viewModel: FriendsViewModel
    #endif
    @State private var bundleUrl: URL?

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        let _ = debugChanges()
        #if FEATURE_RN_FRIENDS
            Group {
                if let token = viewModel.accessToken, let bundleUrl {
                    RNFriendsView(accessToken: token, bundleUrl: bundleUrl, colorScheme: colorScheme)
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
        let colorScheme: ColorScheme
        private let moduleName = "friends"

        func makeUIView(context _: Context) -> UIView {
            var props = AppMetadata.asDictionary()
            props["x-access-token"] = accessToken
            props["theme"] = colorScheme.description
            return makeReactView(bundleURL: bundleUrl, moduleName: moduleName, initialProperties: props)
        }

        func updateUIView(_: UIView, context _: Context) {}
    }
#endif
