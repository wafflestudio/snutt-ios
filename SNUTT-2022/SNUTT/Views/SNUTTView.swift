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

    /// Required to synchronize between two navigation bar heights: `TimetableScene` and `SearchLectureScene`.
    @MainActor @State private var navigationBarHeight: CGFloat = 0

    private var selected: Binding<TabType> {
        Binding<TabType> {
            viewModel.selectedTab
        } set: {
            [previous = viewModel.selectedTab] current in
            if previous == current, current == .review {
                viewModel.reloadReviewWebView()
            }
            viewModel.selectedTab = current
        }
    }

    @State private var pushToTimetableScene = true

    var body: some View {
        ZStack {
            if viewModel.isAuthenticated && pushToTimetableScene {
                TabView(selection: selected) {
                    TabScene(tabType: .timetable) {
                        TimetableScene(viewModel: .init(container: viewModel.container))
                            .background(NavigationBarReader { navbar in
                                navigationBarHeight = navbar.frame.height
                            })
                    }
                    TabScene(tabType: .search) {
                        SearchLectureScene(viewModel: .init(container: viewModel.container), navigationBarHeight: navigationBarHeight)
                    }
                    TabScene(tabType: .review) {
                        ReviewScene(viewModel: .init(container: viewModel.container), isMainWebView: true)
                    }
                    TabScene(tabType: .friends) {
                        FriendsScene(viewModel: .init(container: viewModel.container))
                    }
                    TabScene(tabType: .settings) {
                        SettingScene(viewModel: .init(container: viewModel.container))
                    }
                }
                .onAppear {
                    viewModel.selectedTab = .timetable
                    viewModel.preloadWebViews()
                }
                .onLoad {
                    await withTaskGroup(of: Void.self, body: { group in
                        group.addTask {
                            await viewModel.fetchTimetableList()
                        }
                        group.addTask {
                            await viewModel.fetchRecentTimetable()
                        }
                        group.addTask {
                            await viewModel.fetchCourseBookList()
                        }
                        group.addTask {
                            await viewModel.showVacancyBannerIfNeeded()
                        }
                        group.addTask {
                            await viewModel.fetchVacancyLectures()
                        }
                        group.addTask {
                            await viewModel.fetchReactNativeBundleIfNeeded()
                        }
                        group.addTask {
                            await viewModel.fetchNotificationsCount()
                        }
                    })
                }

                if viewModel.selectedTab == .timetable {
                    MenuSheetScene(viewModel: .init(container: viewModel.container))
                    LectureTimeSheetScene(viewModel: .init(container: viewModel.container))
                }
                if viewModel.selectedTab == .search {
                    FilterSheetScene(viewModel: .init(container: viewModel.container))
                }
                PopupScene(viewModel: .init(container: viewModel.container))
            } else {
                NavigationView {
                    OnboardScene(viewModel: .init(container: viewModel.container), pushToTimetableScene: $pushToTimetableScene)
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
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
        @Published var accessToken: String? = nil
        @Published var preferredColorScheme: ColorScheme? = nil
        @Published private var error: STError? = nil

        @Published private var _isErrorAlertPresented = false
        var isErrorAlertPresented: Bool {
            get { _isErrorAlertPresented }
            set { services.globalUIService.setIsErrorAlertPresented(newValue) }
        }

        @Published private var _selectedTab: TabType = .timetable
        var selectedTab: TabType {
            get { _selectedTab }
            set { services.globalUIService.setSelectedTab(newValue) }
        }

        var isAuthenticated: Bool {
            guard let accessToken = accessToken else { return false }
            return !accessToken.isEmpty
        }

        override init(container: DIContainer) {
            super.init(container: container)
            appState.system.$error.assign(to: &$error)
            appState.system.$isErrorAlertPresented.assign(to: &$_isErrorAlertPresented)
            appState.user.$accessToken.assign(to: &$accessToken)
            appState.system.$preferredColorScheme.assign(to: &$preferredColorScheme)
            appState.system.$selectedTab.assign(to: &$_selectedTab)
        }

        var errorTitle: String {
            (appState.system.error ?? .init(.UNKNOWN_ERROR)).title
        }

        var errorMessage: String {
            (appState.system.error ?? .init(.UNKNOWN_ERROR)).content
        }

        func reloadReviewWebView() {
            services.globalUIService.sendMainWebViewReloadSignal()
        }

        func preloadWebViews() {
            services.globalUIService.preloadWebViews()
        }

        func fetchTimetableList() async {
            do {
                try await services.timetableService.fetchTimetableList()
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }

        func fetchCourseBookList() async {
            do {
                try await services.courseBookService.fetchCourseBookList()
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }

        func fetchRecentTimetable() async {
            do {
                try await services.timetableService.fetchRecentTimetable()
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }

        func showVacancyBannerIfNeeded() async {
            do {
                try await services.vacancyService.showVacancyBannerIfNeeded()
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }

        func fetchVacancyLectures() async {
            do {
                try await services.vacancyService.fetchLectures()
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }

        func fetchReactNativeBundleIfNeeded() async {
            do {
                try await services.friendsService.fetchReactNativeBundleUrl()
            } catch {
                // pass
            }
        }

        func fetchNotificationsCount() async {
            do {
                try await services.notificationService.fetchUnreadNotificationCount()
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }
    }
}

enum TabType: String {
    case timetable
    case search
    case review
    case friends
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
