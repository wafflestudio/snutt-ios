//
//  ToolbarButton.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI
import UIKit

struct ToolbarButton: View {
    let image: UIImage
    var contentInsets: EdgeInsets = .all(0)
    let action: () -> Void

    var body: some View {
        Button {
            action()
        } label: {
            Image(uiImage: image)
                .renderingMode(.template)
                .foregroundStyle(Color(.label))
                .padding(contentInsets)
        }
        .frame(width: 40, height: 40)
        .contentShape(Rectangle())
        .buttonStyle(
            .animatable(scale: 0.9, backgroundHighlightColor: Color(.label).opacity(0.1), hapticFeedback: true)
        )
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
