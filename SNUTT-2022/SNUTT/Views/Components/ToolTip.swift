//
//  ToolTip.swift
//  SNUTT
//
//  Created by 최유림 on 10/9/25.
//

import SwiftUI

struct ToolTip: View {
    
    let label: String
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var isAnimating: Bool = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text(label)
                .foregroundStyle(STColor.darkMint1)
                .font(STFont.medium14.font)
                .padding(.vertical, 9)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(STColor.milkMint, lineWidth: 0.4)
                )
                .shadow(color: STColor.darkMintShadow.opacity(0.24), radius: 12)
            
            VStack(alignment: .center, spacing: -3) {
                Image("light.chevron.down")
                    .offset(y: isAnimating ? 2 : -3)
                    .animation(
                        Animation
                            .easeIn(duration: 0.5)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
                Image("dark.chevron.down")
                    .offset(y: isAnimating ? 2 : -3)
                    .animation(
                        Animation
                            .easeIn(duration: 0.5)
                            .repeatForever(autoreverses: true)
                            .delay(0.03),
                        value: isAnimating
                    )
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    ToolTip(label: "스크롤하면 상시강의를 확인할 수 있어요.")
}
