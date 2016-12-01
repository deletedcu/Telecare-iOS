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
import SwiftyJSON
import KeychainSwift

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
    
    var currentBackgroundNotificationPayload:[AnyHashable:Any]? = [:]
    
    var controllerStack:[UIViewController]? = []

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
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
        
        FIRApp.configure()
        
        if FIRInstanceID.instanceID().token() != nil {
            FBToken = FIRInstanceID.instanceID().token()!
        } else {
            FBToken = ""
        }
        
        print("TOKEN!" + FBToken!)
        
        errorManager = ErrorManager()
        restManager = RestManager()
        sessionManager = SessionManager()
        
        let keychain = KeychainSwift()
        let sid = keychain.get("sid")
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let firstViewController = storyBoard.instantiateViewController(withIdentifier: "loadingController") as! LoadingController
        
        self.window?.rootViewController = firstViewController
        self.window?.makeKeyAndVisible()
        
        firstViewController.showTextOverlay("Loading...")
        
        if(sid != nil){
            restManager?.sidIsValid(sid: sid!, callback: finishLoadingFirstScreen)
        } else {
            var restData = JSON([])
            restData["status"] = 500
            finishLoadingFirstScreen(restData: restData)
        }
        
        return true
    }
    
    func finishLoadingFirstScreen(restData: JSON){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        
        if(restData["status"] == 200){
            if(currentlyLoggedInPerson == nil){
                currentlyLoggedInPerson = PersonManager.getPersonUsing(json: restData)
                resetViewToRootViewController()
            }
            
            if(sessionManager?.lockSession != 1 && !pinViewIsUp!){
                sessionManager?.lockSession = 1
                
                let pinViewController = storyBoard.instantiateViewController(withIdentifier: "PinViewController") as! PinViewController
                
                window?.rootViewController?.present(pinViewController, animated: true, completion: nil)
                
                pinViewIsUp = true
            }
        } else {
            let firstViewController = storyBoard.instantiateViewController(withIdentifier: "ViewController") as UIViewController
           window?.rootViewController = firstViewController
        }
        
        self.window?.makeKeyAndVisible()
    }

    func applicationWillResignActive(_ application: UIApplication) {

    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        let topViewController = UIApplication.topViewController()
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let pinViewController = storyBoard.instantiateViewController(withIdentifier: "PinViewController") as! PinViewController
        
        print(String(describing: type(of: topViewController)))
        
        if topViewController is ViewController || pinViewIsUp! {
            return
        }
        
        sessionManager?.lockSession = 1
        
        pinViewController.delegate = topViewController
        topViewController?.present(pinViewController, animated: false, completion: nil)
        pinViewIsUp = true
        
        self.currentBackgroundNotificationPayload = [:]
        
        FIRMessaging.messaging().disconnect()
        print("Disconnected from FCM.")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        let keychain = KeychainSwift()
        let sid = keychain.get("sid")
                
        if FIRInstanceID.instanceID().token() != nil {
            FBToken = FIRInstanceID.instanceID().token()!
        } else {
            FBToken = ""
        }
        
        if(sid != nil){
            restManager?.sidIsValid(sid: sid!, callback: finishLoadingFirstScreen)
        } else {
            var restData = JSON([])
            restData["status"] = 500
            finishLoadingFirstScreen(restData: restData)
        }
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func resetViewToLogin(){
        FBToken = ""
        restManager?.updateFBToken()
        sessionManager?.clearSession()
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let firstViewController = storyBoard.instantiateViewController(withIdentifier: "ViewController") as UIViewController
        self.window?.rootViewController = firstViewController
        self.window?.makeKeyAndVisible()
    }
    
    func resetViewToRootViewController(){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarViewController = storyBoard.instantiateViewController(withIdentifier: "TabBarController") as UIViewController
        (tabBarViewController as! ProactiveTabBarController).trimTabBarController()
        window?.rootViewController = nil
        window?.rootViewController = tabBarViewController
        window?.makeKeyAndVisible()
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
        
        self.currentBackgroundNotificationPayload = userInfo
        // Actually handled in the pinController
    }
}


// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let data = notification.request.content.userInfo
        // Print message ID.
        print("Message ID: \(data["gcm.message_id"]!)")
        
        // Print full message.
        print("%@", data)
        print("YEEESSSS")
        MessageRouter.routeMessage(messageData: data, directRoute: false)
    }
}

extension AppDelegate : FIRMessagingDelegate {
    // Receive data message on iOS 10 devices.
    func applicationReceivedRemoteMessage(_ remoteMessage: FIRMessagingRemoteMessage) {
        print("UHHHHH")
        //MessageRouter.routeMessage(messageData: remoteMessage, directRoute: false)
    }
}

