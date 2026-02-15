//
//  ReviewsUIProvidable.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies
import SwiftUI

@MainActor
public protocol ReviewsUIProvidable: Sendable {
    func makeReviewsScene(for evLectureID: Int) -> AnyView
}

private struct EmptyReviewsUIProvider: ReviewsUIProvidable {
    func makeReviewsScene(for evLectureID: Int) -> AnyView {
        AnyView(Text("ReviewsUIProvider not found."))
    }
}

public enum ReviewsUIProviderKey: TestDependencyKey {
    public static let testValue: any ReviewsUIProvidable = EmptyReviewsUIProvider()
}

extension DependencyValues {
    public var reviewsUIProvider: any ReviewsUIProvidable {
        get { self[ReviewsUIProviderKey.self] }
        set { self[ReviewsUIProviderKey.self] = newValue }
    }
}

extension EnvironmentValues {
    public var reviewsUIProvider: any ReviewsUIProvidable {
        withDependencies {
            $0.context = .live
        } operation: {
            Dependency(\.reviewsUIProvider).wrappedValue
        }
    }
}
