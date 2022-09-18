//
//  SNUTTView.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/06/28.
//

import Combine
import SwiftUI

struct SNUTTView: View {
    @State private var selectedTab: TabType = .timetable
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        ZStack {
            MainTabScene(viewModel: .init(container: viewModel.container))
            MenuSheetScene(viewModel: .init(container: viewModel.container))
            FilterSheetScene(viewModel: .init(container: viewModel.container))
        }
        .accentColor(Color(UIColor.label))
        .alert(viewModel.errorTitle, isPresented: $viewModel.isErrorAlertPresented, actions: {}) {
            Text(viewModel.errorMessage)
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

extension SNUTTView {
    class ViewModel: BaseViewModel, ObservableObject {
        @Published var isErrorAlertPresented = false
        @Published var errorContent: STError? = nil

        override init(container: DIContainer) {
            super.init(container: container)
            appState.system.$errorContent.assign(to: &$errorContent)
            appState.system.$isErrorAlertPresented.assign(to: &$isErrorAlertPresented)
        }

        var errorTitle: String {
            (appState.system.errorContent ?? .UNKNOWN_ERROR).errorTitle
        }

        var errorMessage: String {
            (appState.system.errorContent ?? .UNKNOWN_ERROR).errorMessage
        }
    }
}

private struct MainTabScene: View {
    @ObservedObject var viewModel: MainTabViewModel

    var body: some View {
        let selected = Binding {
            viewModel.selected
        } set: {
            [previous = viewModel.selected] current in
            if previous == .review && current == .review {
                viewModel.resetDetailId()
            }
            viewModel.selected = current
        }

        TabView(selection: selected) {
            TabScene(tabType: .timetable) {
                TimetableScene(viewModel: .init(container: viewModel.container))
            }
            TabScene(tabType: .search) {
                SearchLectureScene(viewModel: .init(container: viewModel.container))
            }
            TabScene(tabType: .review) {
                ReviewScene(viewModel: .init(container: viewModel.container))
            }
            TabScene(tabType: .settings) {
                SettingScene(viewModel: .init(container: viewModel.container))
            }
        }
    }

    final class MainTabViewModel: BaseViewModel, ObservableObject {
        @Published var selectedTab: TabType = .timetable
        private var bag = Set<AnyCancellable>()

        override init(container: DIContainer) {
            super.init(container: container)

            // TODO: fix this
            container.appState.tab.$selected
                .assign(to: &$selectedTab)
        }

        var selected: TabType {
            get { selectedTab }
            set { setSelectedTab(newValue) }
        }

        func resetDetailId() {
            reviewService.setDetailId("")
        }

        func setSelectedTab(_ tab: TabType) {
            reviewService.setSelectedTab(tab)
        }

        private var reviewService: ReviewServiceProtocol {
            services.reviewService
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
        SNUTTView(viewModel: .init(container: .preview))
    }
}
