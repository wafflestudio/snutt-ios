//
//  LectureReminderSettingsViewModel.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Dependencies
import Foundation
import Observation
import SharedUIComponents
import TimetableInterface

enum LectureReminderLoadState {
    case loading
    case loaded([LectureReminderViewModel])
    case failed

    var isLoading: Bool {
        if case .loading = self { return true }
        return false
    }

    var reminderViewModels: [LectureReminderViewModel] {
        if case .loaded(let viewModels) = self { return viewModels }
        return []
    }
}

@MainActor
@Observable
public final class LectureReminderSettingsViewModel {
    @ObservationIgnored
    @Dependency(\.lectureReminderRepository) private var lectureReminderRepository

    @ObservationIgnored
    @Dependency(\.timetableRepository) private var timetableRepository

    @ObservationIgnored
    @Dependency(\.semesterRepository) private var semesterRepository

    private(set) var loadState: LectureReminderLoadState = .loading

    public init() {}

    func loadReminders() async throws {
        do {
            guard let timetableID = try await getUpcomingSemesterTimetableID() else {
                loadState = .loaded([])
                return
            }
            let reminders = try await lectureReminderRepository.fetchReminders(timetableID: timetableID)
            let reminderViewModels = reminders.map { reminder in
                LectureReminderViewModel(lectureReminder: reminder, timetableID: timetableID)
            }
            loadState = .loaded(reminderViewModels)
        } catch let error where error.isCancellationError {
            return
        } catch {
            loadState = .failed
            throw error
        }
    }

    private func getUpcomingSemesterTimetableID() async throws -> String? {
        let semesterStatus = try await semesterRepository.fetchSemesterStatus()
        let targetSemester = semesterStatus.currentOrNext
        let timetableMetadataList = try await timetableRepository.fetchTimetableMetadataList()
        return timetableMetadataList.first { metadata in
            metadata.isPrimary
                && metadata.quarter.year == targetSemester.year
                && metadata.quarter.semester == targetSemester.semester
        }?.id
    }

    var sortedReminderViewModels: [LectureReminderViewModel] {
        loadState.reminderViewModels.sorted(by: { $0.lectureReminder.lectureTitle < $1.lectureReminder.lectureTitle })
    }
}
