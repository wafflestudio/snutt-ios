//
//  FriendsScene.swift
//  SNUTT
//
//  Created by 박신홍 on 2023/07/15.
//

#if FEATURE_RN_FRIENDS
import SwiftUI
import ReactNativeKit

struct FriendsScene: View {
    var viewModel: FriendsViewModel

    var body: some View {
        if let token = viewModel.accessToken {
            RNFriendsView(accessToken: token)
        }
    }
}


struct RNFriendsView: UIViewRepresentable {

    let accessToken: String

    private enum Config {
        case localhost
        case remote

        static let moduleName = "friends"

        var url: URL {
            switch self {
            case .localhost:
                return URL(string: "http://localhost:8081/index.bundle?platform=ios")!
            case .remote:
                return URL(string: "https://snutt-rn-assets.s3.ap-northeast-2.amazonaws.com/ios.jsbundle")!
            }
        }
    }

    func makeUIView(context: Context) -> UIView {
        let config = Config.remote
        var props = AppMetadata.asDictionary()
        props["x-access-token"] = accessToken
        let myView = makeReactView(bundleURL: config.url, moduleName: Config.moduleName, initialProperties: props)
        return myView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
    }
}

#endif


