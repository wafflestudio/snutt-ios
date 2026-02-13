//
//  SettingsMenuButton.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

struct SettingsMenuButton: View {
    let title: String
    var onTap: (() -> Void)?
    var leadingImage: Image?
    var detail: String?
    var detailImage: Image?
    var destructive: Bool = false

    var body: some View {
        Button {
            onTap?()
        } label: {
            HStack(spacing: 0) {
                if let leadingImage {
                    leadingImage
                    Spacer().frame(width: 4)
                }
                Text(title)
                    .font(.system(size: 16))
                    .foregroundStyle(
                        destructive
                            ? SharedUIComponentsAsset.red.swiftUIColor
                            : Color.primary
                    )
                Spacer()
                Group {
                    if let detailImage {
                        detailImage
                    }
                    if let detail {
                        Text(detail)
                            .font(.system(size: 16))
                    }
                }
                .foregroundStyle(.gray)
            }
        }
        .contentShape(.rect)
        .disabled(onTap == nil)
    }
}
