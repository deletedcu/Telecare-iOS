//
//  ConversationViewController.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 10/2/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation
import UIKit

class ConversationViewController : RestViewController, UITableViewDataSource, UITableViewDelegate, UINavigationBarDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var navTitle: UINavigationItem!
    
    var currentConversation:Conversation? = Conversation()
    
    @IBOutlet weak var navbarTitle: UINavigationItem!
    
    override func refreshData(){
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        navigationController?.navigationBar.topItem?.title = ""
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (currentConversation?.messages?.count)!
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
        } else {
            cell.messageDate.textAlignment = NSTextAlignment.left
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
