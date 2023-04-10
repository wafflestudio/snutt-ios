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

    private var supportedFamilies: [WidgetFamily] {
        var supported: [WidgetFamily] = [.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge]
        if #available(iOS 16.0, watchOS 9.0, *) {
            supported.append(contentsOf: [.accessoryRectangular, .accessoryInline, .accessoryCircular])
        }
        return supported
    }

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: SNUTTWidgetProvider()) { entry in
            TimetableWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("WEEKLY_TIMETABLE".localized)
        .description("주간 시간표입니다.")
        .supportedFamilies(supportedFamilies)
    }
}
