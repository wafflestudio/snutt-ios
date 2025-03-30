//
//  TimetableUIProvidable.swift
//  SNUTT
//
//  Copyright © 2025 wafflestudio.com. All rights reserved.
//

import SwiftUI
import Dependencies

@MainActor
public protocol TimetableUIProvidable: Sendable {
    func lectureDetailRow(type: DetailLabelType, lecture: any Lecture) -> AnyView
}

public enum DetailLabelType: CaseIterable {
    case department
    case time
    case place
    case remark
}

struct EmptyTimetableUIProvider: TimetableUIProvidable {
    func lectureDetailRow(type: DetailLabelType, lecture: any Lecture) -> AnyView {
        AnyView(Text("Empty LectureDetailRow"))
    }
}

public enum TimetableUIProviderKey: TestDependencyKey {
    public static let testValue: any TimetableUIProvidable = EmptyTimetableUIProvider()
}

extension DependencyValues {
    var timetableUIProvider: any TimetableUIProvidable {
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
