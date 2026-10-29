//
//  EvaluationSortToggle.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI

extension EvaluationSort.Kind {
    var evaluationDisplayTitle: String {
        switch self {
        case .recommended:
            "추천순"
        case .latest:
            "최신순"
        }
    }
}

struct EvaluationSortToggle: View {
    let sorts: [EvaluationSort]
    let selectedSort: EvaluationSort
    let onSelect: (EvaluationSort) -> Void

    var body: some View {
        HStack(spacing: 16) {
            ForEach(sorts) { sort in
                Button {
                    onSelect(sort)
                } label: {
                    Text("• \(sort.kind.evaluationDisplayTitle)")
                        .font(.system(size: 15, weight: sort == selectedSort ? .semibold : .regular))
                        .foregroundStyle(sort == selectedSort ? Color.primary : Color.secondary)
                        .contentTransition(.opacity)
                }
                .buttonStyle(.animatable())
            }

            Spacer(minLength: 0)
        }
        .padding(.vertical, 2)
        .animation(.defaultSpring, value: selectedSort)
    }
}

#Preview {
    EvaluationSortToggle(
        sorts: [
            EvaluationSort(id: 1, kind: .recommended),
            EvaluationSort(id: 2, kind: .latest),
        ],
        selectedSort: EvaluationSort(id: 1, kind: .recommended),
        onSelect: { _ in }
    )
    .padding()
}
