import Dependencies
import Foundation
import Spyable

@Spyable
public protocol LectureReminderRepository: Sendable {
    /// Fetches all lecture reminders for a specific timetable
    func fetchReminders(timetableID: String) async throws -> [LectureReminder]

    /// Gets the reminder option for a specific lecture
    func getReminder(timetableID: String, lectureID: String) async throws -> ReminderOption

    /// Updates the reminder option for a specific lecture
    func updateReminder(
        timetableID: String,
        lectureID: String,
        option: ReminderOption
    ) async throws
        -> LectureReminder
}
