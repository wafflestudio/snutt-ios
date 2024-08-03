//
//  FriendsScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2023/07/15.
//

import ReactNativeKit
import SwiftUI

struct FriendsScene: View {
    @StateObject var viewModel: FriendsViewModel
    @State private var bundleUrl: URL?

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        let _ = debugChanges()
        Group {
            if let token = viewModel.accessToken, let bundleUrl {
                RNFriendsView(accessToken: token, bundleUrl: bundleUrl, colorScheme: colorScheme)
                    .id(colorScheme)
                    .navigationBarHidden(true)
                    .background(STColor.systemBackground)
            } else {
                ProgressView()
            }
        }
        .alert(isPresented: $viewModel.isErrorAlertPresented, error: viewModel.friendRequestError, actions: { _ in
            Button("확인", role: .none, action: {})
        }, message: { error in Text(error.recoverySuggestion ?? "")})
        .task {
            // bundleUrl = URL(string: "http://localhost:8081/index.bundle?platform=ios")!
            bundleUrl = await viewModel.fetchReactNativeBundleUrl()
        }
        .task {
            await viewModel.bindEventEmitter()
        }
    }
}

struct RNFriendsView: UIViewRepresentable {
    let accessToken: String
    let bundleUrl: URL
    let colorScheme: ColorScheme
    private let moduleName = "friends"

    private enum RNFeature: String, CaseIterable {
        case ASYNC_STORAGE
    }

    private var initialProps: [String: Any] {
        var props: [String: Any] = AppMetadata.asDictionary()
        props["x-access-token"] = accessToken
        props["theme"] = colorScheme.description
        props["allowFontScaling"] = false
        props["feature"] = RNFeature.allCases.map { $0.rawValue }
        return props
    }

    func makeUIView(context _: Context) -> UIView {
        return makeReactView(bundleURL: bundleUrl,
                             moduleName: moduleName,
                             initialProperties: initialProps,
                             backgroundColor: UIColor(STColor.systemBackground))
    }

    func updateUIView(_: UIView, context _: Context) {}
}
