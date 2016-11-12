//
//  StaffConversationViewController.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 10/8/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import AVFoundation
import AlamofireImage
import SwiftOverlays

class StaffConversationViewController : AVCRestViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var navTitle: UINavigationItem!
            
    @IBOutlet weak var chatInputField: UITextField!
    
    @IBOutlet weak var chatBarView: UIView!
    
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var attachmentButton: UIButton!
    
    var messages:[Message] = []
    
    var lastPlayedUrl: String? = ""
    
    @IBAction func playMedia(_ sender: MediaButton) {
        if !(sender.message?.hasMedia)! {
            return
        }

        self.showWaitOverlayWithText("Loading Image...")
        
        if(!(sender.message?.hasAudio)!){
            if (sender.message?.hasMedia)! {
                openImage(message: sender.message!)
            }
        } else {
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
            self.removeAllOverlays()
        }
    }
    
    override func refreshData(){
        restManager?.getAllStaffMessages(entityId: currentEid!, callback: refreshTable)
    }
    
    func refreshTable(restData: JSON){
        self.messages = []
        
        for (_, subJson) in restData["data"]["messages"] {
            messages.append(ConsultManager.getConsultMessageUsing(json: subJson))
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
        navigationController?.navigationBar.titleTextAttributes?["ForegroundColorAttributeName"] = UIColor.white
        navigationController?.navigationBar.tintColor = UIColor.white;
        
        originalFrameOriginX = self.view.frame.origin.x
        originalFrameOriginY = self.view.frame.origin.y
        hideKeyboardWhenViewTapped()
        audioView.delegate = self
        picker.delegate = self
                
        navTitle.title = currentConversation?.person?.fullName
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    @IBAction func showAttachmentActions(_ sender: AnyObject) {
        
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
        if((chatInputField.text! == "" && hasAttachment == false)){
            return
        }
        
        let message = Message()
        let messageText = chatInputField.text! as String
        message.message = messageText
        message.messageDate = Date()
        message.isCurrentUsers = true
        message.consultId = currentConversation?.entityId
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
        
        messages.append(message)
        restManager?.sendConsultMessage(caller: self, message: message, callback: finishSendingMessage)
        self.tableView?.reloadData()
        self.dismissKeyboard()
        self.showWaitOverlayWithText("Sending your message...")
    }
    
    func scrollToBottom(){
        if messages.count > 0 {
            self.tableView.scrollToRow(at: IndexPath.init(row: messages.count - 1, section: 0), at: UITableViewScrollPosition.bottom, animated: true)
        }
    }
    
    // Refactor later... just get it done son(json.. haha... oh boy i've been at this too long)!
    func finishSendingMessage(message: Message, restData: JSON){
        self.refreshData()
        chatInputField.text = ""
        self.removeAllOverlays()
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        print(message)
        if(message.hasMedia)!{
            let cell:MediaMessageCell = self.tableView.dequeueReusableCell(withIdentifier: "MediaMessageCell")! as! MediaMessageCell
            
            cell.media.message = Message()
            cell.media.message?.hasMedia = message.hasMedia
            
            if((message.hasAudio)! && message.imageMedia != nil){
                cell.media.message?.hasAudio = message.hasAudio
                cell.media.message?.imageMedia = message.imageMedia
                cell.media.setBackgroundImage(UIImage(named: "AudioIcon"), for: UIControlState.normal)
                cell.media.message = message
            } else {
                var buttonFrame = cell.media.frame
                buttonFrame.size = CGSize(width: 200, height: 200)
                cell.media.frame = buttonFrame
                
                let image = message.imageMedia?.af_imageAspectScaled(toFit: cell.media.frame.size)
                cell.media.setBackgroundImage(image, for: UIControlState.normal)
                cell.media.message?.mediaUrl = message.mediaUrl
            }
            cell.messageDate.text = message.messageDate?.toDateTimeReadable()
            
            cell.messageText.text = message.message
            
            if(message.isCurrentUsers)!{
                cell.media.message?.isCurrentUsers = message.isCurrentUsers
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
            
            return cell
        } else {
            
            let cell:ConsultMessageCell = self.tableView.dequeueReusableCell(withIdentifier: "ConsultMessageCell")! as! ConsultMessageCell
            
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
        let chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage //2
        attachmentImage = chosenImage
        attachmentType = "image"
        hasAttachment = true
        dismiss(animated: true, completion: nil) //5
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
        self.removeAllOverlays()
    }
    
    func openImage(message: Message){
        DispatchQueue.main.async {
            let destination = self.storyboard?.instantiateViewController(withIdentifier: "ImageViewController") as! ImageViewController
            (destination as ImageViewController).currentMessage = message
            destination.delegate = self
            self.present(destination, animated: true, completion: nil)
        }
    }
    
}
