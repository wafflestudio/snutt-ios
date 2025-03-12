import Dependencies
import KakaoMapsSDK
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
        setFCMToken()
        authUseCase.syncAuthState()
        initializeKakaoSDK()
    }

    /// for KakaoMap (TODO: initialization for "login with kakao")
    private func initializeKakaoSDK() {
        let kakaoAppKey = Bundle.main.infoDictionary?["KAKAO_APP_KEY"] as! String
        SDKInitializer.InitSDK(appKey: kakaoAppKey)
    }

    /// Listens to the FCM token sent from `AppDelegate` and forwards it to the server.
    private func setFCMToken() {
        NotificationCenter.default
            .addObserver(forName: .fcmToken, object: nil, queue: .main) { notification in
                guard let fcmToken = notification.userInfo?["token"] as? String else { return }
                Task {
                    try await authUseCase.registerFCMToken(fcmToken)
                }
                print("FCM Token: \(fcmToken)")
            }
    }
}

extension Notification.Name {
    static let fcmToken: Self = Notification.Name(rawValue: "FCMToken")
}
