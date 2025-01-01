import APIClientInterface
import Auth
import AuthInterface
import Dependencies
import SharedUIComponents
import SwiftUI
import Timetable

struct ContentView: View {
    @State private var viewModel = ContentViewModel()
    @State private var sheetPresentationContext: SheetPresentationContext?

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
        .observeErrors()
        .animation(.easeInOut, value: viewModel.isAuthenticated)
        .tint(.label)
    }

    private var mainView: some View {
        ZStack {
            AnimatableTabView(selectedTab: $viewModel.selectedTab) {
                TabScene(tabItem: TabItem.timetable, rootView: TimetableScene(isSearchMode: isSearchMode))
                TabScene(tabItem: TabItem.search)
                TabScene(tabItem: TabItem.friends, rootView: ColorView(color: .yellow))
                TabScene(tabItem: TabItem.review, rootView: ColorView(color: .green))
                TabScene(tabItem: TabItem.settings, rootView: ColorView(color: .purple))
            }
            .ignoresSafeArea()

            sheetPresentationContext?.makeHUDView()
        }
        .onPreferenceChange(SheetPresentationKey.self) { value in
            Task { @MainActor in
                sheetPresentationContext = value
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
}
