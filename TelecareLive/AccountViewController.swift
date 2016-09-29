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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        birthday.delegate = self
        
        restManager?.getAccountData(caller: self, callback: populate)
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
    
}
