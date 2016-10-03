//
//  ConversationViewController.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 10/2/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation
import UIKit

class ConversationViewController : RestViewController, UITableViewDataSource, UITableViewDelegate, UINavigationBarDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var navTitle: UINavigationItem!
    
    var currentConversation:Conversation? = Conversation()
    
    @IBOutlet weak var chatInputField: UITextField!
    
    @IBOutlet weak var chatBarView: UIView!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func refreshData(){
        tableView.reloadData()
        // TODO: FINISH THE KEYBOARD BUMPING THE TEXT FIELD UP
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        navigationController?.navigationBar.topItem?.title = ""
        self.tabBarController?.tabBar.isHidden = true
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (currentConversation?.messages?.count)!
    }
    
    @IBAction func didClickInChatBox(_ sender: AnyObject) {
        
    }
    
    @IBAction func sendMessage(_ sender: AnyObject) {
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = currentConversation?.messages?[indexPath.row]
        
        let cell:MessageCell = self.tableView.dequeueReusableCell(withIdentifier: "MessageCell")! as! MessageCell

        cell.message.text = message?.message
        cell.messageDate.text = message?.messageDate?.toDateTimeReadable()
        
        if(message?.isCurrentUsers)!{
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
}
