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

                            AnimatableButton(animationOptions: .scale(0.95).impact()) {
                                withAnimation(.defaultSpring) {
                                    deselect(tag)
                                }
                            } configuration: { button in
                                var config = UIButton.Configuration.borderedProminent()
                                config.cornerStyle = .capsule
                                config.attributedTitle = .init(tag.localizedDescription, font: .systemFont(ofSize: 14))
                                config.image = TimetableAsset.xmark.image
                                    .withTintColor(.white)
                                    .resized(to: .init(width: 10, height: 10))
                                config.imagePlacement = .trailing
                                config.baseBackgroundColor = UIColor(tag.category.backgroundColor)
                                config.imagePadding = 5
                                button.tintAdjustmentMode = .normal
                                return config
                            }
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
