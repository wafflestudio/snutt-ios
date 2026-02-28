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
                .font(
                    isSelected
                        ? .system(size: 14, weight: .bold)
                        : .system(size: 14)
                )
                .foregroundStyle(
                    isSelected
                        ? Color.selectedOptionChipLabel
                        : Color.unselectedOptionChipLabel
                )
                .padding(.vertical, 8)
                .padding(.horizontal, 24)
                .background(isSelected ? Color.optionChipBackground : .clear)
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
