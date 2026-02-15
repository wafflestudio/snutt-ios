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
    @Dependency(\.lectureDiaryRepository) private var repository

    var targetLecture: Lecture?

    private(set) var diaryListState: DiaryListState = .loading
    private(set) var selectedQuarter: Quarter?
    private(set) var availableQuarters: [Quarter] = []

    public init() {}

    func loadDiaryList() async {
        diaryListState = .loading

        do {
            let diaries = try await repository.fetchDiaryList()

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
            try await repository.deleteDiary(diaryID: id)
            await loadDiaryList()
        } catch {
            // TODO: Handle error
            print("Failed to delete diary: \(error)")
        }
    }

    func getLectureForDiary() async {
        //        guard let targetMetaData = services.lectureService.getCurrentOrNextSemesterPrimaryTable()
        //        else { return nil }
        //        do {
        //            let targetTable = try await services.timetableService.fetchTimetableData(timetableId: targetMetaData.id)
        //            return targetTable.lectures.first { $0.lectureId != nil }
        //        } catch {
        //            print("Failed to get lecture for diary: \(error)")
        //        }
    }

    private func extractQuarters(from diaries: [DiarySubmissionsOfYearSemester]) -> [Quarter] {
        let uniqueQuarters = Set(diaries.map(\.quarter))
        return uniqueQuarters.sorted()
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
