//
//  SNUTTWidgetProvider.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/24.
//

import WidgetKit

struct SNUTTWidgetProvider: IntentTimelineProvider {
    typealias Entry = TimetableEntry

    var userDefaultsRepository: UserDefaultsRepositoryProtocol = UserDefaultsRepository(storage: .shared)

    func placeholder(in _: Context) -> Entry {
        Entry(date: Date(), configuration: ConfigurationIntent(), currentTimetable: getCurrentTimetable())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in _: Context, completion: @escaping (Entry) -> Void) {
        let entry = Entry(date: Date(), configuration: configuration, currentTimetable: getCurrentTimetable())
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in _: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        var entries: [Entry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = Entry(date: entryDate, configuration: configuration, currentTimetable: getCurrentTimetable())
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }

    func getCurrentTimetable() -> Timetable? {
        guard let dto = userDefaultsRepository.get(TimetableDto.self, key: .currentTimetable) else { return nil }
        return Timetable(from: dto)
    }
}

struct TimetableEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let currentTimetable: Timetable?

    init(date: Date, configuration: ConfigurationIntent, currentTimetable: Timetable? = nil) {
        self.date = date
        self.configuration = configuration
        self.currentTimetable = currentTimetable
    }
}
