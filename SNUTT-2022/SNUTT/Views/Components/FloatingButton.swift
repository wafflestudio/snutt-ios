//
//  FloatingButton.swift
//  SNUTT
//
//  Created by user on 4/10/24.
//

import SwiftUI

struct FloatingButton: View {
    var text: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 14))
                    .scaledToFit()
                    .foregroundColor(.white)
                Text(text)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
        }
        .buttonStyle(FloatingButtonStyle())
    }
}

private struct FloatingButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(STColor.cyan)
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.2), radius: 3)
            .overlay {
                Capsule()
                    .strokeBorder(Color(uiColor: .label).opacity(0.05), lineWidth: 1)
            }
            .scaleEffect(configuration.isPressed ? 0.95 : 1) // Scale down when pressed
            .animation(.customSpring, value: configuration.isPressed)
    }
}

#Preview {
    ZStack {
        FloatingButton(text: "시간표로 이동") {}
    }
}
