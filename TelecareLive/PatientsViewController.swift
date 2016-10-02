//
//  PatientsViewController.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 10/1/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class PatientsViewController : RestViewController {

    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        
    }
    
    override func refreshData(){
//        restManager?.getAllConversations(person: self, callback: populate)
    }
    
    func populate(restData: JSON){
        
    }
    
    func getConversationsFailed(){
        var message = "Getting your conversations was unsuccessful. Check your internet connection and try again."
        
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
