//
//  PinViewController.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 9/27/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation
import UIKit

class PinViewController : RestViewController {
    
    var delegate: UIViewController?
    
    @IBOutlet weak var pinNumberField: UITextField!
    
    @IBAction func submitPin(_ sender: AnyObject) {
        if(pinNumberField.text == appDelegate.currentlyLoggedInPerson?.lockCode){
            sessionManager?.lockSession = 0
            appDelegate.pinViewIsUp = false
            self.dismiss(animated: true, completion: nil)
        } else {
            errorManager?.postErrorMessage(controller: self, message: "Incorrect Pin Code. Please try again")
        }
    }
    
    @IBAction func resetPin(_ sender: AnyObject) {
        UIApplication.shared.open(URL(string: "http://www.stackoverflow.com")!, options: [:], completionHandler: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
