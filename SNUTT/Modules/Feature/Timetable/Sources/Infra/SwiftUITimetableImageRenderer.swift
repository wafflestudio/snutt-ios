//
//  SwiftUITimetableImageRenderer.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI
import ThemesInterface
import TimetableInterface
import TimetableUIComponents

struct SwiftUITimetableImageRenderer: TimetableImageRenderer {
    @MainActor
    func render(
        timetable: Timetable,
        configuration: TimetableConfiguration,
        availableThemes: [Theme],
        colorScheme: ColorScheme
    ) async throws -> Data {
        let painter = TimetablePainter(
            currentTimetable: timetable,
            selectedLecture: nil,
            preferredTheme: nil,
            availableThemes: availableThemes,
            configuration: configuration
        )
        let timetableView = TimetableZStack(painter: painter)
            .background(Color(uiColor: .systemBackground))
            .environment(\.colorScheme, colorScheme)
        let renderer = ImageRenderer(content: timetableView)
        renderer.scale = 3.0
        let screenSize = UIScreen.main.bounds.size
        renderer.proposedSize = .init(width: screenSize.width, height: screenSize.height)
        guard let pngData = renderer.uiImage?.pngData() else { throw RenderingError() }
        return pngData
    }

    struct RenderingError: Error {}
}
