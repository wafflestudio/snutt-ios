//
//  EvaluationFilterSheet.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI
import SwiftUIUtility

/// A two-column picker for search filter tags: categories on the leading side, their tags on the trailing side.
struct EvaluationFilterSheet: View {
    @State private var viewModel: EvaluationFilterViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.errorAlertHandler) private var errorAlertHandler
    private let onApply: ([SearchTag]) -> Void

    init(selectedTags: [SearchTag], onApply: @escaping ([SearchTag]) -> Void) {
        _viewModel = State(initialValue: EvaluationFilterViewModel(selectedTags: selectedTags))
        self.onApply = onApply
    }

    var body: some View {
        NavigationStack {
            content
                .navigationTitle(EvaluationsStrings.filterTitle)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button(EvaluationsStrings.cancel, systemImage: "xmark") {
                            dismiss()
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button(EvaluationsStrings.filterApply, systemImage: "checkmark") {
                            onApply(viewModel.selectedTags)
                            dismiss()
                        }
                        .tint(EvaluationDesignColor.accent)
                    }
                }
        }
        .presentationDetents([.medium])
        .analyticsScreen(.reviewFilter)
        .onLoad {
            // The skeleton has no failed state to recover from, so close the sheet and let the alert explain.
            if await errorAlertHandler.withAlert(operation: { try await viewModel.load() }) == nil {
                dismiss()
            }
        }
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.groupsState {
        case .loading:
            filterColumns(
                groups: EvaluationPreviewFixtures.tagGroups,
                selectedGroup: EvaluationPreviewFixtures.tagGroups[0]
            )
            .redacted(reason: .placeholder)
            .allowsHitTesting(false)
            .accessibilityHidden(true)
        case .loaded(let groups):
            filterColumns(groups: groups, selectedGroup: viewModel.selectedGroup)
        }
    }

    private func filterColumns(groups: [SearchTagGroup], selectedGroup: SearchTagGroup?) -> some View {
        TwoColumnFilterPicker(
            categories: groups,
            selectedCategory: selectedGroup,
            title: \.name,
            selectedCount: viewModel.selectedCount(in:),
            accentColor: EvaluationDesignColor.accent,
            onSelectCategory: { group in
                viewModel.selectedGroupID = group.id
            },
            detail: { group in
                ForEach(group.tags) { tag in
                    FilterOptionRow(
                        title: tag.name,
                        isSelected: viewModel.isSelected(tag),
                        accentColor: EvaluationDesignColor.accent
                    ) {
                        withAnimation(.defaultSpring) {
                            viewModel.toggle(tag)
                        }
                    }
                }
            }
        )
    }
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            EvaluationFilterSheet(selectedTags: [EvaluationPreviewFixtures.tagGroups[0].tags[0]], onApply: { _ in })
        }
}
