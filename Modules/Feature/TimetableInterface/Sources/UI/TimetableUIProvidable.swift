//
//  TimetableUIProvidable.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies
import SwiftUI
import ThemesInterface

@MainActor
public protocol TimetableUIProvidable: Sendable {
    func lectureDetailRow(type: DetailLabelType, lecture: Lecture) -> AnyView
    func timetableView(
        timetable: Timetable?,
        configuration: TimetableConfiguration,
        preferredTheme: Theme?,
        availableThemes: [Theme]
    ) -> AnyView
    func makeLectureDetailPreview(lecture: Lecture, quarter: Quarter, options: LectureDetailPreviewOptions) -> AnyView
    func makeLectureReminderScene() -> AnyView
}

public enum DetailLabelType: CaseIterable {
    case department
    case time
    case place
    case remark
}

private struct EmptyTimetableUIProvider: TimetableUIProvidable {
    func lectureDetailRow(type _: DetailLabelType, lecture _: Lecture) -> AnyView {
        AnyView(Text("Empty LectureDetailRow"))
    }

    func timetableView(
        timetable _: Timetable?,
        configuration _: TimetableConfiguration,
        preferredTheme _: Theme?,
        availableThemes _: [Theme]
    ) -> AnyView {
        AnyView(Text("Empty TimetableView"))
    }

    func makeLectureDetailPreview(
        lecture _: Lecture,
        quarter _: Quarter,
        options _: LectureDetailPreviewOptions
    ) -> AnyView {
        AnyView(Text("Empty LectureDetailPreview"))
    }

    func makeLectureReminderScene() -> AnyView {
        AnyView(Text("Empty LectureReminderScene"))
    }
}

public enum TimetableUIProviderKey: TestDependencyKey {
    public static let testValue: any TimetableUIProvidable = EmptyTimetableUIProvider()
}

extension DependencyValues {
    fileprivate var timetableUIProvider: any TimetableUIProvidable {
        get { self[TimetableUIProviderKey.self] }
        set { self[TimetableUIProviderKey.self] = newValue }
    }
}

extension EnvironmentValues {
    public var timetableUIProvider: any TimetableUIProvidable {
        withDependencies {
            $0.context = .live
        } operation: {
            Dependency(\.timetableUIProvider).wrappedValue
        }
    }
}

extension EnvironmentValues {
    @Entry public var lectureTapAction: LectureTapAction = .init(action: nil)
}

@MainActor
public struct LectureTapAction {
    public let action: (@MainActor (Lecture) -> Void)?
    public nonisolated init(action: (@MainActor (Lecture) -> Void)?) {
        self.action = action
    }

    public func callAsFunction(lecture: Lecture) {
        action?(lecture)
    }
}
