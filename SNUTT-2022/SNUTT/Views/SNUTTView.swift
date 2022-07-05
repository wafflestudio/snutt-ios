//
//  SNUTTView.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/06/28.
//

import SwiftUI

struct SNUTTView: View {
    @State var selectedTab: TabType = .timetable
    let appState: AppState

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                TabScene(tabType: .timetable) {
                    MyTimetableScene(viewModel: .init(appState: appState))
                }
                TabScene(tabType: .search) {
                    SearchLectureScene(viewModel: .init(appState: appState))
                }
                TabScene(tabType: .review) {
                    ReviewScene(viewModel: .init(appState: appState))
                }
                TabScene(tabType: .settings) {
                    SettingScene(viewModel: .init(appState: appState))
                }
            }

            MenuSheetScene(viewModel: .init(appState: appState))
            FilterSheetScene(viewModel: .init(appState: appState))
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

enum TabType: String {
    case timetable
    case search
    case review
    case settings
}

struct SNUTTView_Previews: PreviewProvider {
    static var previews: some View {
        SNUTTView(appState: AppState())
    }
}
