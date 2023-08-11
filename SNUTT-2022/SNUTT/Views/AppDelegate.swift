//
//  AppDelegate.swift
//  SNUTT
//
//  Created by 박신홍 on 2022/09/28.
//

import FacebookCore
import FirebaseCore
import FirebaseMessaging
import SwiftUI
import UIKit

/// Required to integrate Firebase SDK and Facebook SDK.
///
/// See [here](https://www.raywenderlich.com/20201639-firebase-cloud-messaging-for-ios-push-notifications) for more information about FCM configuration.
class AppDelegate: NSObject, UIApplicationDelegate {
    #if DEBUG
        /// `ReactNativeDevKit` requires this property to be declared.
        var window: UIWindow?
    #endif

    var firebaseConfigName: String {
        #if DEBUG
            return "GoogleServiceDebugInfo"
        #else
            return "GoogleServiceReleaseInfo"
        #endif
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool
    {
        // configure firebase sdk
        if let filePath = Bundle.main.path(forResource: firebaseConfigName, ofType: "plist"),
           let configOption = FirebaseOptions(contentsOfFile: filePath)
        {
            FirebaseApp.configure(options: configOption)
            FirebaseConfiguration.shared.setLoggerLevel(.min)

            UNUserNotificationCenter.current().delegate = self
            UNUserNotificationCenter.current().requestAuthorization(
                options: [.alert, .badge, .sound]) { _, _ in }
            application.registerForRemoteNotifications()

            Messaging.messaging().delegate = self
        }

        // configure facebook sdk
        return ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
    }

    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool
    {
        // configure facebook sdk
        return ApplicationDelegate.shared.application(app, open: url, options: options)
    }
}

/// Firebase Push Notification Settings.
extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _: UNUserNotificationCenter,
        willPresent _: UNNotification,
        withCompletionHandler completionHandler:
        @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([[.banner, .sound, .list]])
    }

    func userNotificationCenter(
        _: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        openUrl(from: response.notification)
        completionHandler()
    }

    func application(
        _: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        /// Register the token when the user grants permission for push notifications.
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(_: UIApplication, didFailToRegisterForRemoteNotificationsWithError _: Error) {}

    func openUrl(from notification: UNNotification) {
        let userInfo = notification.request.content.userInfo
        if let urlString = userInfo["url_scheme"] as? String, let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:])
        }
    }
}

extension AppDelegate: MessagingDelegate {
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
}
