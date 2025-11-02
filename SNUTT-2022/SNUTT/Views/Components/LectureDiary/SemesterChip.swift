//
//  SemesterChip.swift
//  SNUTT
//
//  Created by 최유림 on 11/2/25.
//

import SwiftUI

struct SemesterChip: View {
    
    let semester: String
    let isSelected: Bool
    let selected: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        Button {
            selected()
        } label: {
            Text(semester)
                .font(
                    isSelected
                    ? .system(size: 15, weight: .semibold)
                    : .system(size: 15)
                )
                .foregroundStyle(semesterChipForeground(isSelected))
                .padding(.horizontal, 24)
                .padding(.vertical, 8)
                .background(semesterChipBackground(isSelected))
                .clipShape(Capsule())
        }
    }
    
    private func semesterChipForeground(_ selected: Bool) -> Color {
        selected
        ? .white
        : (colorScheme == .dark ? STColor.assistive : STColor.alternative)
    }
    
    private func semesterChipBackground(_ selected: Bool) -> Color {
        switch colorScheme {
        case .dark:
            selected ? STColor.darkMint1 : STColor.neutral5
        default:
            selected ? STColor.cyan : STColor.neutral98
        }
    }
}
