import APIClient
import APIClientInterface
import AnalyticsInterface
import Auth
import AuthInterface
import Dependencies
import Friends
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
    @Environment(\.presentToast) private var presentToast
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
            CommonTabView(selectedTab: $viewModel.selectedTab) {
                TabScene(
                    tabItem: TabItem.timetable,
                    rootView: TimetableScene(
                        isSearchMode: isSearchMode,
                        timetableViewModel: viewModel.timetableViewModel
                    )
                    .environment(\.notificationsUIProvider, NotificationsUIProvider())
                )
                TabScene(tabItem: TabItem.search)
                TabScene(
                    tabItem: TabItem.review,
                    rootView: ReviewsScene()
                        .modifier(AnalyticsScreenModifier(screen: Reviews.AnalyticsScreen.reviewHome))
                )
                TabScene(
                    tabItem: TabItem.friends,
                    rootView: FriendsScene()
                        .modifier(AnalyticsScreenModifier(screen: Friends.AnalyticsScreen.friends))
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
        .overlayADPopup()
        .task {
            for await message in viewModel.notificationCenter.messages(of: ToastNotificationMessage.self) {
                presentToast(message.toast)
            }
        }
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
        AnyTransition(.blurReplace(.downUp).combined(with: .push(from: .top)))
    }
}

#Preview {
    ContentView()
        .observeErrors()
}
