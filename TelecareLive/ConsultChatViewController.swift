//
//  ConsultChatViewController.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 10/3/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import AVFoundation

class ConsultChatViewController : RestViewController, UITableViewDataSource, UITableViewDelegate, UINavigationBarDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var navTitle: UINavigationItem!
    
    var currentConversation:Conversation? = Conversation()
    
    var currentConsult:Consult? = Consult()
    
    @IBOutlet weak var chatInputField: UITextField!
    
    @IBOutlet weak var chatBarView: UIView!
    
    @IBOutlet weak var sendButton: UIButton!
    
    var originalFrameOriginX:CGFloat?
    
    var originalFrameOriginY:CGFloat?
    
    var audioPlayer:AVAudioPlayer?
    
    override func refreshData(){
        tableView.reloadData()
        // TODO: FINISH THE KEYBOARD BUMPING THE TEXT FIELD UP
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
        hideKeyboardWhenViewTapped()
        //        scrollToBottom()
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (currentConsult?.messages?.count)!
    }
    
    @IBAction func testAction(_ sender: AnyObject) {
        if audioPlayer == nil {
            audioPlayer = AVAudioPlayer()
            
            let sender = sender as? MediaButton
            
            do {
                let mediaUrl = URL(fileURLWithPath: (sender?.message?.mediaUrl)!)
                let sound = try AVAudioPlayer(contentsOf: mediaUrl)
                sound.play()
            } catch {
                let nsError = error as NSError
                print(nsError.localizedDescription)
            }
        } else {
            if (audioPlayer?.isPlaying)! {
                audioPlayer?.stop()
            } else {
                audioPlayer?.play()
            }
        }
    }
    
    @IBAction func showAttachmentActions(_ sender: AnyObject) {
        let optionMenu = UIAlertController(title: nil, message: "Select Attachment Type", preferredStyle: .actionSheet)
        
        let photoAction = UIAlertAction(title: "Take Photo", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Photo Taken")
        })
        
        let galleryAction = UIAlertAction(title: "Choose Photo from Gallery", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Photo Chosen")
        })
        
        let recordAction = UIAlertAction(title: "Record Audio", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Audio Recorded")
        })
        
        
        let chooseAudioAction = UIAlertAction(title: "Select Audio", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Audio Selected")
        })
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(photoAction)
        optionMenu.addAction(galleryAction)
        optionMenu.addAction(recordAction)
        optionMenu.addAction(chooseAudioAction)
        optionMenu.addAction(cancelAction)
        
        
        self.present(optionMenu, animated: true, completion: nil)
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
        currentConsult?.messages?.append(message)
        restManager?.sendConsultMessage(caller: self, message: message, callback: finishSendingMessage)
    }
    
    func scrollToBottom(){
        if((currentConsult?.messages?.count)! > 0){
                    tableView.scrollToRow(at: IndexPath.init(row: (currentConsult?.messages?.count)! - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
        }
    }
    
    // Refactor later... just get it done son(json.. haha... oh boy i've been at this too long)!
    func finishSendingMessage(message: Message, restData: JSON){
        ConsultManager.populateMessagesForConsult(consult: (self.currentConsult)!)
        chatInputField.text = ""
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
        let message = currentConsult?.messages?[indexPath.row]
        
        print(message)
        if(message?.hasMedia)!{
            let cell:MediaMessageCell = self.tableView.dequeueReusableCell(withIdentifier: "MediaMessageCell")! as! MediaMessageCell
            
            if((message?.hasAudio)! && message?.imageMedia != nil){
                cell.media.setBackgroundImage(UIImage(named: "AudioIcon"), for: UIControlState.normal)
                cell.media.message = message
            } else {
                cell.media.setBackgroundImage(message?.imageMedia, for: UIControlState.normal)
            }
            cell.messageDate.text = message?.messageDate?.toDateTimeReadable()

            cell.messageText.text = message?.message
            
            if(message?.isCurrentUsers)!{
                cell.messageDate.textAlignment = NSTextAlignment.right
                cell.layoutMargins = UIEdgeInsetsMake(40, 100, 40, 10)
//                cell.media.layoutMargins = UIEdgeInsetsMake(10, 10, 10, 10)
//                cell.media.layer.cornerRadius = 10
//                cell.media.layer.backgroundColor = UIColor.init(red: 0, green: 0.25, blue: 0.85, alpha: 0.25).cgColor
                cell.messageText.layoutMargins = UIEdgeInsetsMake(10, 10, 10, 10)
                cell.messageText.layer.cornerRadius = 10
                cell.messageText.layer.backgroundColor = UIColor.init(red: 0, green: 0.25, blue: 0.85, alpha: 0.25).cgColor
            } else {
                cell.messageDate.textAlignment = NSTextAlignment.left
                cell.layoutMargins = UIEdgeInsetsMake(40, 10, 40, 100)
//                cell.media.layoutMargins = UIEdgeInsetsMake(10, 10, 10, 10)
//                cell.media.layer.cornerRadius = 10
//                cell.media.layer.backgroundColor = UIColor.init(red: 0, green: 0.75, blue: 0.25, alpha: 0.35).cgColor
                cell.messageText.layoutMargins = UIEdgeInsetsMake(10, 10, 10, 10)
                cell.messageText.layer.cornerRadius = 10
                cell.messageText.layer.backgroundColor = UIColor.init(red: 0, green: 0.75, blue: 0.25, alpha: 0.35).cgColor
            }
            
            return cell
        } else {
            
            let cell:ConsultMessageCell = self.tableView.dequeueReusableCell(withIdentifier: "ConsultMessageCell")! as! ConsultMessageCell
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
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
}
