//
//  SNUTTView.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/06/28.
//

import SwiftUI

struct SNUTTView: View {
    @State var selectedTab: TabType = .timetable
    let container: DIContainer

    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                TabScene(tabType: .timetable) {
                    MyTimetableScene(viewModel: .init(container: container))
                }
                TabScene(tabType: .search) {
                    MyLectureListScene(viewModel: .init(container: container))
                }
                TabScene(tabType: .review) {
                    ReviewScene(viewModel: .init(container: container))
                }
                TabScene(tabType: .settings) {
                    SettingScene(viewModel: .init(container: container))
                }
            }

            MenuSheetScene(viewModel: .init(container: container))
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
        SNUTTView(container: .preview)
    }
}
