//
//  ActivityController.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 9/28/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import KeychainSwift

class AccountViewController : RestViewController, UITextFieldDelegate {
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var fullName: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var birthday: UITextField!
    @IBOutlet weak var phone: UITextField!
    @IBOutlet weak var lockCode: UITextField!
    @IBOutlet weak var notificationsToggle: UISwitch!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var activeField: UITextField?
    var originalContentInset: UIEdgeInsets?
    var originalScrollIndicatorInsets: UIEdgeInsets?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerForKeyboardNotifications()
        
        fullName.delegate = self
        email.delegate = self
        birthday.delegate = self
        phone.delegate = self
        lockCode.delegate = self
        
        originalContentInset = scrollView.contentInset
        originalScrollIndicatorInsets = scrollView.scrollIndicatorInsets
        
        restManager?.getAccountData(caller: self, callback: populate)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        deregisterFromKeyboardNotifications()
    }
    
    func populate(restData: JSON){
        print(restData)

        if (restData["data"]["user_image"].count < 1){
            profileImage.image = UIImage(named: "Default")
        } else {
            profileImage.setImageFromURl(stringImageUrl: restData["data"]["user_image"][0].string!)
        }
        
        fullName.text = restData["data"]["user_full_name"].string!
        email.text = restData["data"]["mail"].string!
        birthday.text = Date.init(timeIntervalSince1970: Double(restData["data"]["user_birthdate"].int!)).toReadable()
        phone.text = restData["data"]["user_phone"].string!
        lockCode.text = restData["data"]["user_lock_code"].string!
        
        if restData["data"]["user_notifications"] == 1{
            notificationsToggle.isOn = true
        } else {
            notificationsToggle.isOn = false
        }
    }
    
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        datePicker.date = Date().fromString(string: birthday.text!)
//        datePicker.isHidden = false
//        return true
//    }
    
    // Much thanks to http://blog.apoorvmote.com/change-textfield-input-to-datepicker/
    
    @IBAction func editBirthday(_ sender: AnyObject) {
        let datePicker:UIDatePicker = UIDatePicker()
        datePicker.date = Date().fromString(string: birthday.text!)
        birthday.inputView = datePicker
        datePicker.datePickerMode = UIDatePickerMode.date
        datePicker.addTarget(self, action: #selector(AccountViewController.selectDate), for: UIControlEvents.valueChanged)
    }

    func selectDate(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.long
        dateFormatter.timeStyle = DateFormatter.Style.none
        birthday.text = dateFormatter.string(from: sender.date)
    }
    
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func keyboardWasShown(notification: NSNotification){
        //Need to calculate keyboard exact size due to Apple suggestions
        let info : NSDictionary = notification.userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        if activeField != nil{
            if (!aRect.contains(activeField!.frame.origin)){
                self.scrollView.scrollRectToVisible(activeField!.frame, animated: true)
            }
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification){
        if(originalContentInset != nil){
            self.scrollView.contentInset = originalContentInset!
        }
        
        if(originalScrollIndicatorInsets != nil){
            self.scrollView.scrollIndicatorInsets = originalScrollIndicatorInsets!
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField){
            activeField = textField
    }
    
    func textFieldDidEndEditing(_ textField: UITextField){
            activeField = nil
    }
}
