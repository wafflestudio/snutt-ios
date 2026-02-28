//
//  SemesterChip.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

struct SemesterChip: View {
    let semester: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            Text(semester)
                .font(
                    isSelected
                        ? .system(size: 15, weight: .semibold)
                        : .system(size: 15)
                )
                .foregroundStyle(
                    isSelected
                        ? .white
                        : Color.unselectedSemesterChipLabel
                )
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
                .background(
                    isSelected
                        ? Color.selectedSemesterChipBackground
                        : Color.unselectedSemesterChipBackground
                )
                .clipShape(Capsule())
        }
    }
}

#Preview("Selected") {
    SemesterChip(semester: "25-1", isSelected: true, onTap: {})
        .padding()
}

#Preview("Unselected") {
    SemesterChip(semester: "25-2", isSelected: false, onTap: {})
        .padding()
}

#Preview("Multiple") {
    HStack(spacing: 8) {
        SemesterChip(semester: "25-1", isSelected: true, onTap: {})
        SemesterChip(semester: "25-2", isSelected: false, onTap: {})
        SemesterChip(semester: "25-여름", isSelected: false, onTap: {})
    }
    .padding()
}
