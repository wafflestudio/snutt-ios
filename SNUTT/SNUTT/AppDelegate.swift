//
//  AppDelegate.swift
//  SNUTT
//
//  Created by 김진형 on 2015. 7. 2..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import Alamofire
import Crashlytics
import Fabric
import FBSDKCoreKit
import Firebase
import SwiftyJSON
import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        #if DEBUG
        #else
            Fabric.with([Crashlytics.self])
        #endif

        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)

        let path = Bundle.main.path(forResource: "config", ofType: "plist")!
        let configAllDict = NSDictionary(contentsOfFile: path)!

        #if DEBUG
            let infoName = "GoogleService-Info-Dev"
            let configKey = "debug"
        #elseif PRODUCTION
            let infoName = "GoogleService-Info-Production"
            let configKey = "production"
        #else
            let infoName = "GoogleService-Info-Production"
            let configKey = "staging"
        #endif

        print(infoName)
        print(configKey)

        let configDict = configAllDict.object(forKey: configKey) as! NSDictionary
        let filePath = Bundle.main.path(forResource: infoName, ofType: "plist")
        let options = FirebaseOptions(contentsOfFile: filePath!)
        FirebaseApp.configure(options: options!)

        print(configDict.object(forKey: "api_server_url") as! String)

        STConfig.sharedInstance.baseURL = configDict.object(forKey: "api_server_url") as! String

        setColors()

        // open main or login depending on the token
        if STDefaults[.token] != nil {
            window?.rootViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateInitialViewController()
        } else {
            window?.rootViewController = UIStoryboard(name: "Login", bundle: Bundle.main).instantiateInitialViewController()
        }

        // set the api key base on config.plist
        STDefaults[.apiKey] = configDict.object(forKey: "api_key") as! String
        if STDefaults[.token] != nil {
            STNetworking.getNotificationCount({ cnt in
                STDefaults[.shouldShowBadge] = cnt != 0
            }, failure: {})
        }

        // set snuev web url
        STDefaults[.snuevWebUrl] = configDict.object(forKey: "snuev_web_url") as! String

        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self

            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: { _, _ in }
            )
        } else {
            let settings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()

        if InstanceID.instanceID().token() != nil {
            STUser.updateDeviceIdIfNeeded()
            connectToFcm()
        }

        // For STColorList UserDefaults
        NSKeyedArchiver.setClassName("STColorList", for: STColorList.self)
        NSKeyedUnarchiver.setClass(STColorList.self, forClassName: "STColorList")
        // For STFCMInfo UserDefaults
        NSKeyedArchiver.setClassName("STFCMInfo", for: STFCMInfo.self)
        NSKeyedUnarchiver.setClass(STFCMInfo.self, forClassName: "STFCMInfo")

        var fcmInfos = STDefaults[.shouldDeleteFCMInfos]?.infoList ?? []
        for fcmInfo in fcmInfos {
            STNetworking.logOut(userId: fcmInfo.userId, fcmToken: fcmInfo.fcmToken, done: {
                let infos = STDefaults[.shouldDeleteFCMInfos]?.infoList ?? []
                STDefaults[.shouldDeleteFCMInfos] = STFCMInfoList(infoList: infos.filter { info in info != fcmInfo })
            }, failure: nil)
        }
        
        STPopupManager.initialize()

        return true
    }

    func setColors() {
        UINavigationBar.appearance().tintColor = UIColor.black
        UITabBar.appearance().tintColor = UIColor.black

        if #available(iOS 15.0, *) {
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithOpaqueBackground()
            navigationBarAppearance.backgroundColor = .systemBackground
            UINavigationBar.appearance().standardAppearance = navigationBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance

            let tabBarAppearance = UITabBarAppearance()
            tabBarAppearance.configureWithOpaqueBackground()
            tabBarAppearance.backgroundColor = .systemBackground
            UITabBar.appearance().standardAppearance = tabBarAppearance
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }

    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func application(_: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
    {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.

        receivedNotification()

        // Print message ID.
        #if DEBUG
            print("Message ID: \(userInfo["gcm.message_id"]!)")
            print("%@", userInfo)
        #endif

        completionHandler(UIBackgroundFetchResult.newData)
    }

    func receivedNotification() {
        STMainTabBarController.controller?.notificationController?.refreshList()
    }

    func applicationWillResignActive(_: UIApplication) {
        STPopupManager.saveData()
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func messaging(_: Messaging, didRefreshRegistrationToken _: String) {
        STUser.updateDeviceIdIfNeeded()
        connectToFcm()
    }

    func connectToFcm() {
        Messaging.messaging().connect { error in
            #if DEBUG
                if error != nil {
                    print("Unable to connect with FCM. \(error)")
                } else {
                    print("Connected to FCM.")
                }
            #endif
        }
    }

    func applicationDidEnterBackground(_: UIApplication) {
        Messaging.messaging().disconnect()
        print("Disconnected from FCM.")
    }

    func applicationWillEnterForeground(_: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_: UIApplication) {
        STPopupManager.initialize()
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        let fbHandled = FBSDKApplicationDelegate.sharedInstance().application(application, open: url, sourceApplication: sourceApplication, annotation: annotation)
        return fbHandled
    }
}

@available(iOS 10, *)
extension AppDelegate: UNUserNotificationCenterDelegate {
    // Receive displayed notifications for iOS 10 devices.

    func userNotificationCenter(_: UNUserNotificationCenter, willPresent _: UNNotification, withCompletionHandler _: @escaping (UNNotificationPresentationOptions) -> Void) {
        receivedNotification()
    }
}

extension AppDelegate: MessagingDelegate {
    // Receive data message on iOS 10 devices.
    func applicationReceivedRemoteMessage(remoteMessage: MessagingRemoteMessage) {
        #if DEBUG
            print("%@", remoteMessage.appData)
        #endif
        receivedNotification()
    }
}
