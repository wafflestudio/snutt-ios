//
//  ToolbarButton.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI
import UIKit

struct ToolbarButton: View {
    let image: UIImage
    var contentInsets: EdgeInsets = .all(0)
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
            configuration.contentInsets = .init(contentInsets)
            return configuration
        }
        .frame(width: 40, height: 40)
        .contentShape(Rectangle())
    }
}

extension EdgeInsets {
    static func all(_ value: CGFloat) -> EdgeInsets {
        EdgeInsets(top: value, leading: value, bottom: value, trailing: value)
    }

    init(horizontal: CGFloat, vertical: CGFloat) {
        self.init(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
    }
}

#Preview {
    HStack {
        ToolbarButton(image: TimetableAsset.chevronLeft.image) {}
        ToolbarButton(image: TimetableAsset.chevronRight.image) {}
        ToolbarButton(image: TimetableAsset.navAlarmOn.image) {}
        ToolbarButton(image: TimetableAsset.navBookmark.image, contentInsets: .all(5)) {}
    }
}
