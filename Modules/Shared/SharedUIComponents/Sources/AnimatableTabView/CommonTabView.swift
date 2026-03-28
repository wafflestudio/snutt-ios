//
//  CommonTabView.swift
//  SNUTT
//
//  Copyright © 2026 wafflestudio.com. All rights reserved.
//

import SwiftUI

public struct CommonTabView<T: TabItem>: View {
    @Binding var selectedTab: T
    let tabScenes: () -> [TabScene<T>]

    public init(selectedTab: Binding<T>, @TabSceneBuilder tabScenes: @escaping () -> [TabScene<T>]) {
        _selectedTab = selectedTab
        self.tabScenes = tabScenes
    }

    public var body: some View {
        SystemTabView(selectedTab: $selectedTab, tabScenes: tabScenes)
    }
}
