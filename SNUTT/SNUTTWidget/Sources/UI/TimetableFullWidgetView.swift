//
//  TimetableFullWidgetView.swift
//  SNUTTWidgetExtension
//
//  Created by 박신홍 on 2023/03/18.
//

import SwiftUI
import TimetableUIComponents

/// Just a simple wrapper of `TimetableZStack` for consistency.
struct TimetableFullWidgetView: View {
    var entry: TimelineProvider.Entry
    var body: some View {
        TimetableZStack(painter: entry.makeTimetablePainter())
    }
}
