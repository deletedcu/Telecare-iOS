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
        
    var refreshControl = UIRefreshControl()
    
    var consults:[Consult] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tabBarController?.hidesBottomBarWhenPushed = true
        navigationController?.navigationBar.titleTextAttributes?["ForegroundColorAttributeName"] = UIColor.white
        
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(refreshData), for: UIControlEvents.valueChanged)
        self.tableView?.addSubview(refreshControl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navTitle.title = "My Consults"
        self.refreshData()
    }
    
    override func refreshData(){
        // tell refresh control it can stop showing up now
        if self.refreshControl.isRefreshing
        {
            self.refreshControl.endRefreshing()
        }
        restManager?.getAllConsultsForCurrent(userId: (appDelegate.currentlyLoggedInPerson?.userId)!, callback: refreshTable)
    }
    
    func refreshTable(restData: JSON){
        self.consults = []
                
        for(_,subJson) in restData["data"]{
            consults.append(ConsultManager.getConsultUsing(json: subJson))
        }

        tableView.reloadData()
    }
    
    func getConsultsFailed(){
        let message = "Getting your consults was unsuccessful. Check your internet connection and try again."
        errorManager?.postErrorMessage(controller: self, message: message)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return consults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let consult = consults[indexPath.row]
        
        let cell:ConsultCell = self.tableView.dequeueReusableCell(withIdentifier: "MyConsultCell")! as! ConsultCell
        
        cell.issue.text = consult.issue
        cell.birthdateField.text = "Birth Date : " + (consult.birthdate?.toReadable())!
        cell.profileImage.image = consult.userImage?.af_imageRoundedIntoCircle()
        
        if(consult.status == "0"){
            cell.backgroundColor = UIColor.lightGray
        } else {
            cell.backgroundColor = UIColor.white
        }
        
        if consult.unreadCount != 0 {
            cell.accessoryView = UIView()
            createBadge(text: String(consult.unreadCount), view: cell.accessoryView!)
        } else {
            cell.accessoryView = UIView()
        }
        
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! ConsultCell
        if cell.accessoryView != nil {
            cell.accessoryView = UIView()
        }
        
        switch segue.identifier! {
        case "myConsult" :
            let destination = segue.destination as? MCChatViewController
            let row = (tableView.indexPathForSelectedRow?.row)!
            destination?.currentEid = consults[row].entityId;
            destination?.currentConsult = consults[row]
            destination?.delegate = self
        default:break
        }
    }
    
    override func handleDirectMessage(restData: JSON) {
        let viewController:MCChatViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MCChatViewController") as! MCChatViewController
        viewController.currentEid = restData["data"]["eid"].string!
        self.currentEid = restData["data"]["eid"].string!
        viewController.currentConversation = ConversationManager.getConversationUsing(json: restData["data"])
        self.navigationController?.pushViewController(viewController, animated: true)
        viewController.handleDirectMessage()
    }
    
}

