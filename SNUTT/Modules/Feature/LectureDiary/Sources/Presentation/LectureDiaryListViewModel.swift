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
    var diariesGroupedByDate: [(Date, [DiarySummary])] {
        guard case .loaded(let diaries) = diaryListState else { return [] }
        let selectedDiaries = diaries.first { $0.quarter == selectedQuarter }?.diaryList ?? []
        return Dictionary(grouping: selectedDiaries) {
            Calendar.current.startOfDay(for: $0.date)
        }
        .sorted { $0.key > $1.key }
    }

    private(set) var diaryListState: DiaryListState = .loading
    private(set) var selectedQuarter: Quarter?
    private(set) var availableQuarters: [Quarter] = []

    public init() {}

    func loadDiaryList() async {
        diaryListState = .loading

        do {
            let diaries = try await diaryRepository.fetchDiaryList()
            if diaries.isEmpty {
                diaryListState = .empty
            } else {
                diaryListState = .loaded(diaries)
                // Extract unique quarters
                availableQuarters = extractQuarters(from: diaries)
                selectedQuarter = availableQuarters.first
            }
        } catch {
            diaryListState = .failed
        }
    }

    func selectQuarter(_ quarter: Quarter) {
        selectedQuarter = quarter
    }

    func deleteDiary(id: String) async {
        do {
            try await diaryRepository.deleteDiary(diaryID: id)
            await loadDiaryList()
        } catch {
            // TODO: Handle error
            print("Failed to delete diary: \(error)")
        }
    }

    func getLectureForDiary() async {
        do {
            diaryEditContext = try await diaryRepository.fetchTargetLecture()
        } catch {
            diaryEditContext = nil
            diaryListState = .failed
        }
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
