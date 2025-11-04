//
//  OptionChip.swift
//  SNUTT
//
//  Created by 최유림 on 11/3/25.
//

import SwiftUI

struct OptionChip: View {
    
    let label: String
    let state: ChipState
    let select: () -> Void
    
    var body: some View {
        Button {
            select()
        } label: {
            Text(label)
                .foregroundColor(state.labelColor)
                .font(state.font)
                .padding(.vertical, 8)
                .padding(.horizontal, 24)
                .background(state.backgroundColor)
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .stroke(state.borderColor, lineWidth: state.borderWidth)
                )
        }
    }
}

extension OptionChip {
    enum ChipState {
        case selected
        case `default`
        case darkSelected
        case darkDefault
        
        init(selected: Bool, colorScheme: ColorScheme) {
            if colorScheme == .dark {
                self = selected ? .darkSelected : .darkDefault
            } else {
                self = selected ? .selected : .default
            }
        }
        
        var font: Font {
            switch self {
            case .selected, .darkSelected: return STFont.bold14.font
            case .default, .darkDefault: return STFont.regular14.font
            }
        }
        
        var labelColor: Color {
            switch self {
            case .selected: return Color(hex: "#059A94")
            case .default: return .black
            case .darkSelected: return STColor.darkMint1
            case .darkDefault: return STColor.assistive
            }
        }
        
        var borderWidth: CGFloat {
            switch self {
            case .selected, .darkSelected: return 1
            case .default, .darkDefault: return 0.6
            }
        }
        
        var borderColor: Color {
            switch self {
            case .selected: return STColor.lightCyan
            case .default: return STColor.neutral95
            case .darkSelected: return STColor.darkMint2
            case .darkDefault: return STColor.gray30.opacity(0.8)
            }
        }
        
        var backgroundColor: Color {
            switch self {
            case .selected: return STColor.lightCyan.opacity(0.06)
            case .default: return .clear
            case .darkSelected: return STColor.darkMint2.opacity(0.08)
            case .darkDefault: return .clear
            }
        }
    }
}
