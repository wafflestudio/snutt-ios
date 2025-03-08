//
//  AppDelegate.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Firebase
import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    private var firebaseConfigName: String {
        #if DEBUG
            return "GoogleServiceDebugInfo"
        #else
            return "GoogleServiceReleaseInfo"
        #endif
    }

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // MARK: Configure Firebase

        if let filePath = Bundle.main.path(forResource: firebaseConfigName, ofType: "plist"),
           let configOption = FirebaseOptions(contentsOfFile: filePath)
        {
            FirebaseApp.configure(options: configOption)
            FirebaseConfiguration.shared.setLoggerLevel(.min)

            // MARK: remote notification

            // https://developer.apple.com/forums/thread/764777
            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(options: [
                .alert,
                .badge,
                .sound,
            ]) { @Sendable _, _ in }
            application.registerForRemoteNotifications()
            Messaging.messaging().delegate = self
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(
        _: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options _: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        let sceneConfig = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        sceneConfig.delegateClass = SceneDelegate.self
        return sceneConfig
    }

    func application(_: UIApplication, didDiscardSceneSessions _: Set<UISceneSession>) {}
}

/// Firebase Push Notification Settings.
extension AppDelegate: @preconcurrency UNUserNotificationCenterDelegate {
    func userNotificationCenter(_: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions)
                                    -> Void)
    {
        let userInfo = notification.request.content.userInfo
        Messaging.messaging().appDidReceiveMessage(userInfo)
        completionHandler([[.banner, .sound, .list]])
    }

    func userNotificationCenter(_: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void)
    {
        let userInfo = response.notification.request.content.userInfo
        Messaging.messaging().appDidReceiveMessage(userInfo)
        openUrl(from: response.notification)
        completionHandler()
    }

    func application(_: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    {
        Messaging.messaging().appDidReceiveMessage(userInfo)
        completionHandler(.noData)
    }

    func openUrl(from notification: UNNotification) {
        let userInfo = notification.request.content.userInfo
        if let urlString = userInfo["url_scheme"] as? String, let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:])
        }
    }
}

extension AppDelegate: @preconcurrency MessagingDelegate {
    func messaging(
        _: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        let tokenDict = ["token": fcmToken ?? ""]
        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: tokenDict
        )
    }

    func application(
        _: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        /// Register the token when the user grants permission for push notifications.
        Messaging.messaging().apnsToken = deviceToken
    }
}
