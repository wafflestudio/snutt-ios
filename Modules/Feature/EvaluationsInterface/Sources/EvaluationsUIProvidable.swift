//
//  EvaluationsUIProvidable.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies
import SwiftUI

@MainActor
public protocol EvaluationsUIProvidable: Sendable {
    func makeEvaluationsScene(for evLectureID: Int) -> AnyView
}

private struct EmptyEvaluationsUIProvider: EvaluationsUIProvidable {
    func makeEvaluationsScene(for evLectureID: Int) -> AnyView {
        AnyView(Text("EvaluationsUIProvider not found."))
    }
}

public enum EvaluationsUIProviderKey: TestDependencyKey {
    public static let testValue: any EvaluationsUIProvidable = EmptyEvaluationsUIProvider()
}

extension DependencyValues {
    public var evaluationsUIProvider: any EvaluationsUIProvidable {
        get { self[EvaluationsUIProviderKey.self] }
        set { self[EvaluationsUIProviderKey.self] = newValue }
    }
}

extension EnvironmentValues {
    public var evaluationsUIProvider: any EvaluationsUIProvidable {
        withDependencies {
            $0.context = .live
        } operation: {
            Dependency(\.evaluationsUIProvider).wrappedValue
        }
    }
}
