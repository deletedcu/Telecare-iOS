//
//  MCViewController.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 10/10/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import AlamofireImage

class MCViewController : RestViewController, UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var navTitle: UINavigationItem!
    
    var currentConversation:Conversation? = Conversation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tabBarController?.hidesBottomBarWhenPushed = true
        navigationController?.navigationBar.titleTextAttributes?["ForegroundColorAttributeName"] = UIColor.white
    }
    
    override func refreshData(){
        tableView.reloadData()
    }
    
    func getConsultsFailed(){
        let message = "Getting your consults was unsuccessful. Check your internet connection and try again."
        errorManager?.postErrorMessage(controller: self, message: message)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let consults = appDelegate.currentlyLoggedInPerson?.consults
        
        if(consults == nil){
            return 0
        } else {
            return (consults?.count)!
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let consult = appDelegate.currentlyLoggedInPerson?.consults?[indexPath.row]
        
        let cell:ConsultCell = self.tableView.dequeueReusableCell(withIdentifier: "MyConsultCell")! as! ConsultCell
        
        cell.issue.text = consult?.issue
        cell.birthdateField.text = "Birth Date : " + (consult?.birthdate?.toReadable())!
        cell.profileImage.image = consult?.userImage?.af_imageRoundedIntoCircle()
        
        if(consult?.status == "0"){
            cell.backgroundColor = UIColor.lightGray
        } else {
            cell.backgroundColor = UIColor.white
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case "myConsult" :
            let destination = segue.destination as? MCChatViewController
            let row = (tableView.indexPathForSelectedRow?.row)!
            (destination! as AVCRestViewController).currentConversation = self.currentConversation
            destination?.currentConsult = appDelegate.currentlyLoggedInPerson?.consults?[row]
            destination?.delegate = self
            ConsultManager.currentRestController = destination // well... it will be by the time the request completes
            ConsultManager.populateMessagesForConsult(consult: (destination?.currentConsult)!)
        default:break
        }
    }
    
    
    
}

