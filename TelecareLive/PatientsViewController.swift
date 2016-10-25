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
    
    var patients:[Conversation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tabBarController?.hidesBottomBarWhenPushed = true
        navigationController?.navigationBar.titleTextAttributes?["ForegroundColorAttributeName"] = UIColor.white
        let currentViewController = UIApplication.topViewController()
        print("CURRENT CONTROLLER " + String(describing: type(of: currentViewController)))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navTitle.title = "Patients"
    }
    
    override func refreshData(){
        restManager?.getAllConversations(person: (appDelegate.currentlyLoggedInPerson)!, callback: refreshTable)
    }
    
    func refreshTable(restData: JSON){
        self.patients = []
        
        for(_,jsonSub) in restData["data"] {
            self.patients.append(ConversationManager.getConversationUsing(json: jsonSub))
        }
        
        tableView.reloadData()
    }
    
    func getConversationsFailed(){
        let message = "Getting your conversations was unsuccessful. Check your internet connection and try again."
        errorManager?.postErrorMessage(controller: self, message: message)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.patients.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let conversation = self.patients[indexPath.row]

        let cell:ConversationCell = self.tableView.dequeueReusableCell(withIdentifier: "ConversationCell")! as! ConversationCell
        let person = conversation.person
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
                destination?.currentEid = self.patients[row].entityId
                destination?.currentConversation = self.patients[row]
        default:break
        }
    }
}
