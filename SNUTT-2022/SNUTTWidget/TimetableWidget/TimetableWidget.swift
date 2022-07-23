//
//  TimetableWidget.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/23.
//

import SwiftUI
import WidgetKit

struct TimetableWidget: Widget {
    let kind: String = "TimetableWidget"
    
    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: TimetableWidgetProvider()) { entry in
            TimetableWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("주간 시간표")
        .description("주간 시간표입니다.")
        .supportedFamilies([.systemLarge])
    }
}

struct TimetableEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    let currentTimetable: Timetable?
    
    init(date:Date, configuration: ConfigurationIntent, currentTimetable: Timetable? = nil) {
        self.date = date
        self.configuration = configuration
        self.currentTimetable = currentTimetable
    }
}

struct TimetableWidgetProvider: IntentTimelineProvider {
    typealias Entry = TimetableEntry
    
    func placeholder(in context: Context) -> Entry {
        Entry(date: Date(), configuration: ConfigurationIntent(), currentTimetable: getCurrentTimetable())
    }
    
    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Entry) -> ()) {
        let entry = Entry(date: Date(), configuration: configuration, currentTimetable: getCurrentTimetable())
        completion(entry)
    }
    
    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
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
        guard let userDefaults = UserDefaults(suiteName: "group.com.wafflestudio.snutt-2022") else { return nil }
        guard let data = userDefaults.data(forKey: "currentTimetable") else { return nil }
        guard let dto = try? JSONDecoder().decode(TimetableDto.self, from: data) else { return nil }
        print(dto)
        return Timetable(from: dto)
    }
}
