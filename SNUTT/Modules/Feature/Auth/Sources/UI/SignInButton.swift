//
//  SignInButton.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

struct SignInButton: View {
    let label: String
    var image: UIImage? = nil
    var action: (() -> Void)? = nil

    public var body: some View {
        AnimatableButton(
            animationOptions: .identity.scale(0.98).backgroundColor(touchDown: .black.opacity(0.1)).impact(),
            layoutOptions: [.expandHorizontally, .respectIntrinsicHeight]
        ) {
            action?()
        } configuration: { _ in
            var configuration = UIButton.Configuration.plain()
            configuration.title = label
            configuration.baseForegroundColor = .label
            configuration.image = image
            configuration.cornerStyle = .large
            configuration.background.strokeColor = .tertiaryLabel
            return configuration
        }
    }
}

#Preview {
    VStack {
        SignInButton(label: "로그인")
        SignInButton(label: "가입하기")
    }
}
