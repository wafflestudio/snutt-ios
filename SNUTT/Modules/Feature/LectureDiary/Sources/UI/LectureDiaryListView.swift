//
//  LectureDiaryListView.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI

public struct LectureDiaryListView: View {
    @State private var viewModel = LectureDiaryListViewModel()
    @State private var showEditDiary = false

    public init() {}

    public var body: some View {
        Group {
            switch viewModel.diaryListState {
            case .loading:
                ProgressView()
            case .empty:
                emptyStateView
            case let .loaded(diaries):
                filledStateView(diaries: diaries)
            case .failed:
                errorView()
            }
        }
        .navigationTitle("강의 일기장")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadDiaryList()
        }
        .fullScreenCover(isPresented: $showEditDiary) {
            // TODO: Pass actual lecture data
            EditLectureDiaryScene(lectureID: "temp", lectureTitle: "임시 강의")
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("강의일기장이 비어있어요.")
                .font(.system(size: 15, weight: .semibold))

            Text("매주 마지막 수업날,\n푸시알림을 통해 강의일기를\n작성해보세요!")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .lineSpacing(2)

            Button {
                showEditDiary = true
            } label: {
                HStack {
                    Text("강의일기 작성하기")
                    Image(systemName: "arrow.right")
                }
                .font(.system(size: 15))
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .overlay(
                    Capsule()
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
            }
        }
        .padding()
    }

    private func filledStateView(diaries: [DiarySummary]) -> some View {
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
                let groupedDiaries = Dictionary(grouping: diaries) { diary in
                    Calendar.current.startOfDay(for: diary.date)
                }

                ForEach(groupedDiaries.keys.sorted(by: >), id: \.self) { date in
                    if let diariesForDate = groupedDiaries[date] {
                        ExpandableDiarySummaryCell(
                            diaryList: diariesForDate,
                            onDelete: { diaryID in
                                Task {
                                    await viewModel.deleteDiary(id: diaryID)
                                }
                            }
                        )
                    }
                }
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
