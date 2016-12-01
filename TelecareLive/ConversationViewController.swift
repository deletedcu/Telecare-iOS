//
//  ConversationViewController.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 10/2/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class ConversationViewController : RestViewController, UITableViewDataSource, UITableViewDelegate, UINavigationBarDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var navTitle: UINavigationItem!
    
    var currentConversation:Conversation? = Conversation()
    
    @IBOutlet weak var chatInputField: UITextField!
    
    @IBOutlet weak var chatBarView: UIView!
    
    @IBOutlet weak var sendButton: UIButton!
    
    var originalFrameOriginX:CGFloat?
    
    var originalFrameOriginY:CGFloat?
    
    let picker = UIImagePickerController()
    
    var firstLoad:Bool? = false
    
    var refreshControl = UIRefreshControl()
    
    var messages:[Message] = []
    
    lazy var photoView: PhotoView = {
        let photoView = PhotoView()
        return photoView
    }()
    
    override func refreshData(){
        // tell refresh control it can stop showing up now
        if self.refreshControl.isRefreshing
        {
            self.refreshControl.endRefreshing()
        }
        
        restManager?.getAllMessages(entityId: currentEid!, callback: refreshTable)
    }
    
    func refreshTable(restData: JSON){
        self.messages = []
        
        print(restData["data"])
        
//        self.currentConversation = ConversationManager.getConversationUsing(json: restData["data"])
        navTitle.title = currentConversation?.person?.fullName
        
        for (_, subJson) in restData["data"]["messages"] {
            messages.append(ConversationManager.getMessageUsing(json: subJson))
        }
        
        tableView.reloadData()
        scrollToBottom()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        navigationController?.navigationBar.topItem?.title = ""
        self.tabBarController?.tabBar.isHidden = true
        originalFrameOriginX = self.view.frame.origin.x
        originalFrameOriginY = self.view.frame.origin.y

        navTitle.title = currentConversation?.person?.fullName
        hideKeyboardWhenViewTapped()

        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        firstLoad = true
        
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(self.refreshData), for: UIControlEvents.valueChanged)
        self.tableView?.addSubview(refreshControl)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.refreshData()
        navTitle.title = currentConversation?.person?.fullName
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    @IBAction func sendMessage(_ sender: AnyObject) {
        if(chatInputField.text! == ""){
            return
        }
        
        let message = Message()
        let messageText = chatInputField.text! as String
        message.message = messageText
        message.messageDate = Date()
        message.isCurrentUsers = true
        message.conversationId = currentConversation?.entityId
        messages.append(message)
        self.tableView.reloadData()
        
        restManager?.sendMessage(caller: self, message: message, callback: finishSendingMessage)
        chatInputField.text = ""
        self.dismissKeyboard()
    }
    
    func scrollToBottom(){
        if messages.count > 0 {
            tableView.scrollToRow(at: IndexPath.init(row: messages.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: !firstLoad!)
        }
    }
    
    // Refactor later... just get it done son(json.. haha... oh boy i've been at this too long)!
    func finishSendingMessage(message: Message, restData: JSON){
        self.refreshData()
        scrollToBottom()
    }
    
    func sendMessageFailed(message:Message){
        errorManager?.postErrorMessage(controller: self)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0{
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if ((notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y = originalFrameOriginY!
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        let cell:MessageCell = self.tableView.dequeueReusableCell(withIdentifier: "MessageCell")! as! MessageCell

        cell.message.text = message.message
        cell.messageDate.text = message.messageDate?.toDateTimeReadable()
        
        if(message.isCurrentUsers)!{
            cell.messageDate.textAlignment = NSTextAlignment.right
            cell.layoutMargins = UIEdgeInsetsMake(40, 100, 40, 10)
            cell.message.layoutMargins = UIEdgeInsetsMake(10, 10, 10, 10)
            cell.message.layer.cornerRadius = 10
            cell.message.layer.backgroundColor = UIColor.init(red: 0, green: 0.25, blue: 0.85, alpha: 0.25).cgColor
        } else {
            cell.messageDate.textAlignment = NSTextAlignment.left
            cell.layoutMargins = UIEdgeInsetsMake(40, 10, 40, 100)
            cell.message.layoutMargins = UIEdgeInsetsMake(10, 10, 10, 10)
            cell.message.layer.cornerRadius = 10
            cell.message.layer.backgroundColor = UIColor.init(red: 0, green: 0.75, blue: 0.25, alpha: 0.35).cgColor
        }
        
        return cell
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print(sender)
        print("ABOVE IS THE SENDER")
        switch segue.identifier! {
        case "viewPatientConsults" :
            let destination = segue.destination as? ConsultsViewController
            destination?.currentEid = self.currentConversation?.entityId
//            ConsultManager.currentRestController = destination // well... it will be by the time the request completes
//            ConsultManager.populateConsultsForConversation(conversation: (appDelegate.currentlyLoggedInPerson?.conversations?[self.currentRow!])!)
            destination?.currentConversation = self.currentConversation
        default:break
        }
    }
    
    func getPhotoFromLibrary(){
        picker.allowsEditing = false //2
        picker.sourceType = .photoLibrary //3
        present(picker, animated: true, completion: nil)//4
    }
    
    func getPhotoFromCamera(){
        if UIImagePickerController.availableCaptureModes(for: .rear) != nil {
            picker.allowsEditing = false
            picker.sourceType = UIImagePickerControllerSourceType.camera
            picker.cameraCaptureMode = .photo
            present(picker, animated: true, completion: nil)
        } else {
            noCamera()
        }
    }
    
    func noCamera(){
        let alertVC = UIAlertController(
            title: "No Camera",
            message: "Sorry, this device has no camera",
            preferredStyle: .alert)
        let okAction = UIAlertAction(
            title: "OK",
            style:.default,
            handler: nil)
        alertVC.addAction(okAction)
        present(alertVC,
                animated: true,
                completion: nil)
    }
    
    @IBAction func replaceImage(_ sender: UIButton) {
        photoView.displayView(onView: view)
    }
    
    override func handleDirectMessage(restData: JSON) {
        if(restData["data"]["staff_conversation"] == nil){
            let viewController:ConsultsViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ConsultsViewController") as! ConsultsViewController
            viewController.currentEid = restData["data"]["eid"].string!
            viewController.currentConversation = currentConversation
            self.navigationController?.pushViewController(viewController, animated: true)
            viewController.handleDirectMessage()
        } else {
            appDelegate.tabBarController?.selectedIndex = 1
            (UIApplication.topViewController() as! StaffViewController).handleDirectMessage(restData: restData)
        }
    }
}
