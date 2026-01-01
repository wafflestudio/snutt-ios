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
    let geometry: TimetableGeometry

    public init(painter: TimetablePainter, geometry: TimetableGeometry) {
        self.painter = painter
        self.geometry = geometry
    }

    public var body: some View {
        ForEach(painter.currentTimetable?.lectures ?? [], id: \.id) { lecture in
            TimetableLectureBlockGroup(painter: painter, lecture: lecture, geometry: geometry)
        }

        if let selectedLecture = painter.selectedLecture {
            TimetableLectureBlockGroup(painter: painter, lecture: selectedLecture, geometry: geometry)
        }
    }
}

#Preview {
    let painter = makePreviewPainter()
    let geometry = TimetableGeometry(size: CGSize(width: 375, height: 800), safeAreaInsets: EdgeInsets())
    return TimetableBlocksLayer(painter: painter, geometry: geometry)
}
