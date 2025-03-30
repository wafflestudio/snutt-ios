//
//  TimetableZStack.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import MemberwiseInit
import SwiftUI
import TimetableInterface

public struct TimetableZStack: View {
    let painter: TimetablePainter

    public init(painter: TimetablePainter) {
        self.painter = painter
    }

    public var body: some View {
        ZStack {
            TimetableGridLayer(painter: painter)
            TimetableBlocksLayer(painter: painter)
        }
        .animation(.defaultSpring, value: painter.currentTimetable?.id)
        .animation(.defaultSpring, value: painter.selectedLecture?.id)
    }
}

// MARK: Preview

@MainActor func makePreviewPainter() -> TimetablePainter {
    let timetable: Timetable = PreviewHelpers.preview(id: "1")
    return TimetablePainter(
        currentTimetable: timetable,
        selectedLecture: nil,
        selectedTheme: .snutt,
        configuration: TimetableConfiguration()
    )
}

#Preview {
    TimetableZStack(painter: makePreviewPainter())
}
