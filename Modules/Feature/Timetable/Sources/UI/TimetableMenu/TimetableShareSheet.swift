//
//  TimetableShareSheet.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import AppReviewPromptInterface
import Dependencies
import SwiftUI
import UIKit

struct TimetableShareSheet: UIViewControllerRepresentable {
    let timetableImage: TimetableImage
    @Dependency(\.appReviewService) private var appReviewService

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let fileURL = try? saveToPNG()
        context.coordinator.tempFileURL = fileURL
        let controller = UIActivityViewController(
            activityItems: [fileURL].compactMap { $0 },
            applicationActivities: nil
        )
        controller.completionWithItemsHandler = { [weak coordinator = context.coordinator] _, completed, _, _ in
            coordinator?.cleanupTempFile()
            guard completed else { return }
            Task {
                await appReviewService.requestReviewIfNeeded()
            }
        }
        return controller
    }

    func updateUIViewController(_: UIActivityViewController, context _: Context) {}

    static func dismantleUIViewController(_: UIActivityViewController, coordinator: Coordinator) {
        coordinator.cleanupTempFile()
    }

    private func saveToPNG() throws -> URL {
        guard let pngData = timetableImage.image.pngData() else {
            throw CocoaError(.fileWriteUnknown)
        }
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileName = "\(timetableImage.title).png"
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        try pngData.write(to: fileURL)
        return fileURL
    }

    class Coordinator {
        var tempFileURL: URL?
        func cleanupTempFile() {
            guard let url = tempFileURL else { return }
            try? FileManager.default.removeItem(at: url)
            tempFileURL = nil
        }
    }
}
