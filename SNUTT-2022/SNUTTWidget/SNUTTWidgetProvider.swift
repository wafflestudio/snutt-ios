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

    var currentTimetable: Timetable? {
        guard let dto = userDefaultsRepository.get(TimetableDto.self, key: .currentTimetable) else { return nil }
        return Timetable(from: dto)
    }

    var timetableConfig: TimetableConfiguration {
        userDefaultsRepository.get(TimetableConfiguration.self, key: .timetableConfig, defaultValue: TimetableConfiguration())
    }

    func placeholder(in _: Context) -> Entry {
        Entry(date: Date(), configuration: ConfigurationIntent(), currentTimetable: currentTimetable, timetableConfig: timetableConfig)
    }

    func getSnapshot(for configuration: ConfigurationIntent, in _: Context, completion: @escaping (Entry) -> Void) {
        let entry = Entry(date: Date(), configuration: configuration, currentTimetable: currentTimetable, timetableConfig: timetableConfig)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in _: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let now = Date()
        var dates: [Date] = [now]

        if let remainingLectureTimes = currentTimetable?.getRemainingLectureTimes(on: now) {
            dates.append(contentsOf: remainingLectureTimes.map({ $0.timePlace.toDates() }).flatMap({ $0 }))
        }

        let entries = dates.map {
            Entry(date: $0, configuration: configuration, currentTimetable: currentTimetable, timetableConfig: timetableConfig)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct TimetableEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let currentTimetable: Timetable?
    let timetableConfig: TimetableConfiguration

    init(date: Date, configuration: ConfigurationIntent, currentTimetable: Timetable?, timetableConfig: TimetableConfiguration) {
        self.date = date
        self.configuration = configuration
        self.currentTimetable = currentTimetable
        self.timetableConfig = timetableConfig
    }
}
