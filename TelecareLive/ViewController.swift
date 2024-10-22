//
//  ViewController.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 9/21/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import KeychainSwift
import SwiftOverlays

class ViewController: RestViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet weak var email: UITextField!

    @IBOutlet weak var password: UITextField!
    
    @IBAction func login(_ sender: AnyObject) {
        self.showWaitOverlayWithText("Logging In...")
        restManager?.logIn(username: email.text!, password: password.text!, caller: self, callback:loginSuccessful)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.removeAllOverlays()
    }
    
    @IBAction func register(_ sender: AnyObject) {
    }
    
    
    @IBAction func forgotPassword(_ sender: AnyObject) {
    }
    
    func loginSuccessful(restData: JSON){
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let tabBarViewController = storyBoard.instantiateViewController(withIdentifier: "TabBarController") as UIViewController
        appDelegate.window?.rootViewController = tabBarViewController
        appDelegate.window?.makeKeyAndVisible()
        print(tabBarViewController.childViewControllers.count)
        print("CHILD VIEW CONTROLLERS ABOVE")
        let firstController = tabBarViewController.childViewControllers[0] as? UINavigationController
        PersonManager.currentRestController = firstController?.topViewController as? RestViewController
        appDelegate.currentlyLoggedInPerson = PersonManager.getPersonUsing(json: restData)
        restManager?.updateFBToken()
        (tabBarViewController as! ProactiveTabBarController).trimTabBarController()
    }

    func loginFailed(){
        self.removeAllOverlays()
        let message = "The service could not be reached. Please check you internet connection."
        errorManager?.postErrorMessage(controller: self, message: message)
    }

}

