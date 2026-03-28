//
//  SearchPredicateScrollView.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import FoundationUtility
import SharedUIComponents
import SwiftUI

struct SearchPredicateScrollView: View {
    let selectedTagList: [SearchPredicate]
    let deselect: @MainActor (SearchPredicate) -> Void

    var body: some View {
        ScrollViewReader { reader in
            VStack(spacing: 0) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(selectedTagList, id: \.localizedDescription) { (tag: SearchPredicate) in

                            Button {
                                withAnimation(.defaultSpring) {
                                    deselect(tag)
                                }
                            } label: {
                                HStack(spacing: 5) {
                                    Text(tag.localizedDescription)
                                        .font(.system(size: 14))
                                    Image(uiImage: TimetableAsset.xmark.image)
                                        .renderingMode(.template)
                                        .resizable()
                                        .frame(width: 10, height: 10)
                                }
                                .foregroundStyle(.white)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(Capsule().fill(tag.category.backgroundColor))
                            }
                            .buttonStyle(.animatable(scale: 0.95, hapticFeedback: true))
                            .id(tag.localizedDescription)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                }
                .withResponsiveTouch()

                Divider()
                    .frame(height: 1)
            }
            .onChange(of: selectedTagList.count) { previousCount, newValue in
                if newValue <= previousCount {
                    return
                }
                withAnimation(.defaultSpring) {
                    reader.scrollTo(selectedTagList.last?.localizedDescription, anchor: .trailing)
                }
            }
        }
    }
}

extension SearchFilterCategory {
    fileprivate var backgroundColor: Color {
        switch self {
        case .sortCriteria: return Color(hex: "#A6A6A6")
        case .academicYear: return Color(hex: "#E54459")
        case .classification: return Color(hex: "#F58D3D")
        case .credit: return Color(hex: "#A6D930")
        case .department: return Color(hex: "#1BD0C8")
        case .time: return Color(hex: "#1D99E8")
        case .category: return Color(hex: "#4F48C4")
        case .categoryPre2025: return Color(hex: "#4F48C4")
        case .etc: return Color(hex: "#AF56B3")
        case .instructor: return Color.clear  // not supported
        }
    }
}

#Preview {
    SearchPredicateScrollView(
        selectedTagList: [.academicYear("1학년"), .credit(1)],
        deselect: { _ in }
    )
}
