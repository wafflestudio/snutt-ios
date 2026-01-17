import APIClient
import APIClientInterface
import AnalyticsInterface
import Auth
import AuthInterface
import Dependencies
import FoundationUtility
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
    @AppStorage(AppStorageKeys.preferredColorScheme) private var selectedColorScheme: ColorSchemeSelection = .system
    @Environment(\.errorAlertHandler) private var errorAlertHandler

    var body: some View {
        VStack {
            if viewModel.isAuthenticated {
                MainContentView()
                    .transition(.identity)
            } else {
                OnboardScene()
                    .transition(.blurReplace(.downUp).combined(with: .push(from: .top)))
                    .zIndex(1)
            }
        }
        .animation(.easeInOut, value: viewModel.isAuthenticated)
        .tint(.label)
        .preferredColorScheme(selectedColorScheme.colorScheme)
        .environment(\.configs, viewModel.configs)
        .task {
            errorAlertHandler.withAlert {
                try await viewModel.loadConfigs()
            }
        }
        #if DEBUG
            .observeNetworkLogsGesture()
        #endif
    }
}

#Preview {
    ContentView()
        .observeErrors()
}
