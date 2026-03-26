import Dependencies
import Foundation
import Spyable
import TimetableInterface

@Spyable
public protocol LectureReminderRepository: Sendable {
    /// Fetches all lecture reminders for a specific timetable
    func fetchReminders(timetableID: TimetableID) async throws -> [LectureReminder]

    /// Gets the reminder option for a specific lecture
    func getReminder(timetableID: TimetableID, lectureID: TimetableLectureID) async throws -> ReminderOption

    /// Updates the reminder option for a specific lecture
    func updateReminder(
        timetableID: TimetableID,
        lectureID: TimetableLectureID,
        option: ReminderOption
    ) async throws
        -> LectureReminder
}
