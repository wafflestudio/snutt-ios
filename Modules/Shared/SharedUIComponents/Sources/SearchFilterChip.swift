//
//  SearchFilterChip.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI

public struct SearchFilterChip: View {
    private let title: String
    private let foregroundColor: Color
    private let backgroundColor: Color
    private let borderColor: Color?
    private let borderWidth: CGFloat
    private let font: Font
    private let icon: Image
    private let iconFont: Font?
    private let iconSize: CGSize?
    private let spacing: CGFloat
    private let horizontalPadding: CGFloat
    private let verticalPadding: CGFloat?
    private let height: CGFloat?

    public init(
        title: String,
        foregroundColor: Color,
        backgroundColor: Color,
        borderColor: Color? = nil,
        borderWidth: CGFloat = 1,
        font: Font = .system(size: 14),
        icon: Image = Image(systemName: "xmark"),
        iconFont: Font? = nil,
        iconSize: CGSize? = nil,
        spacing: CGFloat = 5,
        horizontalPadding: CGFloat = 12,
        verticalPadding: CGFloat? = 8,
        height: CGFloat? = nil
    ) {
        self.title = title
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.font = font
        self.icon = icon
        self.iconFont = iconFont
        self.iconSize = iconSize
        self.spacing = spacing
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.height = height
    }

    public var body: some View {
        HStack(spacing: spacing) {
            Text(title)
                .font(font)
                .lineLimit(1)

            iconView
        }
        .foregroundStyle(foregroundColor)
        .padding(.horizontal, horizontalPadding)
        .padding(.vertical, verticalPadding ?? 0)
        .frame(height: height)
        .background(Capsule().fill(backgroundColor))
        .overlay {
            if let borderColor {
                Capsule()
                    .strokeBorder(borderColor, lineWidth: borderWidth)
            }
        }
    }

    @ViewBuilder private var iconView: some View {
        if let iconSize {
            icon
                .renderingMode(.template)
                .resizable()
                .frame(width: iconSize.width, height: iconSize.height)
        } else if let iconFont {
            icon
                .font(iconFont)
        } else {
            icon
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 16) {
        SearchFilterChip(
            title: "1학년",
            foregroundColor: Color(red: 0.08, green: 0.78, blue: 0.74),
            backgroundColor: Color(red: 0.94, green: 1.0, blue: 0.99),
            borderColor: Color(red: 0.08, green: 0.78, blue: 0.74),
            font: .system(size: 14, weight: .medium),
            iconFont: .system(size: 12, weight: .regular),
            spacing: 6,
            horizontalPadding: 13,
            verticalPadding: nil,
            height: 30
        )

        SearchFilterChip(
            title: "디자인과",
            foregroundColor: .white,
            backgroundColor: .teal,
            iconSize: CGSize(width: 10, height: 10)
        )
    }
    .padding()
}
