#if FEATURE_LECTURE_DIARY
//
//  LectureDiaryListView.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SharedUIComponents
import SwiftUI
import SwiftUIUtility

public struct LectureDiaryListView: View {

    @Environment(\.errorAlertHandler) private var errorAlertHandler

    @State private var viewModel = LectureDiaryListViewModel()
    @State private var showDiaryNotAvailableAlert = false

    public init() {}

    public var body: some View {
        Group {
            switch viewModel.diaryListState {
            case .loading:
                ProgressView()
            case .empty:
                emptyStateView
            case .loaded:
                filledStateView
            case .failed:
                errorView
            }
        }
        .navigationTitle(LectureDiaryStrings.lectureDiaryTitle)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadDiaryList()
        }
        .overlayLectureDiarySheet($viewModel.diaryEditContext) {
            Task { await viewModel.loadDiaryList() }
        }
    }

    private var emptyStateView: some View {
        VStack(alignment: .center, spacing: 16) {
            VStack(spacing: 24) {
                SharedUIComponentsAsset.catError.swiftUIImage
                VStack(spacing: 8) {
                    Text(LectureDiaryStrings.lectureDiaryEmptyTitle)
                        .font(.system(size: 15, weight: .semibold))
                    Text(LectureDiaryStrings.lectureDiaryEmptyDescription)
                        .font(.systemFont(ofSize: 13), lineHeightMultiple: 1.45)
                        .foregroundStyle(Color.emptyDescriptionForeground)
                }
            }
            .multilineTextAlignment(.center)
            Button {
                Task {
                    await viewModel.getLectureForDiary()
                    if viewModel.diaryEditContext == nil {
                        showDiaryNotAvailableAlert = true
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    Text(LectureDiaryStrings.lectureDiaryEmptyButton)
                        .font(.system(size: 15))
                    LectureDiaryAsset.chevronRight.swiftUIImage
                }
                .padding([.vertical, .trailing], 12)
                .padding(.leading, 20)
            }
            .buttonBorderShape(.capsule)
            .foregroundStyle(.primary)
            .overlay(Capsule().stroke(Color.capsuleBorder))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert(
            LectureDiaryStrings.lectureDiaryEmptyAlertTitle,
            isPresented: $showDiaryNotAvailableAlert
        ) {}
    }

    private var filledStateView: some View {
        VStack(spacing: 0) {
            // Quarter chips
            if !viewModel.availableQuarters.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(viewModel.availableQuarters, id: \.self) { quarter in
                            SemesterChip(
                                semester: quarter.shortDescription,
                                isSelected: viewModel.selectedQuarter == quarter,
                                onTap: {
                                    viewModel.selectQuarter(quarter)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                }
            }

            ScrollView {
                ForEach(viewModel.diariesGroupedByDate, id: \.0) { date, diariesForDate in
                    ExpandableDiarySummaryCell(
                        diaryList: diariesForDate,
                        onDelete: { id in deleteDiary(id) }
                    )
                }
            }
        }
    }

    private var errorView: some View {
        ErrorStateView {
            Task {
                await viewModel.loadDiaryList()
            }
        }
    }

    private func deleteDiary(_ id: String) {
        errorAlertHandler.withAlert {
            try await viewModel.deleteDiary(id: id)
        }
    }
}

#Preview("Empty State") {
    NavigationStack {
        LectureDiaryListView()
    }
}

#Preview("Filled State") {
    NavigationStack {
        LectureDiaryListView()
    }
}
#endif
