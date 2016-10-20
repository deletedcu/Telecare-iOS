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
    
    var currentConversation:Conversation? = Conversation()
    
    override func viewDidLoad() {
        //        tableView.register(ConversationCell.self, forCellReuseIdentifier: "ConversationCell")
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        newConsultView.delegate = self
        navigationController?.navigationBar.topItem?.title = ""
        tabBarController?.hidesBottomBarWhenPushed = true
        navTitle.title = currentConversation?.person?.fullName
        navigationController?.navigationBar.titleTextAttributes?["ForegroundColorAttributeName"] = UIColor.white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        navTitle.title = currentConversation?.person?.fullName
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
    
    override func refreshData(){
        tableView.reloadData()
    }
    
    func populate(restData: JSON){
//        print(restData)
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
        restManager?.launchNewConsult(charge: true, title: title, conversation:(currentConversation)!, callback: finishAddingNewConsult)
    }
    
    func addFreeConsult(title:String){
        self.showWaitOverlayWithText("Creating new free consult...")
        restManager?.launchNewConsult(charge: false, title: title, conversation:(currentConversation)!, callback: finishAddingNewConsult)
    }
    
    func finishAddingNewConsult(restData: JSON){
        print(restData)
        ConsultManager.populateConsultsForConversation(conversation: currentConversation!, withCallback:finishGettingAllConsults)
    }
    
    // SOOOO hacky... please fix... later
    func finishGettingAllConsults(conversation: Conversation, restData: JSON){
        var consults:[Consult] = []
        
        for(_,subJson) in restData["data"]{
            consults.append(ConsultManager.getConsultUsing(json: subJson))
        }
        
        conversation.consults = consults
        
        tableView.reloadData()
        let selectedIndexPath = IndexPath.init(row: 0, section: 0)
        tableView.selectRow(at: selectedIndexPath, animated: false, scrollPosition: UITableViewScrollPosition.top)
        performSegue(withIdentifier: "patientConsultChat", sender: nil)
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
        } else {
            cell.backgroundColor = UIColor.white
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.removeAllOverlays()
        switch segue.identifier! {
        case "patientConsultChat" :
            let destination = segue.destination as? ConsultChatViewController
            let row = (tableView.indexPathForSelectedRow?.row)!
            (destination! as AVCRestViewController).currentConversation = self.currentConversation
            destination?.currentConsult = destination?.currentConversation?.consults?[row]
            destination?.delegate = self
            ConsultManager.currentRestController = destination // well... it will be by the time the request completes
            ConsultManager.populateMessagesForConsult(consult: (destination?.currentConsult)!)
        default:break
        }
    }
    

    
}
