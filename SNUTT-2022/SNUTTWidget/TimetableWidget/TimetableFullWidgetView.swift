//
//  TimetableFullWidgetView.swift
//  SNUTTWidgetExtension
//
//  Created by 박신홍 on 2023/03/18.
//

import SwiftUI


/// Just a simple wrapper of `TimetableZStack` for consistency.
struct TimetableFullWidgetView: View {
    var entry: SNUTTWidgetProvider.Entry
    var body: some View {
        TimetableZStack(current: entry.currentTimetable, config: entry.timetableConfig)
    }
}

