//
//  AppDelegate.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 9/21/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import UIKit
import Firebase
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var restManager: RestManager?
    
    var sessionManager: SessionManager?
        
    var currentlyLoggedInPerson: Person?
    
    var errorManager: ErrorManager?
    
    var pinViewIsUp:Bool? = false
    
    var tabBarController:ProactiveTabBarController?
    
    var FBToken:String?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FIRApp.configure()
        
        if #available(iOS 10.0, *) {
            let authOptions : UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_,_ in })
            
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            // For iOS 10 data message (sent via FCM)
            FIRMessaging.messaging().remoteMessageDelegate = self
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        if FIRInstanceID.instanceID().token() != nil {
            FBToken = FIRInstanceID.instanceID().token()!
        } else {
            FBToken = ""
        }
        
        
        print("TOKEN!" + FBToken!)
        
        errorManager = ErrorManager()
        restManager = RestManager()
        sessionManager = SessionManager()
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        var firstViewController = storyBoard.instantiateViewController(withIdentifier: "ViewController") as UIViewController
        
        if (sessionManager?.sessionIsActive())! {
            firstViewController = storyBoard.instantiateViewController(withIdentifier: "PinViewController") as UIViewController
        }
        
        self.window?.rootViewController = firstViewController
        self.window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        let topViewController = UIApplication.topViewController()
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let pinViewController = storyBoard.instantiateViewController(withIdentifier: "PinViewController") as! PinViewController
        
        if topViewController == self.window?.rootViewController || pinViewIsUp! {
            return
        }
        
        sessionManager?.lockSession = 1

        pinViewController.delegate = topViewController
        topViewController?.present(pinViewController, animated: false, completion: nil)
        pinViewIsUp = true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        FIRMessaging.messaging().disconnect()
        print("Disconnected from FCM.")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func resetViewToLogin(){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let firstViewController = storyBoard.instantiateViewController(withIdentifier: "ViewController") as UIViewController
        self.window?.rootViewController = firstViewController
        self.window?.makeKeyAndVisible()
    }
    
    func tokenRefreshNotification(_ notification: Notification) {
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            print("InstanceID token: \(refreshedToken)")
        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }

    func connectToFcm() {
        FIRMessaging.messaging().connect { (error) in
            if (error != nil) {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // Print message ID.
        print("Message ID: \(userInfo["gcm.message_id"]!)")
        
        // Print full message.
        print("%@", userInfo)
        print("YEEERRRRRRRRRP")

    }
}


// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        // Print message ID.
        print("Message ID: \(userInfo["gcm.message_id"]!)")
        
        // Print full message.
        print("%@", userInfo)
        print("YEEESSSS")
    }
}

extension AppDelegate : FIRMessagingDelegate {
    // Receive data message on iOS 10 devices.
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        print("UHHHHH")
        MessageRouter.routeMessage(messageData: remoteMessage)
    }
}

