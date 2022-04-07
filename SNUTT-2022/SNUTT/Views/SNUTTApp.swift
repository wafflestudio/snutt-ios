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
    
    let scenes: [SceneItem] = [
        SceneItem(id: 0, view: AnyView(MyTimetableListScene()), symbolName: "timetable"),
        SceneItem(id: 1, view: AnyView(MyTimetableListScene()), symbolName: "search"),
        SceneItem(id: 2, view: AnyView(MyTimetableListScene()), symbolName: "settings"),
        SceneItem(id: 3, view: AnyView(MyTimetableListScene()), symbolName: "settings"),
    ]
    
    var body: some Scene {
        WindowGroup {
            // 임시 Entry Point
            NavigationView {
                TabView(selection: $selectedSceneId) {
                    ForEach(scenes) { sceneItem in
                        sceneItem.view
                            .tabItem {
                                selectedSceneId == sceneItem.id ? Image(sceneItem.onImageName) : Image(sceneItem.offImageName)
                            }
                    }
                }
                .onAppear {
                    setTabBarStyle()
                }
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
}

/// A simple wrapper struct that represents a tab view item.
struct SceneItem: Identifiable {
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
