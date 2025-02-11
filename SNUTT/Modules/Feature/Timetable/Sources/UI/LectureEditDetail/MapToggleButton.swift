//
//  MapToggleButton.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

struct MapToggleButton: View {
    @Binding var isOpen: Bool
    let action: () -> Void

    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        Button {
            action()
        } label: {
            HStack(spacing: 0) {
                if !isOpen {
                    TimetableAsset.mapOpen.swiftUIImage
                    Spacer().frame(width: 8)
                }
                Text(isOpen ? "지도 닫기" : "지도에서 보기")
                    .font(.system(size: 14))
                    .foregroundStyle(colorScheme == .dark
                        ? SharedUIComponentsAsset.gray30.swiftUIColor
                        : SharedUIComponentsAsset.darkGray.swiftUIColor)
                Spacer().frame(width: 4)
                TimetableAsset.chevronDown.swiftUIImage
                    .rotationEffect(.init(degrees: isOpen ? 180.0 : .zero))
            }
        }
        .padding(.top, 8)
    }
}
