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
        HStack(alignment: .top, spacing: 0) {
            EvaluationFilterCategoryColumn(
                groups: groups,
                selectedGroupID: selectedGroup?.id,
                selectedCount: viewModel.selectedCount(in:),
                onSelect: { group in
                    viewModel.selectedGroupID = group.id
                }
            )

            Divider()
                .ignoresSafeArea(edges: .bottom)

            List(selectedGroup?.tags ?? []) { tag in
                EvaluationFilterOptionRow(tag: tag, isSelected: viewModel.isSelected(tag)) {
                    withAnimation(.defaultSpring) {
                        viewModel.toggle(tag)
                    }
                }
                .listRowBackground(Color.clear)
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .softTopScrollEdge()
            .id(selectedGroup?.id)
        }
        .animation(.defaultSpring, value: selectedGroup?.id)
    }
}

private struct EvaluationFilterCategoryColumn: View {
    let groups: [SearchTagGroup]
    let selectedGroupID: SearchTagGroup.ID?
    let selectedCount: (SearchTagGroup) -> Int
    let onSelect: (SearchTagGroup) -> Void

    @ScaledMetric private var columnWidth = 112.0

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(groups) { group in
                    let isSelected = group.id == selectedGroupID
                    let count = selectedCount(group)
                    Button {
                        onSelect(group)
                    } label: {
                        HStack(spacing: 6) {
                            Text(group.name)
                                .font(.callout.weight(isSelected ? .semibold : .regular))
                                .foregroundStyle(isSelected ? AnyShapeStyle(.primary) : AnyShapeStyle(.secondary))
                            if count > 0 {
                                Text(count, format: .number)
                                    .font(.caption2.weight(.bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 6)
                                    .frame(minWidth: 18, minHeight: 18)
                                    .background(EvaluationDesignColor.accent, in: .capsule)
                                    .transition(.scale.combined(with: .opacity))
                            }
                            Spacer(minLength: 0)
                        }
                        .padding(.horizontal, 12)
                        .frame(minHeight: 44)
                        .background {
                            if isSelected {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(Color(uiColor: .secondarySystemFill))
                            }
                        }
                        .contentShape(.rect)
                    }
                    .buttonStyle(.animatable(scale: 0.97))
                    .accessibilityAddTraits(isSelected ? .isSelected : [])
                    .accessibilityValue(count > 0 ? EvaluationsStrings.filterSelectedCount(count) : "")
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 8)
        }
        .frame(width: columnWidth)
        .scrollIndicators(.hidden)
        .softTopScrollEdge()
    }
}

private struct EvaluationFilterOptionRow: View {
    let tag: SearchTag
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 12) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundStyle(isSelected ? EvaluationDesignColor.accent : Color(uiColor: .systemGray3))
                    .contentTransition(.symbolEffect(.replace))
                Text(tag.name)
                    .font(.callout)
                    .foregroundStyle(.primary)
                Spacer(minLength: 0)
            }
            .contentShape(.rect)
        }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview {
    Color.clear
        .sheet(isPresented: .constant(true)) {
            EvaluationFilterSheet(selectedTags: [EvaluationPreviewFixtures.tagGroups[0].tags[0]], onApply: { _ in })
        }
}

extension View {
    /// Both columns scroll on their own, and the automatic style draws each one as a hard edge on iOS 27.
    @ViewBuilder
    fileprivate func softTopScrollEdge() -> some View {
        if #available(iOS 26, *) {
            scrollEdgeEffectStyle(.soft, for: .top)
        } else {
            self
        }
    }
}
