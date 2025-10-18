import Dependencies
import FacebookCore
import KakaoSDKAuth
import KakaoSDKCommon
import SharedUIComponents
import SharedUIWebKit
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
                .observeErrors()
        }
    }
}

extension SNUTTApp {
    private func bootstrap() {
        initializeSocialSDKs()
        authUseCase.syncAuthState()
        setFCMToken()
        Task {
            WebViewRecycler.shared.prepare()
        }
    }

    private func initializeSocialSDKs() {
        if let kakaoAppKey = Bundle.main.object(forInfoDictionaryKey: "KAKAO_APP_KEY") as? String {
            KakaoSDK.initSDK(appKey: kakaoAppKey)
        }
    }

    /// Listens to the FCM token sent from `AppDelegate` and forwards it to the server.
    private func setFCMToken() {
        Task.detached {
            for await notification in NotificationCenter.default.publisher(for: .fcmToken).values {
                guard let fcmToken = notification.userInfo?["token"] as? String else { continue }
                try await self.authUseCase.registerFCMToken(fcmToken)
                break
            }
        }
    }
}

extension Notification.Name {
    static let fcmToken: Self = Notification.Name(rawValue: "FCMToken")
}
