//
//  SNUTTWidget.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import DependenciesAdditions
import MemberwiseInit
import SwiftUI
import TimetableInterface
import TimetableUIComponents
import WidgetKit

struct TimelineProvider: AppIntentTimelineProvider {
    typealias Entry = TimetableEntry
    private let dataSource = SNUTTWidgetDataSource()

    func placeholder(in _: Context) -> Entry {
        Entry(date: Date(),
              configuration: ConfigurationAppIntent(),
              currentTimetable: dataSource.currentTimetable,
              timetableConfiguration: dataSource.timetableConfiguration)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in _: Context) async -> Entry {
        Entry(date: Date(),
              configuration: configuration,
              currentTimetable: dataSource.currentTimetable,
              timetableConfiguration: dataSource.timetableConfiguration)
    }

    func timeline(for configuration: ConfigurationAppIntent, in _: Context) async -> Timeline<Entry> {
        let now = Date()
        var dates: [Date] = [now]
        let currentTimetable = dataSource.currentTimetable
        let timetableConfiguration = dataSource.timetableConfiguration

        if let remainingLectureTimes = currentTimetable?.getRemainingLectureTimes(on: now, by: .startTime) {
            dates.append(contentsOf: remainingLectureTimes.map { $0.timePlace.toDates() }.flatMap { $0 })
        }

        dates = Array(Set(dates))

        let entries = dates.map {
            Entry(date: $0,
                  configuration: configuration,
                  currentTimetable: currentTimetable,
                  timetableConfiguration: timetableConfiguration)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct TimetableEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let currentTimetable: (any Timetable)?
    let timetableConfiguration: TimetableConfiguration

    init(
        date: Date,
        configuration: ConfigurationAppIntent,
        currentTimetable: (any Timetable)?,
        timetableConfiguration: TimetableConfiguration
    ) {
        self.date = date
        self.configuration = configuration
        self.currentTimetable = currentTimetable
        self.timetableConfiguration = timetableConfiguration
    }

    func makeTimetablePainter() -> TimetablePainter {
        TimetablePainter(
            currentTimetable: currentTimetable,
            selectedLecture: nil,
            selectedTheme: .snutt,
            configuration: timetableConfiguration
        )
    }
}

struct SNUTTWidgetEntryView: View {
    var entry: TimelineProvider.Entry

    var body: some View {
        VStack {
            Text("Time:")
            Text(entry.date, style: .time)

            Text("Favorite Emoji:")
            Text(entry.configuration.favoriteEmoji)
        }
    }
}

struct SNUTTWidget: Widget {
    let kind: String = "SNUTTWidget"

    private var supportedFamilies: [WidgetFamily] {
        [.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge, .accessoryRectangular, .accessoryInline, .accessoryCircular]
    }

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: TimelineProvider()
        ) { entry in
            TimetableWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .contentMarginsDisabled()
        .supportedFamilies(supportedFamilies)
    }
}

func makePreviewTimeline() -> [TimetableEntry] {
    [
        TimetableEntry(
            date: .now,
            configuration: ConfigurationAppIntent(),
            currentTimetable: nil,
            timetableConfiguration: .init()
        ),
        TimetableEntry(
            date: .now,
            configuration: ConfigurationAppIntent(),
            currentTimetable: PreviewHelpers.preview(id: "1"),
            timetableConfiguration: .init()
        ),
    ]
}

#Preview("SystemSmall", as: .systemSmall) {
    SNUTTWidget()
} timeline: {
    for timeline in makePreviewTimeline() {
        timeline
    }
}

#Preview("SystemMedium", as: .systemMedium) {
    SNUTTWidget()
} timeline: {
    for timeline in makePreviewTimeline() {
        timeline
    }
}

#Preview("SystemExtraLarge", as: .systemExtraLarge) {
    SNUTTWidget()
} timeline: {
    for timeline in makePreviewTimeline() {
        timeline
    }
}
