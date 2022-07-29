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
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: SNUTTWidgetProvider()) { entry in
            TimetableWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("주간 시간표")
        .description("주간 시간표입니다.")
        .supportedFamilies([.systemLarge])
    }
}
