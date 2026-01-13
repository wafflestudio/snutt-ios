//
//  OptionChip.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

struct OptionChip: View {
    let label: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(label)
                .font(isSelected ? .system(size: 14, weight: .bold) : .system(size: 14))
                .foregroundStyle(
                    light: isSelected
                        ? SharedUIComponentsAsset.darkMint3.swiftUIColor
                        : .black,
                    dark: isSelected
                        ? SharedUIComponentsAsset.darkMint1.swiftUIColor
                        : SharedUIComponentsAsset.assistive.swiftUIColor
                )
                .foregroundStyle(isSelected ? Color.cyan : .primary)
                .padding(.vertical, 8)
                .padding(.horizontal, 24)
                .backgroundStyle(
                    light: isSelected
                        ? SharedUIComponentsAsset.cyan.swiftUIColor.opacity(0.06)
                        : .clear,
                    dark: isSelected
                        ? SharedUIComponentsAsset.darkMint2.swiftUIColor.opacity(0.08)
                        : .clear
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(
                            isSelected ? Color.cyan : Color.gray.opacity(0.3),
                            lineWidth: isSelected ? 1.0 : 0.6
                        )
                )
        }
    }
}

extension OptionChip {
    private var lightLabelColor: Color {
        isSelected
            ? SharedUIComponentsAsset.darkMint2.swiftUIColor
            : SharedUIComponentsAsset.darkerGray.swiftUIColor
    }

    private var darkLabelColor: Color {
        isSelected
            ? SharedUIComponentsAsset.darkMint1.swiftUIColor
            : SharedUIComponentsAsset.assistive.swiftUIColor
    }

    private var lightBackgroundColor: Color {
        isSelected
            ? SharedUIComponentsAsset.cyan.swiftUIColor.opacity(0.08)
            : .clear
    }

    private var darkBackgroundColor: Color {
        isSelected
            ? SharedUIComponentsAsset.darkMint2.swiftUIColor.opacity(0.08)
            : .clear
    }
}

#Preview("Selected") {
    OptionChip(label: "널널해요", isSelected: true, onTap: {})
        .padding()
}

#Preview("Unselected") {
    OptionChip(label: "무난해요", isSelected: false, onTap: {})
        .padding()
}

#Preview("Multiple Options") {
    VStack(spacing: 12) {
        HStack(spacing: 8) {
            OptionChip(label: "이론수업", isSelected: true, onTap: {})
            OptionChip(label: "토론수업", isSelected: false, onTap: {})
            OptionChip(label: "발표수업", isSelected: true, onTap: {})
        }
        HStack(spacing: 8) {
            OptionChip(label: "실습수업", isSelected: false, onTap: {})
            OptionChip(label: "과제발표", isSelected: false, onTap: {})
            OptionChip(label: "퀴즈", isSelected: false, onTap: {})
        }
    }
    .padding()
}
