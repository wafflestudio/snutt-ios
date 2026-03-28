//
//  FloatingButton.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI

public struct FloatingButton: View {
    let text: String
    let icon: Image
    let action: () -> Void

    public init(
        text: String,
        icon: Image = Image(systemName: "chevron.left"),
        action: @escaping () -> Void
    ) {
        self.text = text
        self.icon = icon
        self.action = action
    }

    public var body: some View {
        if #available(iOS 26, *) {
            Button(action: action) {
                HStack(spacing: 5) {
                    icon
                        .font(.system(size: 14))
                    Text(text)
                        .font(.system(size: 14, weight: .semibold))
                }
            }
            .foregroundColor(.white)
            .tint(SharedUIComponentsAsset.cyan.swiftUIColor)
            .buttonStyle(.glassProminent)
        } else {
            Button(action: action) {
                HStack(spacing: 5) {
                    icon
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                    Text(text)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(SharedUIComponentsAsset.cyan.swiftUIColor)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.2), radius: 3)
                .overlay {
                    Capsule()
                        .strokeBorder(Color(uiColor: .label).opacity(0.05), lineWidth: 1)
                }
            }
        }
    }
}

#Preview("기본") {
    ZStack {
        VStack {
            Spacer()
            FloatingButton(text: "해당 시간표로 이동", icon: Image(systemName: "chevron.left")) {}
                .padding(.bottom, 20)
        }
    }
}

#Preview("다크모드") {
    ZStack {
        Color.black
        VStack {
            Spacer()
            FloatingButton(text: "해당 시간표로 이동", icon: Image(systemName: "chevron.left")) {}
                .padding(.bottom, 20)
        }
    }
    .preferredColorScheme(.dark)
}

#Preview("다양한 스타일") {
    VStack(spacing: 20) {
        FloatingButton(text: "시간표로 이동", icon: Image(systemName: "arrow.left")) {}
        FloatingButton(text: "관심강좌로 이동", icon: Image(systemName: "star.fill")) {}
        FloatingButton(text: "확인", icon: Image(systemName: "checkmark")) {}
    }
    .padding()
}
