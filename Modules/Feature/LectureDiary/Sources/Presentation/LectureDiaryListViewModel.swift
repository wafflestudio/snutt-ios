#if FEATURE_LECTURE_DIARY
//
//  LectureDiaryListViewModel.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Dependencies
import Foundation
import LectureDiaryInterface
import Observation
import SwiftUtility
import TimetableInterface

@Observable
@MainActor
public final class LectureDiaryListViewModel {
    @ObservationIgnored
    @Dependency(\.lectureDiaryRepository) private var diaryRepository

    @ObservationIgnored
    @Dependency(\.notificationCenter) private var notificationCenter

    private(set) var diariesGroupedByDate: [(Date, [DiarySummary])] = []

    private(set) var diaryListState: DiaryListState = .loading {
        didSet { updateDiariesGroupedByDate() }
    }

    private(set) var selectedQuarter: Quarter? {
        didSet { updateDiariesGroupedByDate() }
    }

    private(set) var availableQuarters: [Quarter] = []

    public init() {
        Task.scoped(
            to: self,
            subscribing: notificationCenter.messages(of: RefreshLectureDiaryListMessage.self)
        ) { @MainActor viewModel, _ in
            await viewModel.loadDiaryList()
        }
    }

    func loadDiaryList() async {
        if case .loaded = diaryListState {
            // keep existing data visible
        } else {
            diaryListState = .loading
        }

        do {
            let diaries = try await diaryRepository.fetchDiaryList()
            if diaries.isEmpty {
                diaryListState = .empty
            } else {
                diaryListState = .loaded(diaries)
                availableQuarters = extractQuarters(from: diaries)
                if !availableQuarters.contains(where: { $0 == selectedQuarter }) {
                    selectedQuarter = availableQuarters.first
                }
            }
        } catch {
            diaryListState = .failed
        }
    }

    func selectQuarter(_ quarter: Quarter) {
        selectedQuarter = quarter
    }

    func deleteDiary(id: String) async throws {
        try await diaryRepository.deleteDiary(diaryID: id)
        guard case .loaded(let diaries) = diaryListState else { return }
        let updatedDiaries = diaries.compactMap { group in
            let filteredList = group.diaryList.filter { $0.id != id }
            return filteredList.isEmpty
                ? nil : DiarySubmissionsOfYearSemester(quarter: group.quarter, diaryList: filteredList)
        }
        availableQuarters = extractQuarters(from: updatedDiaries)
        if let current = selectedQuarter, !availableQuarters.contains(current) {
            selectedQuarter = availableQuarters.first
        }
        diaryListState = updatedDiaries.isEmpty ? .empty : .loaded(updatedDiaries)
    }

    func navigateToDiaryWrite() async -> Bool {
        do {
            let context = try await diaryRepository.fetchTargetLecture()
            notificationCenter.post(
                NavigateToLectureDiaryMessage(lectureID: context.lectureID, lectureTitle: context.lectureTitle)
            )
            return true
        } catch {
            return false
        }
    }

    private func updateDiariesGroupedByDate() {
        guard case .loaded(let diaries) = diaryListState else {
            diariesGroupedByDate = []
            return
        }
        let selectedDiaries = diaries.first { $0.quarter == selectedQuarter }?.diaryList ?? []
        diariesGroupedByDate = Dictionary(grouping: selectedDiaries) {
            Calendar.current.startOfDay(for: $0.date)
        }
        .sorted { $0.key > $1.key }
    }

    private func extractQuarters(from diaries: [DiarySubmissionsOfYearSemester]) -> [Quarter] {
        let uniqueQuarters = Set(diaries.map(\.quarter))
        return uniqueQuarters.sorted(by: >)
    }
}

extension LectureDiaryListViewModel {
    enum DiaryListState {
        case loading
        case empty
        case loaded([DiarySubmissionsOfYearSemester])
        case failed
    }
}
#endif
