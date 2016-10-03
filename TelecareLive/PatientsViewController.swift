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

class PatientsViewController : RestViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
//        tableView.register(ConversationCell.self, forCellReuseIdentifier: "ConversationCell")
        tableView.delegate = self
        tableView.dataSource = self
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
        ConversationManager.populateMessagesForConversation(conversation: (appDelegate.currentlyLoggedInPerson?.conversations?[indexPath.row])!)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(sender)
        print("ABOVE IS THE SENDER")
        switch segue.identifier! {
            case "patientMessage" :
                let destination = segue.destination as? ConversationViewController
                
                destination?.currentConversation = appDelegate.currentlyLoggedInPerson?.conversations?[(tableView.indexPathForSelectedRow?.row)!]

            default:break
        }
    }
}
