//
//  StaffViewController.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 10/7/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class StaffViewController : RestViewController, UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var navTitle: UINavigationItem!
    
    override func viewDidLoad() {
        tableView.delegate = self
        tableView.dataSource = self
        tabBarController?.hidesBottomBarWhenPushed = true
        navigationController?.navigationBar.titleTextAttributes?["ForegroundColorAttributeName"] = UIColor.white
    }
    
    override func refreshData(){
        tableView.reloadData()
    }
    
    // MARK: - UITableViewDelegate Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let conversations = appDelegate.currentlyLoggedInPerson?.staffConversations
        
        if(conversations == nil){
            return 0
        } else {
            return (conversations?.count)!
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let conversation = appDelegate.currentlyLoggedInPerson?.staffConversations?[indexPath.row]
        
        let cell:ConversationCell = self.tableView.dequeueReusableCell(withIdentifier: "ConversationCell")! as! ConversationCell
        let person = conversation?.person
        let fullname = person?.fullName!
        
        cell.nameField.text = fullname
        cell.profileImage.image = person?.userImage?.af_imageRoundedIntoCircle()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    // MARK: - Segue Methods
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(sender)
        print("ABOVE IS THE SENDER")
        switch segue.identifier! {
        case "staffMessage" :
            let destination = segue.destination as? AVCRestViewController
            let row = (tableView.indexPathForSelectedRow?.row)!
            destination?.delegate = self
            destination?.currentConversation = appDelegate.currentlyLoggedInPerson?.staffConversations?[row]
            ConversationManager.currentRestController = destination // well... it will be by the time the request completes
            ConversationManager.populateMessagesForStaffConversation(conversation: (destination?.currentConversation)!)
        default:break
        }
    }
}
