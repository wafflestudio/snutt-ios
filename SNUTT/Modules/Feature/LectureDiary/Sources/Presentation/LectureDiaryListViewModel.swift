#if FEATURE_LECTURE_DIARY
//
//  LectureDiaryListViewModel.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Dependencies
import Foundation
import Observation
import TimetableInterface

@Observable
@MainActor
public final class LectureDiaryListViewModel {
    @ObservationIgnored
    @Dependency(\.lectureDiaryRepository) private var diaryRepository

    var diaryEditContext: DiaryEditContext?
    private(set) var diariesGroupedByDate: [(Date, [DiarySummary])] = []

    private(set) var diaryListState: DiaryListState = .loading {
        didSet { updateDiariesGroupedByDate() }
    }

    private(set) var selectedQuarter: Quarter? {
        didSet { updateDiariesGroupedByDate() }
    }

    private(set) var availableQuarters: [Quarter] = []

    public init() {}

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
                if let current = selectedQuarter, availableQuarters.contains(current) {
                    // preserve the currently selected quarter
                } else {
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

    func getLectureForDiary() async {
        do {
            diaryEditContext = try await diaryRepository.fetchTargetLecture()
        } catch {
            diaryEditContext = nil
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
