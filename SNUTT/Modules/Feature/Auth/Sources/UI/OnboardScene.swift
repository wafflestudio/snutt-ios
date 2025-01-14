//
//  OnboardScene.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import MemberwiseInit
import SharedUIComponents
import SwiftUI

public struct OnboardScene: View {
    @State private var viewModel = OnboardViewModel()

    public init() {}

    public var body: some View {
        NavigationStack(path: $viewModel.paths) {
            VStack(spacing: 15) {
                Spacer()
                Logo(orientation: .vertical)
                Spacer()
                VStack {
                    SignInButton(label: AuthStrings.onboardLoginButton) {
                        viewModel.paths.append(.loginLocal)
                    }
                    SignInButton(label: AuthStrings.onboardRegisterButton) {
                        viewModel.paths.append(.registerLocal)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            .navigationDestination(for: OnboardDetailSceneTypes.self) { sceneType in
                switch sceneType {
                case .loginLocal:
                    LoginScene(viewModel: viewModel)
                case .registerLocal:
                    Text("registerLocal")
                case .findLocalID:
                    Text("find")
                case .resetLocalPassword:
                    Text("reset")
                }
            }
        }
    }
}

#Preview {
    OnboardScene()
}
