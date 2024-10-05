//
//  ToolbarButton.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

struct ToolbarButton: View {
    let image: UIImage
    let action: () -> Void

    var body: some View {
        AnimatableButton(
            animationOptions: .identity.impact().scale(0.9).backgroundColor(touchDown: .black.opacity(0.1)),
            layoutOptions: []
        ) {
            action()
        } configuration: { _ in
            var configuration = UIButton.Configuration.plain()
            configuration.image = image.withTintColor(.label, renderingMode: .alwaysOriginal)
            configuration.contentInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0)
            return configuration
        }
        .frame(width: 40, height: 40)
        .contentShape(Rectangle())
    }
}

#Preview {
    ToolbarButton(image: TimetableAsset.navAlarmOn.image) {}
}
