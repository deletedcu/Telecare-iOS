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
import SwiftOverlays

class ConsultsViewController : RestConsultViewController, UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate, UIGestureRecognizerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var navTitle: UINavigationItem!
    
    var refreshControl = UIRefreshControl()
    
    var currentConversation:Conversation? = Conversation()
    
    var consults:[Consult] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        newConsultView.delegate = self
        navigationController?.navigationBar.topItem?.title = ""
        tabBarController?.hidesBottomBarWhenPushed = true
        navTitle.title = currentConversation?.person?.fullName
        navigationController?.navigationBar.titleTextAttributes?["ForegroundColorAttributeName"] = UIColor.white
        
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(self.refreshData), for: UIControlEvents.valueChanged)
        self.tableView?.addSubview(refreshControl)
    }
    
    override func refreshData(){
        // tell refresh control it can stop showing up now
        if self.refreshControl.isRefreshing
        {
            self.refreshControl.endRefreshing()
        }
        
        restManager?.getAllConsults(userId: (currentConversation?.person?.userId)!, callback: refreshTable)
    }
    
    func refreshTable(restData: JSON){
        self.consults = []
        
        for(_,subJson) in restData["data"]{
            consults.append(ConsultManager.getConsultUsing(json: subJson))
        }
        
        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navTitle.title = currentConversation?.person?.fullName
        self.refreshData()
    }
    
    func closeNewConsultViewWhenTapped(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissNewConsultView))
        view.addGestureRecognizer(tap)
    }
    
    func removeCloseNewConsultViewWhenTapped(){
        view.gestureRecognizers = []
    }
    
    func dismissNewConsultView(){
        if(newConsultView.isDescendant(of: self.view)){
            newConsultView.hideView()
        }
    }
    
    lazy var newConsultView: NewConsult = {
        let newConsultView = NewConsult()
        return newConsultView
    }()
    
    
    @IBAction func addNewConsult(_ sender: AnyObject) {
        closeNewConsultViewWhenTapped()
        self.newConsultView.displayView(onView: self.view)
    }
    
    func addChargedConsult(title:String){
        self.showWaitOverlayWithText("Creating new paid consult...")
        restManager?.launchNewConsult(charge: true, title: title, conversation:(currentConversation)!, callback: finishAddingConsult)
    }
    
    func addFreeConsult(title:String){
        self.showWaitOverlayWithText("Creating new free consult...")
        restManager?.launchNewConsult(charge: false, title: title, conversation:(currentConversation)!, callback: finishAddingConsult)
    }
    
    func finishAddingConsult(restData: JSON){
        restManager?.getAllConsults(userId: (currentConversation?.person?.userId)!, callback: refreshToAddedConsult)
        
    }
    
    func refreshToAddedConsult(restData: JSON){
        refreshTable(restData: restData)
        
        let selectedIndexPath = IndexPath.init(row: 0, section: 0)
        tableView.selectRow(at: selectedIndexPath, animated: false, scrollPosition: UITableViewScrollPosition.top)
        performSegue(withIdentifier: "patientConsultChat", sender: nil)
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
        
        let cell:ConsultCell = self.tableView.dequeueReusableCell(withIdentifier: "ConsultCell")! as! ConsultCell
        
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
        
        self.removeAllOverlays()
        switch segue.identifier! {
        case "patientConsultChat" :
            let destination = segue.destination as? ConsultChatViewController
            let row = (tableView.indexPathForSelectedRow?.row)!
            destination?.currentEid = consults[row].entityId
            destination?.currentConsult = consults[row]
            (destination! as AVCRestViewController).currentConversation = self.currentConversation
        default:break
        }
    }
    
    override func handleDirectMessage() {
        let viewController:ConsultChatViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ConsultChatViewController") as! ConsultChatViewController
        viewController.currentEid = currentEid
        self.currentEid = currentConversation?.entityId
        viewController.currentConversation = currentConversation
        self.navigationController?.pushViewController(viewController, animated: true)
        viewController.handleDirectMessage()
    }
    
}
