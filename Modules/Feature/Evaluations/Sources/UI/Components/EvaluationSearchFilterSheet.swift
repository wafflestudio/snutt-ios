//
//  EvaluationSearchFilterSheet.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI
import SwiftUIUtility

struct EvaluationSearchFilterSheet: View {
    @Binding var selectedFilters: [EvaluationSearchFilter]
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory = EvaluationSearchFilterCategory.department

    private var availableOptions: [EvaluationSearchFilter] {
        EvaluationSearchFilter.options(for: selectedCategory)
    }

    var body: some View {
        VStack(spacing: 0) {
            filterContent
            applyButton
        }
        .overlay(alignment: .topTrailing) {
            closeButton
                .padding(.top, 16)
                .padding(.trailing, 18)
        }
        .presentationDetents([.medium, .large])
        .presentationCompactAdaptation(horizontal: .sheet, vertical: .sheet)
    }

    private var filterContent: some View {
        HStack(alignment: .top, spacing: 0) {
            EvaluationSearchFilterCategoryColumn(
                selectedCategory: $selectedCategory
            )

            EvaluationSearchFilterOptionList(
                options: availableOptions,
                selectedFilters: selectedFilters,
                onToggle: toggle
            )
        }
        .frame(maxHeight: .infinity)
    }

    private var applyButton: some View {
        Button {
            dismiss()
        } label: {
            Text("필터 고정")
                .font(.system(size: 17, weight: .bold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(height: 76)
        .background(EvaluationDesignColor.mint)
    }

    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 23, weight: .regular))
                .frame(width: 52, height: 52)
                .contentShape(Rectangle())
        }
        .foregroundStyle(.primary)
        .buttonStyle(.animatable())
    }

    private func toggle(_ filter: EvaluationSearchFilter) {
        withAnimation(.defaultSpring) {
            if selectedFilters.contains(filter) {
                selectedFilters.removeAll { $0 == filter }
            } else {
                selectedFilters.append(filter)
            }
        }
    }
}

private struct EvaluationSearchFilterCategoryColumn: View {
    @Binding var selectedCategory: EvaluationSearchFilterCategory

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(EvaluationSearchFilterCategory.allCases) { category in
                Button {
                    selectedCategory = category
                } label: {
                    Text(category.title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(
                            selectedCategory == category
                                ? Color(uiColor: .label)
                                : Color(uiColor: .tertiaryLabel)
                        )
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.animatable(scale: 0.96))
            }
        }
        .frame(width: 120, alignment: .leading)
        .padding(.leading, 20)
        .padding(.top, 62)
    }
}

private struct EvaluationSearchFilterOptionList: View {
    let options: [EvaluationSearchFilter]
    let selectedFilters: [EvaluationSearchFilter]
    let onToggle: (EvaluationSearchFilter) -> Void

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 23) {
                ForEach(options) { filter in
                    EvaluationSearchFilterOptionButton(
                        filter: filter,
                        isSelected: selectedFilters.contains(filter),
                        onToggle: onToggle
                    )
                }
            }
            .padding(.top, 60)
            .padding(.trailing, 20)
        }
        .withResponsiveTouch()
    }
}

private struct EvaluationSearchFilterOptionButton: View {
    let filter: EvaluationSearchFilter
    let isSelected: Bool
    let onToggle: (EvaluationSearchFilter) -> Void

    var body: some View {
        Button {
            onToggle(filter)
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(isSelected ? EvaluationDesignColor.mint : Color(uiColor: .systemGray4))

                Text(filter.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(Color(uiColor: .label))

                Spacer(minLength: 0)
            }
        }
        .buttonStyle(.animatable(scale: 0.98))
    }
}

#Preview {
    @Previewable @State var selectedFilters = EvaluationSearchFilter.previewSelected
    EvaluationSearchFilterSheet(selectedFilters: $selectedFilters)
}
