//
//  RESTViewController.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 9/27/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation
import UIKit

class RestViewController : UIViewController {
    
    var appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    var restManager: RestManager?
    
    var sessionManager: SessionManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        restManager = (UIApplication.shared.delegate as! AppDelegate).restManager!
        sessionManager = (UIApplication.shared.delegate as! AppDelegate).sessionManager!
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
}
