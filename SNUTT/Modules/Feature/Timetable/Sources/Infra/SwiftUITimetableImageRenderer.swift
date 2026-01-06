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
    ) async throws -> UIImage {
        let painter = TimetablePainter(
            currentTimetable: timetable,
            selectedLecture: nil,
            preferredTheme: nil,
            availableThemes: availableThemes,
            configuration: configuration
        )
        let screenSize = UIScreen.main.bounds.size
        let timetableView = TimetableForCapture(
            painter: painter,
            size: .init(width: screenSize.width, height: screenSize.width * 1.5)
        )
        .frame(width: screenSize.width, height: screenSize.height)
        .background(Color(uiColor: .systemBackground))
        .environment(\.colorScheme, colorScheme)
        let renderer = ImageRenderer(content: timetableView)
        renderer.scale = UIScreen.main.scale
        guard let image = renderer.uiImage else { throw RenderingError() }
        return image
    }

    struct RenderingError: Error {}
}

private struct TimetableForCapture: View {
    let painter: TimetablePainter
    let size: CGSize
    var body: some View {
        ZStack {
            let geometry = TimetableGeometry(size: size, safeAreaInsets: .init(horizontal: 0, vertical: 0))
            TimetableGridLayer(painter: painter, geometry: geometry)
                .frame(width: geometry.size.width, height: geometry.extendedContainerSize.height)
            TimetableBlocksLayer(painter: painter, geometry: geometry)
                .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}
