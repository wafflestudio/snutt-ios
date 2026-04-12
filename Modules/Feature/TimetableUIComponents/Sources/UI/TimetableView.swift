//
//  TimetableView.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies
import MemberwiseInit
import SwiftUI
import ThemesInterface
import TimetableInterface

public struct TimetableView: View {
    let painter: TimetablePainter

    public init(painter: TimetablePainter) {
        self.painter = painter
    }

    public var body: some View {
        GeometryReader { reader in
            let geometry = TimetableGeometry(reader)
            ScrollView {
                ZStack(alignment: .topLeading) {
                    TimetableGridLayer(painter: painter, geometry: geometry)
                        .frame(
                            width: geometry.extendedContainerSize.width,
                            height: geometry.extendedContainerSize.height
                        )
                    TimetableBlocksLayer(painter: painter, geometry: geometry)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .padding(.leading, geometry.safeAreaInsets.leading)
                }
                .animation(.defaultSpring, value: painter.currentTimetable?.id)
                .animation(.defaultSpring, value: painter.selectedLecture?.id)
            }
            .withResponsiveTouch()
            .ignoresSafeArea(edges: [.bottom, .horizontal])
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
    TimetableView(painter: makePreviewPainter())
}
