//
//  SwiftUITimetableImageRenderer.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI
import ThemesInterface
import TimetableInterface
import TimetableUIComponents

struct SwiftUITimetableImageRenderer: TimetableImageRenderer {
    private enum Layout {
        static let aspectRatio: CGFloat = 1.5
    }

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
        guard
            let scene = UIApplication.shared.connectedScenes
                .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        else { throw RenderingError() }

        let screenWidth = scene.screen.bounds.width
        let timetableSize = CGSize(width: screenWidth, height: screenWidth * Layout.aspectRatio)
        let timetableView = TimetableForCapture(painter: painter, size: timetableSize)
            .frame(width: timetableSize.width, height: timetableSize.height)
            .background(Color(uiColor: .systemBackground))
            .environment(\.colorScheme, colorScheme)
        let renderer = ImageRenderer(content: timetableView)
        renderer.scale = scene.screen.scale
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
