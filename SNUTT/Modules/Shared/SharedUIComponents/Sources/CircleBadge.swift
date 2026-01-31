//
//  CircleBadge.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI

public struct CircleBadge: View {
    let color: Color

    public init(color: Color) {
        self.color = color
    }

    public var body: some View {
        Circle()
            .fill(color)
            .frame(width: 4, height: 4)
    }
}

struct CircleBadgeModifier: ViewModifier {
    let condition: Bool
    let color: Color

    func body(content: Content) -> some View {
        ZStack(alignment: .topTrailing) {
            content

            if condition {
                CircleBadge(color: .red)
            }
        }
    }
}

extension View {
    public func circleBadge(condition: Bool, color: Color = .red) -> some View {
        modifier(CircleBadgeModifier(condition: condition, color: color))
    }
}
