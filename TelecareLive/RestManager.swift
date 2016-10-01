//
//  RestManager.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 9/27/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import KeychainSwift

class RestManager {
    
    var sessionManager:SessionManager?
    
    var baseUrl = "http://dev-telecarelive.pantheonsite.io/api/v1/"
    
    var endpoints = [
        "login" : "auth",
        "getAccountData" : "user",
        "saveAccountData": "user"
    ]
    
    var keychain = KeychainSwift()
    
    func primeManager(){
        sessionManager = (UIApplication.shared.delegate as! AppDelegate).sessionManager
    }
    
    func logIn(username: String, password: String, caller: ViewController){
        
        primeManager()
        
        let passcombination = username + ":" + password
        
        let headers: HTTPHeaders = [
            "Authorization": "Basic " + passcombination.toBase64(),
            "Accept": "application/json"
        ]

        Alamofire.request(baseUrl + endpoints["login"]!, headers: headers).validate().responseJSON{ response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                print(json)
                
                if(json["status"] == 200){
                    self.keychain.set(username, forKey: "username")
                    self.keychain.set(json["sid"].string!, forKey: "sid")
                    
                    print(self.keychain.get("sid"))
//                    print(keychain.get("username"))
//                    print("JSON: \(json)")
                    
                    self.sessionManager?.lockSession = 0
                    caller.loginSuccessful()
                    
                } else {
                    (UIApplication.shared.delegate as! AppDelegate).currentErrorMessage = json["message"].string!
                    self.sessionManager?.lockSession = -1
                    caller.loginFailed()
                }
                

            case .failure(let error):
                print(error)
                self.sessionManager?.lockSession = -1
            }
        }
    }
    
    func getSid() -> String{
        return keychain.get("sid")!
    }
    
    func getAccountData(caller: AccountViewController, callback: @escaping (JSON) ->()){
        let headers: HTTPHeaders = [
            "NYTECHSID": getSid(),
            "Accept": "application/json"
        ]
        
        print("EEEEEE")
        print(keychain.get("sid"))
        print(headers)

        
        Alamofire.request(baseUrl + endpoints["getAccountData"]!, headers: headers).validate().responseJSON{ response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                if(json["status"] == 200){
                    callback(json)
                } else {
                    print("In the Error")
                    print(json)
                    (UIApplication.shared.delegate as! AppDelegate).currentErrorMessage = json["message"].string!
                }
            case .failure(let error):
                print(error)
            }

        }
    }
    
    func saveAccountData(caller:AccountViewController, callback: @escaping (JSON)->()){
        
        // Refactor data handling to controller later
        var date = Date.init()
        var notifications = "1"
        
        if(!caller.notificationsToggle.isOn){
            notifications = "0"
        }
        
        var data = [
            "registration_id":(sessionManager?.gcmId)!,
            "encoded":"",
            "user_full_name":caller.fullName.text!,
            "user_phone":caller.phone.text!,
            "user_birthdate":String(date.fromString(string: caller.birthday.text!).timeIntervalSince1970),
            "user_notifications":notifications,
            "user_lock_code":caller.lockCode.text!
        ] as Dictionary<String,String>
        
        let headers: HTTPHeaders = [
            "NYTECHSID": getSid(),
            "Accept": "application/json"
        ]
        
//        Alamofire.request(baseUrl + endpoints["saveAccountData"]!, method: .post, headers: headers,  parameters: data).validate().responseJSON{ response in
//            switch response.result {
//            case .success(let value):
//                let json = JSON(value)
//                
//                if(json["status"] == 200){
//                    callback(json)
//                } else {
//                    print("In the Error")
//                    print(json)
//                    (UIApplication.shared.delegate as! AppDelegate).currentErrorMessage = json["message"].string!
//                }
//            case .failure(let error):
//                print(error)
//            }
//            
//        }
    }
    
    func sidIsValid(sid: String) -> Bool{
        
        primeManager()
        
        return false
    }
}
