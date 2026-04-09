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

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                ScrollView {
                    filterCategoryColumn
                }
                .withResponsiveTouch()
                .frame(width: 120)
                Divider()
                filterSelectionColumn
            }
            .frame(maxHeight: .infinity)
            .padding(.horizontal, 5)
            filterApplyButton
                .padding(.vertical)
        }
        .padding(.top, 30)
        .presentationDetents([.medium, .large])
        .presentationCompactAdaptation(horizontal: .sheet, vertical: .sheet)
        .analyticsScreen(.searchFilter)
    }

    private var filterCategoryColumn: some View {
        VStack {
            ForEach(viewModel.supportedCategories, id: \.rawValue) { category in
                let isSelected = viewModel.selectedCategory == category
                Button {
                    viewModel.selectedCategory = category
                } label: {
                    Text(category.localizedDescription)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(isSelected ? Color(.label) : Color(.label).opacity(0.5))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.vertical, 6)
                        .padding(.horizontal, 8)
                }
                .buttonStyle(.animatable(scale: 0.95, backgroundHighlightColor: Color(.label).opacity(0.05)))
            }
        }
    }

    private var filterSelectionColumn: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                switch viewModel.selectedCategory {
                case .time:
                    TimeFilterOptionsView(viewModel: viewModel)
                default:
                    defaultFilterOptions
                }
            }
        }
        .withResponsiveTouch()
    }

    @ViewBuilder
    private var defaultFilterOptions: some View {
        let predicates = viewModel.availablePredicates[viewModel.selectedCategory] ?? []
        ForEach(predicates, id: \.localizedDescription) { predicate in
            let isSelected = viewModel.selectedPredicates.contains(predicate)
            FilterOptionButton(
                title: predicate.localizedDescription,
                isSelected: isSelected
            ) {
                viewModel.togglePredicate(predicate: predicate)
            }
        }
    }

    private var filterApplyButton: some View {
        Button {
            dismiss()
            errorAlertHandler.withAlert {
                try await viewModel.fetchInitialSearchResult()
            }
        } label: {
            Text(TimetableStrings.searchFilterApply)
                .frame(maxWidth: .infinity)
                .font(.system(size: 17, weight: .semibold))
        }
        .padding(.horizontal)
        .buttonStyle(.borderedProminent)
        .tint(SharedUIComponentsAsset.cyanSecondary.swiftUIColor)
    }
}

struct FilterOptionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button {
            withAnimation(.defaultSpring) {
                action()
            }
        } label: {
            HStack(spacing: 4) {
                if #available(iOS 26.0, *) {
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(
                            isSelected
                                ? SharedUIComponentsAsset.cyanSecondary.swiftUIColor
                                : Color(.secondaryLabel)
                        )
                        .symbolRenderingMode(.multicolor)
                        .contentTransition(
                            .symbolEffect(.replace.magic(fallback: .downUp.byLayer), options: .nonRepeating)
                        )
                        .frame(width: 25, height: 25)
                } else {
                    Image(
                        uiImage: isSelected
                            ? TimetableAsset.checkmarkCircleTick.image
                            : TimetableAsset.checkmarkCircleUntick.image
                    )
                }
                Text(title)
                    .font(.system(size: 14))
            }
            .foregroundStyle(Color(.label))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
        }
        .buttonStyle(.animatable(scale: 0.98))
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
                .padding(.leading, 32)
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
