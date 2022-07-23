//
//  TimetableWidgetEntryView.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/07/23.
//

import SwiftUI
import WidgetKit

struct TimetableWidgetEntryView: View {
    var entry: TimetableWidgetProvider.Entry

    var config: TimetableConfiguration = {
        var config = TimetableConfiguration()
        config.maxHour = 18
        return config
    }()

    var body: some View {
        TimetableZStack(current: entry.currentTimetable, config: config)
    }
}

struct TimetableWidgetEntryView_Previews: PreviewProvider {
    static var previews: some View {
        TimetableWidgetEntryView(entry: TimetableEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemLarge))
    }
}
