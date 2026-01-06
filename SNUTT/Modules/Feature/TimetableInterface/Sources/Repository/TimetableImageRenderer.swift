//
//  TimetableImageRenderer.swift
//  TimetableInterface
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Dependencies
import Spyable
import SwiftUI
import ThemesInterface
import UIKit

@Spyable
public protocol TimetableImageRenderer: Sendable {
    func render(
        timetable: Timetable,
        configuration: TimetableConfiguration,
        availableThemes: [Theme],
        colorScheme: ColorScheme
    ) async throws -> UIImage
}

public enum TimetableImageRendererKey: TestDependencyKey {
    public static let testValue: any TimetableImageRenderer = {
        let spy = TimetableImageRendererSpy()
        spy.renderTimetableConfigurationAvailableThemesColorSchemeReturnValue = UIImage()
        return spy
    }()
}

extension DependencyValues {
    public var timetableImageRenderer: any TimetableImageRenderer {
        get { self[TimetableImageRendererKey.self] }
        set { self[TimetableImageRendererKey.self] = newValue }
    }
}
