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
        restManager?.logIn(username: email.text!, password: password.text!, caller: self, callback:loginSuccessful)
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
        appDelegate.currentlyLoggedInPerson = PersonManager.getPersonUsing(json: restData)
    }

    func loginFailed(){
        var message = "The service could not be reached. Please check you internet connection."
        
        if getCurrentErrorMessage() !=  "" {
            message = getCurrentErrorMessage()
        }
        
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
        //            let DestructiveAction = UIAlertAction(title: "Destructive", style: UIAlertActionStyle.destructive) { (result : UIAlertAction) -> Void in
        //                print("Destructive")
        //            }
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            print("OK")
        }
        //            alertController.addAction(DestructiveAction)
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
    }

}

