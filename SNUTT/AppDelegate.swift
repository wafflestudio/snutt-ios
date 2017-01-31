//
//  AppDelegate.swift
//  SNUTT
//
//  Created by 김진형 on 2015. 7. 2..
//  Copyright (c) 2015년 WaffleStudio. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import SwiftyJSON
import FBSDKCoreKit
import Firebase
import Alamofire


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        Fabric.with([Crashlytics.self])
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        FIRApp.configure()
        
        setColors()
        
        // open main or login depending on the token
        if STDefaults[.token] != nil {
            self.window?.rootViewController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateInitialViewController()
        } else {
            self.window?.rootViewController = UIStoryboard(name: "Login", bundle: NSBundle.mainBundle()).instantiateInitialViewController()
        }
        
        // set the api key base on config.plist
        if STDefaults[.apiKey] == "" {
            let path = NSBundle.mainBundle().pathForResource("config", ofType: "plist")!
            let dict = NSDictionary(contentsOfFile: path)!
            
            STDefaults[.apiKey] = dict.objectForKey("API_KEY") as! String
        }
        if STDefaults[.token] != nil {
            STNetworking.getNotificationCount({ cnt in
                STMainTabBarController.controller?.setNotiBadge(cnt)
                
                }, failure: { _ in
                    return
            })
        }
        
        
        let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        NSNotificationCenter.defaultCenter().addObserver(self,
                                                         selector: #selector(self.tokenRefreshNotification),
                                                         name: kFIRInstanceIDTokenRefreshNotification,
                                                         object: nil)
        
        if (FIRInstanceID.instanceID().token() != nil) {
            STUser.updateDeviceIdIfNeeded()
            connectToFcm()
        }
        
        return true
    }
    
    func setColors() {
        UINavigationBar.appearance().tintColor = UIColor.blackColor()
        UITabBar.appearance().tintColor = UIColor.blackColor()
    }
    
    func tokenRefreshNotification(notification: NSNotification) {
        STUser.updateDeviceIdIfNeeded()
        connectToFcm()
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.Sandbox)
        //FIXME: Production Firebase
        //FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.Prod)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
                     fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        
        //TODO: Fix the gcm.badge.message
        STMainTabBarController.controller?.setNotiBadge((userInfo["gcm.badge.message"] as? Int) ?? 1)
        
        // Print message ID.
        print("Message ID: \(userInfo["gcm.message_id"]!)")
        
        // Print full message.
        print("%@", userInfo)
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    func connectToFcm() {
        FIRMessaging.messaging().connectWithCompletion { (error) in
            if (error != nil) {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    func applicationDidEnterBackground(application: UIApplication) {
        FIRMessaging.messaging().disconnect()
        print("Disconnected from FCM.")
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        let fbHandled = FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
        return fbHandled
    }

}

