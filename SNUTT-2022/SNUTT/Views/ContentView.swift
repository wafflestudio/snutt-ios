//
//  ContentView.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/06/25.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var systemState = AppState.of.system

    var body: some View {
        TabView(selection: $systemState.selectedTab) {
            TabScene(tabType: .timetable) {
                MyTimetableScene()
            }
            TabScene(tabType: .search) {
                MyLectureListScene()
            }
            TabScene(tabType: .review) {
                ReviewScene()
            }
            TabScene(tabType: .settings) {
                SettingScene()
            }
        }
        .accentColor(Color(UIColor.label))
        .onAppear {
            setTabBarStyle()
            setNavBarStyle()
        }
        let _ = debugChanges()
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
