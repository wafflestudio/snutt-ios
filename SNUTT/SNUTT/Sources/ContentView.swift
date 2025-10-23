import APIClient
import APIClientInterface
import AnalyticsInterface
import Auth
import AuthInterface
import Dependencies
import Notifications
import NotificationsInterface
import Popup
import Reviews
import Settings
import SharedUIComponents
import SwiftUI
import Timetable
import Vacancy

struct ContentView: View {
    @State private var viewModel = ContentViewModel()
    @Environment(\.errorAlertHandler) private var errorAlertHandler
    @AppStorage(AppStorageKeys.preferredColorScheme) private var selectedColorScheme: ColorSchemeSelection = .system

    var body: some View {
        VStack {
            if viewModel.isAuthenticated {
                mainView
                    .transition(.identity)
            } else {
                onboardScene
                    .transition(onboardTransition)
                    .zIndex(1)
            }
        }
        .environment(\.configs, viewModel.configs)
        .animation(.easeInOut, value: viewModel.isAuthenticated)
        .tint(.label)
        .preferredColorScheme(selectedColorScheme.colorScheme)
        .onOpenURL { url in
            errorAlertHandler.withAlert {
                try await viewModel.handleURLScheme(url)
            }
        }
        #if DEBUG
            .observeNetworkLogsGesture()
        #endif
    }

    private var mainView: some View {
        ZStack {
            AnimatableTabView(selectedTab: $viewModel.selectedTab) {
                TabScene(
                    tabItem: TabItem.timetable,
                    rootView: TimetableScene(
                        isSearchMode: isSearchMode,
                        timetableViewModel: viewModel.timetableViewModel,
                        lectureSearchRouter: viewModel.lectureSearchRouter
                    )
                    .environment(\.notificationsUIProvider, NotificationsUIProvider())
                )
                TabScene(tabItem: TabItem.search)
                TabScene(tabItem: TabItem.friends, rootView: EmptyView())
                TabScene(
                    tabItem: TabItem.review,
                    rootView: ReviewsScene()
                        .modifier(AnalyticsScreenModifier(screen: Reviews.AnalyticsScreen.reviewHome))
                )
                TabScene(
                    tabItem: TabItem.settings,
                    rootView: SettingsScene()
                        .environment(\.vacancyUIProvider, VacancyUIProvider())
                        #if DEBUG
                            .environment(\.networkLogUIProvider, NetworkLogUIProvider())
                        #endif
                )
            }
            .ignoresSafeArea()
        }
        .overlaySheet()
        .overlayPopup()
        .environment(\.themeViewModel, viewModel.themeViewModel)
        .environment(\.timetableViewModel, viewModel.timetableViewModel)
        .onLoad {
            errorAlertHandler.withAlert {
                try? await viewModel.themeViewModel.fetchThemes()
            }
        }
    }

    private var isSearchMode: Binding<Bool> {
        .init(
            get: { viewModel.selectedTab == .search },
            set: { isSearchMode in viewModel.selectedTab = isSearchMode ? .search : .timetable }
        )
    }

    private var onboardScene: some View {
        OnboardScene()
    }

    private var onboardTransition: AnyTransition {
        if #available(iOS 17, *) {
            AnyTransition(.blurReplace(.downUp).combined(with: .push(from: .top)))
        } else {
            AnyTransition.push(from: .top)
        }
    }
}

#Preview {
    ContentView()
        .observeErrors()
}
