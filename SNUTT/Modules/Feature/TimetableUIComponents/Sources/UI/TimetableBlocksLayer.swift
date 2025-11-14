//
//  TimetableBlocksLayer.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import SwiftUI
import TimetableInterface

public struct TimetableBlocksLayer: View {
    public let painter: TimetablePainter

    public init(painter: TimetablePainter) {
        self.painter = painter
    }

    public var body: some View {
        ForEach(painter.currentTimetable?.lectures ?? [], id: \.id) { lecture in
            TimetableLectureBlockGroup(painter: painter, lecture: lecture)
        }

        if let selectedLecture = painter.selectedLecture {
            TimetableLectureBlockGroup(painter: painter, lecture: selectedLecture)
        }
    }
}

#Preview {
    TimetableBlocksLayer(painter: makePreviewPainter())
}
