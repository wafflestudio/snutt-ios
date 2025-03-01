//
//  SNUTTView.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/06/28.
//

import Combine
import SwiftUI

struct SNUTTView: View, Sendable {
    @ObservedObject var viewModel: ViewModel

    private var selected: Binding<TabType> {
        Binding<TabType> {
            viewModel.selectedTab
        } set: {
            [previous = viewModel.selectedTab] current in
            let hasDoubleTapped = { (tabType: TabType) -> Bool in
                previous == current && current == tabType
            }
            if hasDoubleTapped(.review) {
                viewModel.reloadReviewWebView()
            }
            if hasDoubleTapped(.search) {
                viewModel.initializeSearchState()
            }
            viewModel.selectedTab = current
        }
    }

    @State private var pushToTimetableScene = true

    var body: some View {
        ZStack {
            if let noticeViewInfo = viewModel.noticeViewInfo, noticeViewInfo.visible {
                NavigationView {
                    NoticeView(title: noticeViewInfo.title,
                               content: noticeViewInfo.content,
                               sendFeedback: viewModel.sendFeedback)
                }
            } else if viewModel.isAuthenticated && pushToTimetableScene {
                TabView(selection: selected) {
                    TabScene(tabType: .timetable) {
                        TimetableScene(viewModel: .init(container: viewModel.container))
                    }
                    TabScene(tabType: .search) {
                        SearchLectureScene(viewModel: .init(container: viewModel.container))
                    }
                    TabScene(tabType: .review) {
                        ReviewScene(viewModel: .init(container: viewModel.container), isMainWebView: true)
                            .analyticsScreen(.reviewHome)
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
                            await viewModel.getThemeList()
                        }
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
                        group.addTask {
                            await viewModel.getBookmark()
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
                    OnboardScene(
                        viewModel: .init(container: viewModel.container),
                        pushToTimetableScene: $pushToTimetableScene
                    )
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
        .onLoad {
            await viewModel.showNoticeViewIfNeeded()
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
        @Published var noticeViewInfo: ConfigsDto.NoticeViewInfoDto?

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
            appState.system.$noticeViewInfo.assign(to: &$noticeViewInfo)
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

        func getThemeList() async {
            do {
                try await services.themeService.getThemeList()
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
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

        func showNoticeViewIfNeeded() async {
            do {
                try await services.globalUIService.showNoticeViewIfNeeded()
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

        func initializeSearchState() {
            services.searchService.initializeSearchState()
        }

        func getBookmark() async {
            do {
                try await services.searchService.getBookmark()
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
            }
        }

        func sendFeedback(email: String, message: String) async -> Bool {
            if !Validation.check(email: email) {
                services.globalUIService.presentErrorAlert(error: .INVALID_EMAIL)
                return false
            }
            do {
                try await services.etcService.sendFeedback(email: email, message: message)
                return true
            } catch {
                services.globalUIService.presentErrorAlert(error: error)
                return false
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
