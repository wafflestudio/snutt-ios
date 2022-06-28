//
//  SNUTTApp.swift
//  SNUTT
//
//  Created by Jinsup Keum on 2022/03/19.
//

import SwiftUI

@main
struct SNUTTApp: App {
    var appState = AppState()
    @State var selectedTab: SelectedTab = .timetable
    
    enum SelectedTab {
        case timetable
        case search
        case review
        case settings
    }

    var body: some Scene {
        let tabItems: [TabItem] = [
            TabItem(id: .timetable, view: AnyView(MyTimetableScene(viewModel: TimetableViewModel(appState: appState))), symbolName: .timetable),
            TabItem(id: .search, view: AnyView(MyLectureListScene()), symbolName: .search),
            TabItem(id: .review, view: AnyView(ReviewScene(viewModel: ReviewViewModel(appState: appState))), symbolName: .review),
            TabItem(id: .settings, view: AnyView(SettingScene(viewModel: SettingViewModel(appState: appState))), symbolName: .settings),
        ]

        WindowGroup {
            // 임시 Entry Point
            TabView(selection: $selectedTab) {
                ForEach(tabItems) { tab in
                    NavigationView {
                        tab.view
                    }
                    .accentColor(Color(UIColor.label))
                    .tabItem {
                        Image(selectedTab == tab.id ? tab.onImageName : tab.offImageName)
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
    
    /// A simple wrapper struct that represents a tab view item.
    struct TabItem: Identifiable {
        enum SymbolName: String {
            case timetable
            case search
            case review
            case settings
        }

        let id: SelectedTab
        let view: AnyView
        let symbolName: SymbolName

        var onImageName: String {
            "tab.\(symbolName.rawValue).on"
        }

        var offImageName: String {
            "tab.\(symbolName.rawValue).off"
        }
    }
}

extension View {
    func debugChanges() {
        if #available(iOS 15.0, *) {
            let _ = Self._printChanges()
        }
    }
}
