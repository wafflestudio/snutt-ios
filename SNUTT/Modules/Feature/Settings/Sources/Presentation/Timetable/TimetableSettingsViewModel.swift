import Dependencies
import FoundationUtility
import Observation
import TimetableInterface

@MainActor
@Observable
final class TimetableSettingsViewModel {
    @ObservationIgnored
    @Dependency(\.timetableLocalRepository) private var timetableLocalRepository

    private(set) var timetable: Timetable?
    var configuration: TimetableConfiguration = .init() {
        didSet {
            timetableLocalRepository.storeTimetableConfiguration(configuration)
        }
    }

    func loadInitialTimetable() {
        timetable = try? timetableLocalRepository.loadSelectedTimetable()
        configuration = timetableLocalRepository.loadTimetableConfiguration()
    }

    func toggleWeekday(weekday: Weekday) {
        if let existingIndex = configuration.visibleWeeks.firstIndex(of: weekday) {
            configuration.visibleWeeks.remove(at: existingIndex)
        } else {
            configuration.visibleWeeks.append(weekday)
        }
    }

    var visibleWeekdaysPreview: String {
        configuration.visibleWeeks.sorted { $0.rawValue < $1.rawValue }
            .map { $0.shortSymbol }.joined(separator: " ")
    }

}
