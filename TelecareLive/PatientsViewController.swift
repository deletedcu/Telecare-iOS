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
import AlamofireImage

class PatientsViewController : RestViewController, UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var navTitle: UINavigationItem!
        
    override func viewDidLoad() {
//        tableView.register(ConversationCell.self, forCellReuseIdentifier: "ConversationCell")
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tabBarController?.hidesBottomBarWhenPushed = true
        navigationController?.navigationBar.titleTextAttributes?["ForegroundColorAttributeName"] = UIColor.white
    }
    
    override func refreshData(){
        tableView.reloadData()
    }
    
    func populate(restData: JSON){
        print(restData)
    }
    
    func getConversationsFailed(){
        let message = "Getting your conversations was unsuccessful. Check your internet connection and try again."
        errorManager?.postErrorMessage(controller: self, message: message)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let conversations = appDelegate.currentlyLoggedInPerson?.conversations
        
        if(conversations == nil){
            return 0
        } else {
            return (conversations?.count)!
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let conversation = appDelegate.currentlyLoggedInPerson?.conversations?[indexPath.row]

        let cell:ConversationCell = self.tableView.dequeueReusableCell(withIdentifier: "ConversationCell")! as! ConversationCell
        let person = conversation?.person
        let fullname = person?.fullName!
        
        cell.nameField.text = fullname
        cell.birthdateField.text = "Birth Date : " + (person?.birthdate?.toReadable())!
        cell.profileImage.image = person?.userImage?.af_imageRoundedIntoCircle()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
  
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(sender)
        print("ABOVE IS THE SENDER")
        switch segue.identifier! {
            case "patientMessage" :
                let destination = segue.destination as? ConversationViewController
                let row = (tableView.indexPathForSelectedRow?.row)!
                destination?.currentConversation = appDelegate.currentlyLoggedInPerson?.conversations?[row]
                ConversationManager.currentRestController = destination // well... it will be by the time the request completes
                ConversationManager.populateMessagesForConversation(conversation: (destination?.currentConversation)!)
        default:break
        }
    }
}
