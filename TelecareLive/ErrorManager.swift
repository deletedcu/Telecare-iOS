//
//  ErrorManager.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 10/1/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation
import UIKit

class ErrorManager {
    var currentErrorMessage:String? = ""
    
    func postErrorMessage(controller: UIViewController, message: String? = ""){
        
        var localMessage = message
        
        if currentErrorMessage !=  "" {
            localMessage = currentErrorMessage
        }
        
        let alertController = UIAlertController(title: "Error", message: localMessage, preferredStyle: UIAlertControllerStyle.alert)
        //            let DestructiveAction = UIAlertAction(title: "Destructive", style: UIAlertActionStyle.destructive) { (result : UIAlertAction) -> Void in
        //                print("Destructive")
        //            }
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) { (result : UIAlertAction) -> Void in
            print("OK")
        }
        //            alertController.addAction(DestructiveAction)
        alertController.addAction(okAction)
        controller.present(alertController, animated: true, completion: nil)
    }
}
