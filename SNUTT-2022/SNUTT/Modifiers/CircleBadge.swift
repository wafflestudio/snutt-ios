//
//  CircleBadge.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/08/31.
//

import SwiftUI


struct CircleBadge: ViewModifier {
    let condition: Bool
    let color: Color
    
    func body(content: Content) -> some View {
        ZStack(alignment: .topTrailing) {
            content
            
            if condition {
            Circle()
                .fill(color)
                .frame(width: 4, height: 4)
            }
        }
    }
}


extension View {
    func circleBadge(condition: Bool, color: Color = .red) -> some View {
        modifier(CircleBadge(condition: condition, color: color))
    }
}
