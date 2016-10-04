//
//  ConsultsViewController.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 10/3/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import AlamofireImage

class ConsultsViewController : RestViewController, UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var navTitle: UINavigationItem!
    
    var currentConversation:Conversation? = Conversation()
    
    override func viewDidLoad() {
        //        tableView.register(ConversationCell.self, forCellReuseIdentifier: "ConversationCell")
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
    
    func getConsultsFailed(){
        let message = "Getting your consults was unsuccessful. Check your internet connection and try again."
        errorManager?.postErrorMessage(controller: self, message: message)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let consults = currentConversation?.consults
        
        if(consults == nil){
            return 0
        } else {
            return (consults?.count)!
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let consult = currentConversation?.consults?[indexPath.row]
        
        let cell:ConsultCell = self.tableView.dequeueReusableCell(withIdentifier: "ConsultCell")! as! ConsultCell
        
        cell.issue.text = consult?.issue
        cell.birthdateField.text = "Birth Date : " + (consult?.birthdate?.toReadable())!
        cell.profileImage.image = consult?.userImage?.af_imageRoundedIntoCircle()
        
        if(consult?.status == "0"){
            cell.backgroundColor = UIColor.lightGray
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(sender)
        print("ABOVE IS THE SENDER")
        switch segue.identifier! {
        case "patientConsultChat" :
            let destination = segue.destination as? ConsultChatViewController
            let row = (tableView.indexPathForSelectedRow?.row)!
            destination?.currentConversation = currentConversation
            destination?.currentConsult = destination?.currentConversation?.consults?[row]
            ConsultManager.currentRestController = destination // well... it will be by the time the request completes
            ConsultManager.populateMessagesForConsult(consult: (destination?.currentConsult)!)
        default:break
        }
    }
}
