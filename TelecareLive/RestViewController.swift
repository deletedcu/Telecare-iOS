//
//  RESTViewController.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 9/27/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation
import UIKit

class RestViewController : UIViewController, UITabBarControllerDelegate {
    
    var appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    var restManager: RestManager?
    
    var sessionManager: SessionManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        restManager = (UIApplication.shared.delegate as! AppDelegate).restManager!
        sessionManager = (UIApplication.shared.delegate as! AppDelegate).sessionManager!
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.delegate = self
    }
    
    func getCurrentErrorMessage() -> String {
        return appDelegate.currentErrorMessage
    }
    
    func resetCurrentErrorMessage(){
        appDelegate.currentErrorMessage = ""
    }
    
    func setCurrentErrorMessage(message: String) {
        appDelegate.currentErrorMessage = message
    }
    
    func refreshData(){
        
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        self.refreshData()
    }
}
