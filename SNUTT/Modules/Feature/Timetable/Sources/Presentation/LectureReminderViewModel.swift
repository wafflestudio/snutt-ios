//
//  LectureReminderViewModel.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import AppReviewPromptInterface
import Dependencies
import Foundation
import Observation
import TimetableInterface

@MainActor
@Observable
public final class LectureReminderViewModel {
    @ObservationIgnored
    @Dependency(\.lectureReminderRepository) private var lectureReminderRepository
    @ObservationIgnored
    @Dependency(\.appReviewService) private var appReviewService

    let lectureReminder: LectureReminder
    private let timetableID: String

    var option: ReminderOption
    private var pendingTask: Task<Void, any Error>?

    public init(lectureReminder: LectureReminder, timetableID: String) {
        self.lectureReminder = lectureReminder
        self.timetableID = timetableID
        self.option = lectureReminder.option
    }

    func updateOption(_ newOption: ReminderOption) async throws {
        pendingTask?.cancel()
        option = newOption
        let task = Task { @MainActor in
            defer {
                pendingTask = nil
            }
            do {
                let updatedReminder = try await lectureReminderRepository.updateReminder(
                    timetableID: timetableID,
                    lectureID: lectureReminder.timetableLectureID,
                    option: newOption
                )
                option = updatedReminder.option
                Task {
                    await appReviewService.requestReviewIfNeeded()
                }
            } catch {
                // Propagate error if task was not cancelled
                if !error.isCancellationError {
                    throw error
                }
            }
        }
        pendingTask = task
        try await task.value
    }
}
