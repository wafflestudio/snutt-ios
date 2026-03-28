//
//  TabItem.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI
import UIKit

public protocol TabItem: Hashable {
    var title: String { get }
    var isSearchRole: Bool { get }
    func image(isSelected: Bool) -> UIImage
    func viewIndex() -> Int
}

@MainActor
@resultBuilder
public enum TabSceneBuilder {
    public static func buildBlock<T>(_ components: TabScene<T>...) -> [TabScene<T>] {
        return components
    }
}

@MainActor
public struct TabScene<T: TabItem> {
    let tabItem: T
    let rootView: AnyView?

    public init<Content>(tabItem: T, rootView: Content) where Content: View {
        self.tabItem = tabItem
        self.rootView = AnyView(rootView)
    }

    public init(tabItem: T) {
        self.tabItem = tabItem
        rootView = nil
    }
}
