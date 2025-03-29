import Dependencies
import SharedUIComponents
import SwiftUI

@main
struct SNUTTApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @Dependency(\.authUseCase) private var authUseCase

    init() {
        bootstrap()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

extension SNUTTApp {
    private func bootstrap() {
        authUseCase.syncAuthState()
        setFCMToken()
    }

    /// Listens to the FCM token sent from `AppDelegate` and forwards it to the server.
    private func setFCMToken() {
        Task.detached {
            for await notification in NotificationCenter.default.publisher(for: .fcmToken).values {
                guard let fcmToken = notification.userInfo?["token"] as? String else { continue }
                try await self.authUseCase.registerFCMToken(fcmToken)
                print("FCM Token: \(fcmToken)")
                break
            }
        }
    }
}

extension Notification.Name {
    static let fcmToken: Self = Notification.Name(rawValue: "FCMToken")
}
