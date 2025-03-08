import Dependencies
import KakaoMapsSDK
import SharedUIComponents
import SwiftUI

@main
struct SNUTTApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @Dependency(\.authState) private var authState
    @Dependency(\.authSecureRepository) private var secureRepository
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

        initializeKakaoSDK()
    }

    /// for KakaoMap (TODO: initialization for "login with kakao")
    private func initializeKakaoSDK() {
        let kakaoAppKey = Bundle.main.infoDictionary?["KAKAO_APP_KEY"] as! String
        SDKInitializer.InitSDK(appKey: kakaoAppKey)
    }
    
    /// Listens to the FCM token sent from `AppDelegate` and forwards it to the server.
    private func setFCMToken() {
        NotificationCenter.default.addObserver(forName: Notification.Name("FCMToken"), object: nil, queue: .main) { notification in
            guard let fcmToken = notification.userInfo?["token"] as? String else { return }
            Task {
                try await authUseCase.registerFCMToken(fcmToken)
            }
            print("FCM Token: \(fcmToken)")
        }
    }
}
