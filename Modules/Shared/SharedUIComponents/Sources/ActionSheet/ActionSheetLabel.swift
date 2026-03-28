//
//  ActionSheetLabel.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI

public struct ActionSheetLabel: View {
    public static let rowHeight: CGFloat = 48

    public enum Role {
        case normal
        case destructive
    }

    private let image: Image?
    private let title: String
    private let role: Role

    public init(image: Image? = nil, title: String, role: Role = .normal) {
        self.image = image
        self.title = title
        self.role = role
    }

    private var foregroundColor: Color {
        switch role {
        case .normal: .primary
        case .destructive: .red
        }
    }

    public var body: some View {
        HStack(spacing: 10) {
            if let image {
                image
                    .frame(width: 24, height: 24)
            }
            Text(title)
            Spacer()
        }
        .foregroundStyle(foregroundColor)
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .contentShape(Rectangle())
    }
}
