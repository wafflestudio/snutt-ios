//
//  SNUTTApp.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/03/19.
//

import SwiftUI

@main
struct SNUTTApp: App {
    @State private var selectedSceneId = 0

    let tabItems: [TabItem] = [
        TabItem(id: 0, view: AnyView(MyTimetableScene()), symbolName: "timetable"),
        TabItem(id: 1, view: AnyView(MyLectureListScene()), symbolName: "search"),
        TabItem(id: 2, view: AnyView(MyLectureListScene()), symbolName: "review"),
        TabItem(id: 3, view: AnyView(MyLectureListScene()), symbolName: "settings"),
    ]

    var body: some Scene {
        WindowGroup {
            // 임시 Entry Point
            TabView(selection: $selectedSceneId) {
                ForEach(tabItems) { tab in
                    NavigationView {
                        tab.view
                    }
                    .accentColor(Color(UIColor.label))
                    .tabItem {
                        Image(selectedSceneId == tab.id ? tab.onImageName : tab.offImageName)
                    }
                }
            }
            .onAppear {
                setTabBarStyle()
                setNavBarStyle()
            }
        }
    }

    /// Globally set the background color of the tab bar to white.
    private func setTabBarStyle() {
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = .white
        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }

    /// Globally set the background color of the nav bar to white.
    private func setNavBarStyle() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .white
        UINavigationBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    }
}

/// A simple wrapper struct that represents a tab view item.
struct TabItem: Identifiable {
    let id: Int
    let view: AnyView
    let symbolName: String

    var onImageName: String {
        "tab.\(symbolName).on"
    }

    var offImageName: String {
        "tab.\(symbolName).off"
    }
}
