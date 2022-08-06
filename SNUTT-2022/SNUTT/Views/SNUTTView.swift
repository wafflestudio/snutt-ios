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
    @ObservedObject var system: SystemState
    
    init(container: DIContainer) {
        self.container = container
        system = container.appState.system
    }
    
    var body: some View {
        ZStack {
            TabView(selection: $selectedTab) {
                TabScene(tabType: .timetable) {
                    TimetableScene(viewModel: .init(container: container))
                }
                TabScene(tabType: .search) {
                    SearchLectureScene(viewModel: .init(container: container))
                }
                TabScene(tabType: .review) {
                    ReviewScene(viewModel: .init(container: container))
                }
                TabScene(tabType: .settings) {
                    SettingScene(viewModel: .init(container: container))
                }
            }

            MenuSheetScene(viewModel: .init(container: container))
            FilterSheetScene(viewModel: .init(container: container))
        }
        .accentColor(Color(UIColor.label))
        .alert(system.errorContent?.errorTitle ?? "", isPresented: $system.isErrorAlertPresented, actions: {}) {
            Text(system.errorContent?.errorMessage ?? "")
        }
        .onAppear {
            setTabBarStyle()
            setNavBarStyle()
        }
        
        let _ = debugChanges()
    }

    /// Globally set the background color of the nav bar to white.
    private func setNavBarStyle() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = UIColor(STColor.navBackground)
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }

    /// Globally set the background color of the tab bar to white.
    private func setTabBarStyle() {
        let appearance = UITabBarAppearance()
        appearance.backgroundColor = UIColor(STColor.tabBackground)
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
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
