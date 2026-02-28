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
    @State private var viewModel = LectureDiaryListViewModel()
    @State private var showEditDiary = false
    @State private var showDiaryNotAvailableAlert = false

    public init() {}

    public var body: some View {
        Group {
            switch viewModel.diaryListState {
            case .loading:
                ProgressView()
            case .empty:
                emptyStateView
            case .loaded(let diaries):
                filledStateView(diaries: diaries)
            case .failed:
                errorView()
            }
        }
        .navigationTitle(LectureDiaryStrings.lectureDiaryTitle)
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadDiaryList()
        }
        .fullScreenCover(isPresented: $showEditDiary) {
            // TODO: Pass actual lecture data
            EditLectureDiaryScene(lectureID: "temp", lectureTitle: "컴퓨터의 개념 및 실습")
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
                    showDiaryNotAvailableAlert = viewModel.targetLecture == nil
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
        //        .fullScreenCover(item: $lectureForDiary) { lecture in
        //            EditLectureDiaryScene(
        //                viewModel: .init(container: viewModel.container),
        //                lecture: lecture
        //            )
        //        }
    }

    private func filledStateView(diaries: [DiarySubmissionsOfYearSemester]) -> some View {
        ScrollView {
            VStack(spacing: 0) {
                // Quarter chips
                if !viewModel.availableQuarters.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(viewModel.availableQuarters, id: \.self) { quarter in
                                SemesterChip(
                                    semester: quarter.id,
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

                // Group diaries by date
                let groupedDiaries = Dictionary(grouping: diaries.map(\.diaryList)) { diary in
                    //Calendar.current.startOfDay(for: diary.date)
                    diary.count
                }
                //
                //                ForEach(groupedDiaries.keys.sorted(by: >), id: \.self) { date in
                //                    if let diariesForDate = groupedDiaries[date] {
                //                        ExpandableDiarySummaryCell(
                //                            diaryList: diariesForDate,
                //                            onDelete: { diaryID in
                //                                Task {
                //                                    await viewModel.deleteDiary(id: diaryID)
                //                                }
                //                            }
                //                        )
                //                    }
                //                }
            }
        }
    }

    private func errorView() -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundStyle(.red)

            Text("오류가 발생했습니다")
                .font(.system(size: 15, weight: .semibold))

            Text("잠시 후 다시 시도해주세요")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("다시 시도") {
                Task {
                    await viewModel.loadDiaryList()
                }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
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
