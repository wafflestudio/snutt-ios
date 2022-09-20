//
//  SNUTTView.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/06/28.
//

import Combine
import SwiftUI

struct SNUTTView: View {
    @ObservedObject var viewModel: ViewModel
    @State private var selectedTab: TabType = .timetable

    /// Required to synchronize between two navigation bar heights: `TimetableScene` and `SearchLectureScene`.
    @State private var navigationBarHeight: CGFloat = 0

    var body: some View {
        let selected = Binding {
            selectedTab
        } set: {
            [previous = selectedTab] current in
            if previous == current && current == .review {
                viewModel.resetReviewId()
            }
            selectedTab = current
        }
        
        ZStack {
            MainTabScene(container: viewModel.container,
                         navigationBarHeight: $navigationBarHeight,
                         selected: selected)
            if selectedTab == .timetable {
                MenuSheetScene(viewModel: .init(container: viewModel.container))
            }
            if selectedTab == .search {
                FilterSheetScene(viewModel: .init(container: viewModel.container))
            }
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
        @Published private var _shouldReloadWebView = false

        override init(container: DIContainer) {
            super.init(container: container)
            appState.system.$errorContent.assign(to: &$errorContent)
            appState.system.$isErrorAlertPresented.assign(to: &$isErrorAlertPresented)
            appState.webView.$reloadWebView
                .assign(to: &$_shouldReloadWebView)
        }

        var errorTitle: String {
            (appState.system.errorContent ?? .UNKNOWN_ERROR).errorTitle
        }

        var errorMessage: String {
            (appState.system.errorContent ?? .UNKNOWN_ERROR).errorMessage
        }
        
        func resetReviewId() {
            services.reviewService.resetReviewId()
        }
    }
}

private struct MainTabScene: View {
    let container: DIContainer
    @Binding var navigationBarHeight: CGFloat
    @Binding var selected: TabType

    var body: some View {
        TabView(selection: $selected) {
            TabScene(tabType: .timetable) {
                TimetableScene(viewModel: .init(container: viewModel.container))
                    .background(NavigationBarReader { navbar in
                        DispatchQueue.main.async {
                            navigationBarHeight = navbar.frame.height
                        }
                    })
            }
            TabScene(tabType: .search) {
                SearchLectureScene(viewModel: .init(container: container), navigationBarHeight: navigationBarHeight)
            }
            TabScene(tabType: .review) {
                ReviewScene(viewModel: .init(container: container))
            }
            TabScene(tabType: .settings) {
                SettingScene(viewModel: .init(container: container))
            }
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

// TODO: move elsewhere if needed
struct NavigationBarReader: UIViewControllerRepresentable {
    var callback: (UINavigationBar) -> Void
    private let proxyController = ViewController()

    func makeUIViewController(context _: UIViewControllerRepresentableContext<NavigationBarReader>) -> UIViewController {
        proxyController.callback = callback
        return proxyController
    }

    func updateUIViewController(_: UIViewController, context _: UIViewControllerRepresentableContext<NavigationBarReader>) {}

    private class ViewController: UIViewController {
        var callback: (UINavigationBar) -> Void = { _ in }

        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            if let navBar = navigationController {
                callback(navBar.navigationBar)
            }
        }
    }
}
