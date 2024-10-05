import APIClientInterface
import Auth
import AuthInterface
import Dependencies
import SharedUIComponents
import SwiftUI
import Timetable

struct ContentView: View {
    @StateObject private var viewModel = ContentViewModel()

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
        .animation(.easeInOut, value: viewModel.isAuthenticated)
        .accentColor(Color(uiColor: .label))
    }

    private var mainView: some View {
        ZStack {
            AnimatableTabView(selectedTab: $viewModel.selectedTab) {
                TabScene(tabItem: TabItem.timetable, rootView: TimetableScene())
//                TabScene(tabItem: TabItem.search, rootView: LectureSearchScene())
                TabScene(tabItem: TabItem.friends, rootView: ColorView(color: .yellow))
                TabScene(tabItem: TabItem.review, rootView: ColorView(color: .green))
                TabScene(tabItem: TabItem.settings, rootView: ColorView(color: .purple))
            }
            .ignoresSafeArea()
        }
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
