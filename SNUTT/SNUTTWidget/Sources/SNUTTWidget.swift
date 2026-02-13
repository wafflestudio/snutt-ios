//
//  SNUTTWidget.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import DependenciesAdditions
import MemberwiseInit
import SwiftUI
import ThemesInterface
import TimetableInterface
import TimetableUIComponents
import WidgetKit

struct TimelineProvider: AppIntentTimelineProvider {
    typealias Entry = TimetableEntry
    private let dataSource = SNUTTWidgetDataSource()

    func placeholder(in _: Context) -> Entry {
        Entry(
            date: Date(),
            configuration: ConfigurationAppIntent(),
            currentTimetable: dataSource.currentTimetable,
            timetableConfiguration: dataSource.timetableConfiguration,
            availableThemes: dataSource.availableThemes
        )
    }

    func snapshot(for configuration: ConfigurationAppIntent, in _: Context) async -> Entry {
        Entry(
            date: Date(),
            configuration: configuration,
            currentTimetable: dataSource.currentTimetable,
            timetableConfiguration: dataSource.timetableConfiguration,
            availableThemes: dataSource.availableThemes
        )
    }

    func timeline(for configuration: ConfigurationAppIntent, in _: Context) async -> Timeline<Entry> {
        let now = Date()
        var dates: [Date] = [now]
        let currentTimetable = dataSource.currentTimetable
        let timetableConfiguration = dataSource.timetableConfiguration
        let availableThemes = dataSource.availableThemes

        if let remainingLectureTimes = currentTimetable?.getRemainingLectureTimes(on: now, by: .startTime) {
            dates.append(contentsOf: remainingLectureTimes.map { $0.timePlace.toDates() }.flatMap { $0 })
        }

        dates = Array(Set(dates))

        let entries = dates.map {
            Entry(
                date: $0,
                configuration: configuration,
                currentTimetable: currentTimetable,
                timetableConfiguration: timetableConfiguration,
                availableThemes: availableThemes
            )
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
}

struct TimetableEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
    let currentTimetable: Timetable?
    let timetableConfiguration: TimetableConfiguration
    let availableThemes: [Theme]

    init(
        date: Date,
        configuration: ConfigurationAppIntent,
        currentTimetable: Timetable?,
        timetableConfiguration: TimetableConfiguration,
        availableThemes: [Theme]
    ) {
        self.date = date
        self.configuration = configuration
        self.currentTimetable = currentTimetable
        self.timetableConfiguration = timetableConfiguration
        self.availableThemes = availableThemes
    }

    func makeTimetablePainter() -> TimetablePainter {
        TimetablePainter(
            currentTimetable: currentTimetable,
            selectedLecture: nil,
            preferredTheme: nil,
            availableThemes: availableThemes,
            configuration: timetableConfiguration
        )
    }
}

struct SNUTTWidget: Widget {
    let kind: String = "SNUTTWidget"

    private var supportedFamilies: [WidgetFamily] {
        [
            .systemSmall,
            .systemMedium,
            .systemLarge,
            .systemExtraLarge,
            .accessoryRectangular,
            .accessoryInline,
            .accessoryCircular,
        ]
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
            timetableConfiguration: .init(),
            availableThemes: []
        ),
        TimetableEntry(
            date: .now,
            configuration: ConfigurationAppIntent(),
            currentTimetable: PreviewHelpers.preview(id: "1"),
            timetableConfiguration: .init(),
            availableThemes: []
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

#Preview("SystemLarge", as: .systemLarge) {
    SNUTTWidget()
} timeline: {
    for timeline in makePreviewTimeline() {
        timeline
    }
}
