//
//  AppDelegate.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 9/21/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    var restManager: RestManager?
    
    var sessionManager: SessionManager?
        
    var currentlyLoggedInPerson: Person?
    
    var errorManager: ErrorManager?
    
    var pinViewIsUp:Bool? = false
    
    var tabBarController:ProactiveTabBarController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
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
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
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


}

