import Dependencies
import SharedUIComponents
import SwiftUI
import WindowReader

@main
struct SNUTTApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @Dependency(\.authState) private var authState
    @Dependency(\.authSecureRepository) private var secureRepository

    init() {
        bootstrap()
    }

    var body: some Scene {
        WindowGroup {
            WindowReader { window in
                ContentView()
                    .environment(\.hudPresenter, HudPresenter(windowScene: window.windowScene))
            }
        }
    }
}

extension SNUTTApp {
    private func bootstrap() {
        if let userID = authState.get(.userID) {
            // If userID exists in userDefaults, store it into in-memory store
            authState.set(.userID, value: userID)
        } else {
            // The user has never logged in, clear the keychain
            authState.clear()
            try? secureRepository.clear()
            return
        }

        if let accessToken = secureRepository.getAccessToken() {
            authState.set(.accessToken, value: accessToken)
        }
    }
}
