//
//  LectureDiaryUIProvidable.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies
import Spyable
import SwiftUI

@MainActor
public protocol LectureDiaryUIProvidable: Sendable {
    func makeLectureDiaryListView() -> AnyView
}

private struct EmptyLectureDiaryUIProvider: LectureDiaryUIProvidable {
    func makeLectureDiaryListView() -> AnyView {
        AnyView(Text("LectureDiaryUIProvider not found."))
    }
}

public enum LectureDiaryUIProviderKey: TestDependencyKey {
    public static let testValue: any LectureDiaryUIProvidable = EmptyLectureDiaryUIProvider()
}

extension DependencyValues {
    fileprivate var lectureDiaryUIProvider: any LectureDiaryUIProvidable {
        get { self[LectureDiaryUIProviderKey.self] }
        set { self[LectureDiaryUIProviderKey.self] = newValue }
    }
}

extension EnvironmentValues {
    public var lectureDiaryUIProvider: any LectureDiaryUIProvidable {
        withDependencies {
            $0.context = .live
        } operation: {
            Dependency(\.lectureDiaryUIProvider).wrappedValue
        }
    }
}
