//
//  WidgetReloaderDependency.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import Dependencies
import WidgetKit

public struct WidgetReloader: Sendable {
    public let reloadAll: @Sendable () -> Void

    public init(reloadAll: @escaping @Sendable () -> Void) {
        self.reloadAll = reloadAll
    }
}

public enum WidgetReloaderKey: DependencyKey {
    public static let liveValue: WidgetReloader = .init(
        reloadAll: { WidgetCenter.shared.reloadAllTimelines() }
    )

    public static let testValue: WidgetReloader = .init(reloadAll: {})
}

extension DependencyValues {
    public var widgetReloader: WidgetReloader {
        get { self[WidgetReloaderKey.self] }
        set { self[WidgetReloaderKey.self] = newValue }
    }
}
