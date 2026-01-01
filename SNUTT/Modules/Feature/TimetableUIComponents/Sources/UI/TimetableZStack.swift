//
//  TimetableZStack.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Dependencies
import MemberwiseInit
import SwiftUI
import ThemesInterface
import TimetableInterface

public struct TimetableZStack: View {
    let painter: TimetablePainter

    public init(painter: TimetablePainter) {
        self.painter = painter
    }

    public var body: some View {
        GeometryReader { reader in
            let geometry = TimetableGeometry(reader)
            ScrollView {
                ZStack(alignment: .top) {
                    TimetableGridLayer(painter: painter, geometry: geometry)
                        .frame(width: geometry.size.width, height: geometry.extendedContainerSize.height)
                    TimetableBlocksLayer(painter: painter, geometry: geometry)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }
                .animation(.defaultSpring, value: painter.currentTimetable?.id)
                .animation(.defaultSpring, value: painter.selectedLecture?.id)
            }
            .ignoresSafeArea(edges: .bottom)
            .scrollBounceBehavior(.basedOnSize)
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: Preview

@MainActor func makePreviewPainter() -> TimetablePainter {
    let timetable: Timetable = PreviewHelpers.preview(id: "1")
    return TimetablePainter(
        currentTimetable: timetable,
        selectedLecture: nil,
        preferredTheme: nil,
        availableThemes: [],
        configuration: TimetableConfiguration()
    )
}

#Preview {
    TimetableZStack(painter: makePreviewPainter())
}
