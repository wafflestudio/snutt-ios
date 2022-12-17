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

    private var selected: Binding<TabType> {
        Binding<TabType> {
            selectedTab
        } set: {
            [previous = selectedTab] current in
            if previous == current, current == .review {
                viewModel.reloadReviewWebView()
            }
            selectedTab = current
        }
    }

    var body: some View {
        ZStack {
            if !viewModel.isAuthenticated {
                NavigationView {
                    OnboardScene(viewModel: .init(container: viewModel.container))
                }
            } else {
                TabView(selection: selected) {
                    TabScene(tabType: .timetable) {
                        TimetableScene(viewModel: .init(container: viewModel.container))
                            .background(NavigationBarReader { navbar in
                                DispatchQueue.main.async {
                                    navigationBarHeight = navbar.frame.height
                                }
                            })
                    }
                    TabScene(tabType: .search) {
                        SearchLectureScene(viewModel: .init(container: viewModel.container), navigationBarHeight: navigationBarHeight)
                    }
                    TabScene(tabType: .review) {
                        ReviewScene(viewModel: .init(container: viewModel.container), webViewEventSignal: viewModel.reviewEventSignal)
                    }
                    TabScene(tabType: .settings) {
                        SettingScene(viewModel: .init(container: viewModel.container))
                    }
                }
                .onAppear {
                    selectedTab = .timetable
                }
                if selectedTab == .timetable {
                    MenuSheetScene(viewModel: .init(container: viewModel.container))
                }
                if selectedTab == .search {
                    FilterSheetScene(viewModel: .init(container: viewModel.container))
                }
                PopupScene(viewModel: .init(container: viewModel.container))
            }
            LectureTimeSheetScene(viewModel: .init(container: viewModel.container))
        }
        .animation(.easeOut, value: viewModel.accessToken)
        .preferredColorScheme(viewModel.preferredColorScheme)
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
        @Published var accessToken: String? = nil
        @Published var preferredColorScheme: ColorScheme? = nil

        @Published private var error: STError? = nil
        var reviewEventSignal = PassthroughSubject<WebViewEventType, Never>()

        var isAuthenticated: Bool {
            guard let accessToken = accessToken else { return false }
            return !accessToken.isEmpty
        }

        override init(container: DIContainer) {
            super.init(container: container)
            appState.system.$error.assign(to: &$error)
            appState.system.$isErrorAlertPresented.assign(to: &$isErrorAlertPresented)
            appState.user.$accessToken.assign(to: &$accessToken)
            appState.system.$preferredColorScheme.assign(to: &$preferredColorScheme)
        }

        var errorTitle: String {
            (appState.system.error ?? .init(.UNKNOWN_ERROR)).title
        }

        var errorMessage: String {
            (appState.system.error ?? .init(.UNKNOWN_ERROR)).content
        }

        func reloadReviewWebView() {
            reviewEventSignal.send(.reload)
        }
    }
}

enum TabType: String {
    case timetable
    case search
    case review
    case settings
}

#if DEBUG
    struct SNUTTView_Previews: PreviewProvider {
        static var previews: some View {
            SNUTTView(viewModel: .init(container: .preview))
        }
    }
#endif

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
