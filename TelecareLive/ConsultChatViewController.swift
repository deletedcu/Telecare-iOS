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

class ConsultChatViewController : AVCRestViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var navTitle: UINavigationItem!
            
    @IBOutlet weak var chatInputField: UITextField!
    
    @IBOutlet weak var chatBarView: UIView!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var attachmentButton: UIButton!
    
    @IBOutlet weak var consultSwitch: UISwitch!
    
    var lastPlayedUrl: String? = ""
    
    @IBAction func toggleConsultSwitch(_ sender: AnyObject) {
        if consultSwitch.isOn {
            consultSwitch.isOn = true
        } else {
            consultSwitch.isOn = false
        }
        restManager?.toggleConsultSwitch(consult:currentConsult!, callback: finishToggleConsult)
    }
    
    func finishToggleConsult(restData: JSON){
        if consultSwitch.isOn {
            currentConsult?.status = "1"
            chatInputField.isEnabled = true
        } else {
            currentConsult?.status = "0"
            chatInputField.isEnabled = false
        }
        self.refreshData()
    }
        
    @IBAction func playAudio(_ sender: MediaButton) {
        if(!(sender.message?.hasAudio)! || (consultSwitch.isOn == false)){
            return
        }
        
        if audioPlayer == nil || lastPlayedUrl != sender.message?.mediaUrl! {
            let sender = sender
            
            print((sender.message?.mediaUrl!)!)
            let mediaUrl = URL(string: (sender.message?.mediaUrl!)!)
            audioPlayer = AVPlayer(url: mediaUrl!)
            audioPlayer.play()
            lastPlayedUrl = (sender.message?.mediaUrl!)!
            
        } else {
            if (audioPlayer.rate != 0.0) {
                audioPlayer.pause()
            } else {
                audioPlayer.seek(to: CMTimeMake(0, 1))
                audioPlayer.play()
            }
        }
    }
    
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
        audioView.delegate = self
        picker.delegate = self
        
        navTitle.title = currentConversation?.person?.fullName
        
        if(currentConsult?.status == "1"){
            consultSwitch.isOn = true
        } else {
            consultSwitch.isOn = false
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    deinit {
        audioView.purgeAudioFiles()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (currentConsult?.messages?.count)!
    }
    
    @IBAction func showAttachmentActions(_ sender: AnyObject) {
        if (consultSwitch.isOn == false) {
            return
        }
        
        let optionMenu = UIAlertController(title: nil, message: "Select Attachment Type", preferredStyle: .actionSheet)
        
        let photoAction = UIAlertAction(title: "Take Photo", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.getPhotoFromCamera()
            print("Photo Taken")
        })
        
        let galleryAction = UIAlertAction(title: "Choose Photo from Gallery", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.getPhotoFromLibrary()
            print("Photo Chosen")
        })
        
        let recordAction = UIAlertAction(title: "Record Audio", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.audioView.displayView(onView: self.view)
            print("Audio Recorded")
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        
        optionMenu.addAction(photoAction)
        optionMenu.addAction(galleryAction)
        optionMenu.addAction(recordAction)
        optionMenu.addAction(cancelAction)
        
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    @IBAction func sendMessage(_ sender: AnyObject) {
        if((chatInputField.text! == "" && hasAttachment == false) || (consultSwitch.isOn == false)){
            return
        }
        
        let message = Message()
        let messageText = chatInputField.text! as String
        message.message = messageText
        message.messageDate = Date()
        message.isCurrentUsers = true
        message.conversationId = currentConversation?.entityId
        message.isUnread = true
        
        if hasAttachment! && attachmentType == "audio" {
            message.mediaUrl = audioUrl?.absoluteString
            message.hasAudio = true
            message.hasMedia = true
            message.fileMime = "audio/m4a"
        }
        
        if hasAttachment! && attachmentType == "image" && attachmentImage != nil{
            message.imageMedia = attachmentImage!
            message.hasMedia = true
        }
        
        message.consultId = currentConsult?.entityId
        
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
            
            cell.media.message = Message()
            
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
                cell.messageText.layoutMargins = UIEdgeInsetsMake(10, 10, 10, 10)
                cell.messageText.layer.cornerRadius = 10
                cell.messageText.layer.backgroundColor = UIColor.init(red: 0, green: 0.25, blue: 0.85, alpha: 0.25).cgColor
            } else {
                cell.messageDate.textAlignment = NSTextAlignment.left
                cell.layoutMargins = UIEdgeInsetsMake(40, 10, 40, 100)
                cell.messageText.layoutMargins = UIEdgeInsetsMake(10, 10, 10, 10)
                cell.messageText.layer.cornerRadius = 10
                cell.messageText.layer.backgroundColor = UIColor.init(red: 0, green: 0.75, blue: 0.25, alpha: 0.35).cgColor
            }
            
            if(consultSwitch.isOn == false){
                cell.backgroundColor = UIColor.lightGray
            } else {
                cell.backgroundColor = UIColor.white
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
            
            if(consultSwitch.isOn == false){
                cell.backgroundColor = UIColor.lightGray
            } else {
                cell.backgroundColor = UIColor.white
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
    
    func getPhotoFromLibrary(){
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
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

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        attachmentImage = chosenImage
        attachmentType = "image"
        hasAttachment = true
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
        attachmentImage = nil
    }
    
    override func viewWillDisappear(_ animated : Bool) {
        super.viewWillDisappear(animated)
        
        if (self.isMovingFromParentViewController){
            delegate?.refreshData()
        }
    }
}