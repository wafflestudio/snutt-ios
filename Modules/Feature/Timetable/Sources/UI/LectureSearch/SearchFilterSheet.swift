//
//  SearchFilterSheet.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import FoundationUtility
import SharedUIComponents
import SwiftUI

struct SearchFilterSheet: View {
    @Bindable var viewModel: LectureSearchViewModel

    @Environment(\.dismiss) private var dismiss
    @Environment(\.errorAlertHandler) private var errorAlertHandler

    /// The selection when the sheet opened, restored unless the user applies.
    @State private var initialPredicates: [SearchPredicate]?
    @State private var isApplied = false

    var body: some View {
        NavigationStack {
            TwoColumnFilterPicker(
                categories: viewModel.supportedCategories,
                selectedCategory: viewModel.selectedCategory,
                title: \.localizedDescription,
                selectedCount: viewModel.selectedCount(in:),
                accentColor: SharedUIComponentsAsset.cyanSecondary.swiftUIColor,
                onSelectCategory: { category in
                    viewModel.selectedCategory = category
                },
                detail: { category in
                    switch category {
                    case .time:
                        TimeFilterOptionsView(viewModel: viewModel)
                    default:
                        filterOptions(in: category)
                    }
                }
            )
            .navigationTitle(TimetableStrings.searchFilterTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(SharedUIComponentsStrings.alertCancel, systemImage: "xmark") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(SharedUIComponentsStrings.alertApply, systemImage: "checkmark") {
                        apply()
                    }
                    .tint(SharedUIComponentsAsset.cyanSecondary.swiftUIColor)
                }
            }
        }
        .presentationDetents([.medium, .large])
        // Scrolling a long list moves the list, not the sheet; only the grabber resizes it.
        .presentationContentInteraction(.scrolls)
        // The dimmed timetable behind shows through the translucent medium detent and washes out the options.
        .presentationBackground(Color(.systemBackground))
        .presentationCompactAdaptation(horizontal: .sheet, vertical: .sheet)
        .analyticsScreen(.searchFilter)
        .onAppear {
            if initialPredicates == nil {
                initialPredicates = viewModel.selectedPredicates
            }
        }
        .onDisappear {
            if !isApplied, let initialPredicates {
                viewModel.selectedPredicates = initialPredicates
            }
        }
    }

    private func filterOptions(in category: SearchFilterCategory) -> some View {
        ForEach(viewModel.availablePredicates[category] ?? [], id: \.localizedDescription) { predicate in
            FilterOptionButton(
                title: predicate.localizedDescription,
                isSelected: viewModel.selectedPredicates.contains(predicate)
            ) {
                viewModel.togglePredicate(predicate: predicate)
            }
        }
    }

    private func apply() {
        isApplied = true
        dismiss()
        errorAlertHandler.withAlert {
            try await viewModel.fetchInitialSearchResult()
        }
    }
}

/// A ``FilterOptionRow`` tinted for lecture search.
struct FilterOptionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        FilterOptionRow(
            title: title,
            isSelected: isSelected,
            accentColor: SharedUIComponentsAsset.cyanSecondary.swiftUIColor
        ) {
            withAnimation(.defaultSpring) {
                action()
            }
        }
    }
}

struct TimeFilterOptionsView: View {
    @Bindable var viewModel: LectureSearchViewModel

    var body: some View {
        // Empty slots option
        FilterOptionButton(
            title: TimetableStrings.searchPredicateTimeEmptySlots,
            isSelected: viewModel.isTimeExcludeSelected
        ) {
            if viewModel.isTimeExcludeSelected {
                viewModel.clearTimeFilter()
            } else {
                viewModel.setTimeExcludeRangesFromCurrentTimetable()
            }
        }

        // Direct selection option
        FilterOptionButton(
            title: TimetableStrings.searchPredicateTimeDirectSelection,
            isSelected: viewModel.isTimeIncludeSelected
        ) {
            viewModel.isTimeSelectionSheetOpen = true
        }
        .sheet(isPresented: $viewModel.isTimeSelectionSheetOpen) {
            TimeSelectionSheet(
                currentTimetable: viewModel.timetableViewModel.currentTimetable,
                initialRanges: viewModel.selectedTimeIncludeRanges
            ) { ranges in
                viewModel.setTimeIncludeRanges(ranges)
            }
        }

        // Display selected time ranges
        if !viewModel.selectedTimeIncludeRanges.isEmpty {
            Text(formattedTimeRanges)
                .lineSpacing(4)
                .font(.system(size: 13))
                .foregroundStyle(.tertiary)
                .underline()
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 36)
                .listRowSeparator(.hidden, edges: .top)
        }
    }

    private var formattedTimeRanges: String {
        viewModel.selectedTimeIncludeRanges
            .map { $0.formatted() }
            .joined(separator: "\n")
    }
}

#Preview {
    @Previewable @State var isPresented = true
    let timetableViewModel = TimetableViewModel()
    let _ = Task {
        try await timetableViewModel.loadTimetable()
    }
    ZStack {
        Color.gray
        Button("Present") {
            isPresented = true
        }
        .buttonStyle(.borderedProminent)
        .padding(.bottom, 300)
    }
    .ignoresSafeArea()
    .sheet(isPresented: $isPresented) {
        SearchFilterSheet(viewModel: .init(timetableViewModel: timetableViewModel))
    }
}
