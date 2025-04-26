//
//  TimetableUIProvidable.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import Dependencies
import SwiftUI

@MainActor
public protocol TimetableUIProvidable: Sendable {
    func lectureDetailRow(type: DetailLabelType, lecture: Lecture) -> AnyView
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
