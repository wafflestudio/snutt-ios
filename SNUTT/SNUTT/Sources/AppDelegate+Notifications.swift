//
//  AppDelegate+Notifications.swift
//  SNUTT
//
//  Copyright © 2024 wafflestudio.com. All rights reserved.
//

import Firebase
import UIKit
import os.log

private let logger = Logger(subsystem: "com.wafflestudio.snutt", category: "Notifications")

// MARK: - Notification System Setup

extension AppDelegate {
    /// Configures the notification system and requests user permissions.
    ///
    /// ## Overview
    /// Sets up:
    /// - User notification center delegate
    /// - Notification authorization (.alert, .badge, .sound)
    /// - Remote notification registration with APNs
    /// - Firebase Messaging delegate
    ///
    /// ## APNs → FCM Token Flow
    /// 1. User grants permission
    /// 2. APNs generates device token
    /// 3. `didRegisterForRemoteNotificationsWithDeviceToken` forwards to Firebase
    /// 4. Firebase generates FCM token
    /// 5. `messaging(_:didReceiveRegistrationToken:)` receives FCM token
    /// 6. The app sends FCM token to backend
    func setupNotificationSystem(application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(
            options: [.alert, .badge, .sound]
        ) { @Sendable granted, error in
            if let error {
                logger.error("Notification permission error: \(error.localizedDescription)")
            }
            logger.info("Notification permission: \(granted ? "granted" : "denied")")
        }

        application.registerForRemoteNotifications()
        Firebase.Messaging.messaging().delegate = self
    }
}

// MARK: - UNUserNotificationCenterDelegate

/// Handles notification lifecycle events.
///
/// ## Firebase Method Swizzling
/// Swizzling is **disabled** (`FirebaseAppDelegateProxyEnabled = false` in Info.plist).
/// We manually call `appDidReceiveMessage` in each delegate method for analytics tracking.
///
/// ## FCM Message Format
///
/// All messages from the server include `aps.alert` - iOS displays automatically:
/// ```json
/// {
///   "aps": { "alert": { "title": "강의 알림", "body": "10분 후 시작" } },
///   "url_scheme": "snutt://timetable-lecture?..."
/// }
/// ```
///
/// ## Lifecycle by App State
///
/// **Foreground**: `willPresent` → display banner → user taps → `didReceive`
/// **Background/Closed**: iOS displays → user taps → `didReceive`
extension AppDelegate: @MainActor UNUserNotificationCenterDelegate {

    /// Handles notifications arriving while app is in foreground.
    ///
    /// ## When Called
    /// - App is active and visible
    /// - FCM message arrives
    ///
    /// ## Why Override?
    /// By default, iOS doesn't display notifications in foreground.
    /// We return `[.banner, .sound, .list]` to show them anyway.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        let userInfo = notification.request.content.userInfo
        Firebase.Messaging.messaging().appDidReceiveMessage(userInfo)
        return [.banner, .sound, .list]
    }

    /// Handles user tapping on a notification.
    ///
    /// ## When Called
    /// - User taps notification body or action button
    /// - App can be in any state (foreground/background/not running)
    ///
    /// ## Navigation
    /// Extracts `url_scheme` from userInfo and opens it.
    /// SceneDelegate receives the URL and routes to appropriate screen.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo
        Firebase.Messaging.messaging().appDidReceiveMessage(userInfo)
        await openURLScheme(from: response.notification)
    }

    /// Handles remote notifications received in background.
    ///
    /// ## When Called
    /// - FCM message arrives with `content-available: 1` flag with `apns-push-type: background`
    /// - App is in background or foreground (but NOT when force quitted by the user)
    ///
    /// ## Current Implementation
    /// This method is kept for future extensibility (e.g., silent background updates).
    ///
    /// ## Firebase Analytics
    /// `appDidReceiveMessage` tracks delivery metrics.
    /// Required because Firebase method swizzling is disabled (`FirebaseAppDelegateProxyEnabled = false`).
    func application(
        _ application: UIApplication,
        didReceiveRemoteNotification userInfo: [AnyHashable: Any]
    ) async -> UIBackgroundFetchResult {
        Messaging.messaging().appDidReceiveMessage(userInfo)
        return .noData
    }
}

// MARK: - MessagingDelegate

/// Manages FCM token registration.
///
/// ## Token Types
/// - **APNs Token**: Apple's device-specific identifier
/// - **FCM Token**: Firebase's cross-platform wrapper
///
/// ## Why Two Tokens?
/// - APNs is iOS-specific, FCM works across platforms
/// - Backend uses FCM tokens to send notifications via Firebase
///
/// ## Token Flow
/// 1. APNs generates device token
/// 2. `didRegisterForRemoteNotificationsWithDeviceToken` forwards to Firebase
/// 3. Firebase generates FCM token
/// 4. `messaging(_:didReceiveRegistrationToken:)` posts to NotificationCenter
/// 5. SNUTTApp sends to backend
extension AppDelegate: @MainActor Firebase.MessagingDelegate {
    /// Receives FCM token from Firebase.
    ///
    /// ## When Called
    /// - First launch after permission granted
    /// - Token refresh (rare, usually after reinstall)
    ///
    /// ## Token Distribution
    /// Posts to NotificationCenter with name `"FCMToken"`.
    /// SNUTTApp observes and sends to backend.
    func messaging(
        _ messaging: Messaging,
        didReceiveRegistrationToken fcmToken: String?
    ) {
        guard let fcmToken = fcmToken else {
            logger.warning("FCM token is nil")
            return
        }

        logger.info("FCM token received")

        NotificationCenter.default.post(
            name: Notification.Name("FCMToken"),
            object: nil,
            userInfo: ["token": fcmToken]
        )
    }

    /// Registers APNs device token with Firebase.
    ///
    /// ## When Called
    /// After `application.registerForRemoteNotifications()` succeeds.
    ///
    /// ## Why Forward to Firebase?
    /// Firebase needs APNs token to:
    /// 1. Generate FCM token
    /// 2. Communicate with APNs
    /// 3. Handle notification delivery
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        logger.info("APNs device token received, forwarding to Firebase")
        Firebase.Messaging.messaging().apnsToken = deviceToken
    }
}

// MARK: - URL Scheme Handling

extension AppDelegate {
    /// Extracts and opens URL scheme from notification.
    ///
    /// ## Overview
    /// Extracts `url_scheme` from notification's userInfo and opens it.
    /// SceneDelegate receives URL and routes to appropriate screen.
    ///
    /// ## URL Scheme Format
    /// `snutt://[host]?[parameters]`
    ///
    /// ## Navigation Flow
    /// 1. Extract `url_scheme` from userInfo
    /// 2. Open URL via `UIApplication.shared.open`
    /// 3. SceneDelegate handles URL routing
    /// 4. ContentViewModel navigates to screen
    func openURLScheme(from notification: UNNotification) async {
        let userInfo = notification.request.content.userInfo

        guard let urlString = userInfo["url_scheme"] as? String else {
            logger.debug("No url_scheme in notification")
            return
        }

        guard let url = URL(string: urlString) else {
            logger.error("Invalid URL in notification: \(urlString)")
            return
        }

        logger.info("Opening URL scheme: \(url.absoluteString)")

        let opened = await UIApplication.shared.open(url, options: [:])
        if !opened {
            logger.error("Failed to open URL scheme: \(url.absoluteString)")
        }
    }
}
