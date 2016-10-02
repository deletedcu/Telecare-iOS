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
    
    var errorManager:ErrorManager?
    
    var baseUrl = "http://dev-telecarelive.pantheonsite.io/api/v1/"
    
    var endpoints = [
        "login" : "auth",
        "getAccountData" : "user",
        "saveAccountData"     : "user",
        "getConversations"    : "conversations",
        "getMessagesP1"         : "conversation/",
        "getMessagesP2"         : "/messages"
    ]
    
    var keychain = KeychainSwift()
    
    init(){
        errorManager = (UIApplication.shared.delegate as! AppDelegate).errorManager
    }
    
    func primeManager(){
        sessionManager = (UIApplication.shared.delegate as! AppDelegate).sessionManager
    }
    
    func logIn(username: String, password: String, caller: ViewController, callback: @escaping (JSON)->()){
        
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
                
//                print(json)
                
                if(json["status"] == 200){
                    self.keychain.set(username, forKey: "username")
                    self.keychain.set(json["sid"].string!, forKey: "sid")
                    
//                    print(self.keychain.get("sid"))
                    
                    self.sessionManager?.lockSession = 0
                   callback(json)
                } else {
                    self.errorManager?.currentErrorMessage = json["message"].string!
                    self.sessionManager?.lockSession = -1
                    caller.loginFailed()
                }
                

            case .failure(let error):
//                print(error)
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
                    self.errorManager?.currentErrorMessage = json["message"].string!
                }
            case .failure(let error):
                print(error)
            }

        }
    }
    
    func saveAccountData(caller:AccountViewController, callback: @escaping (JSON)->()){
        
        // Refactor data handling to controller later
        let date = Date.init()
        var notifications = "1"
        
        if(!caller.notificationsToggle.isOn){
            notifications = "0"
        }
        
        let image = caller.profileImage.backgroundImage(for: UIControlState.normal)
        
        let parameters = [
            "registration_id":(sessionManager?.gcmId)!,
            "user_image":"data:image/png;base64," + (image?.toBase64())!,
            "user_full_name":caller.fullName.text!,
            "user_phone":caller.phone.text!,
            "user_birthdate":date.fromString(string: caller.birthday.text!).timeIntervalSince1970,
            "user_notifications":Int(notifications),
            "user_lock_code":caller.lockCode.text!
        ] as Dictionary<String,Any>
        
        print(parameters["encoded"])
        
        let headers: HTTPHeaders = [
            "NYTECHSID": getSid(),
            "Accept": "application/json"
        ]
        
        Alamofire.request(baseUrl + endpoints["saveAccountData"]!, method: .post, parameters: parameters, headers: headers)
            .responseJSON { response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                if(json["status"] == 200){
                    callback(json)
                } else {
                    print("In the Error")
                    print(json)
                    self.errorManager?.currentErrorMessage = json["message"].string!
                    caller.updateAccountFailed()
                }
            case .failure(let error):
                print(error)
            }
            
        }
    }
    
    func getAllConversations(person: Person, callback: @escaping (Person, JSON)->()){
        let headers: HTTPHeaders = [
            "NYTECHSID": getSid(),
            "Accept": "application/json"
        ]

        Alamofire.request(baseUrl + endpoints["getConversations"]!, headers: headers).validate().responseJSON{ response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                if(json["status"] == 200){
                    callback(person, json)
                } else {
                    print("In the Error")
                    print(json)
                    self.errorManager?.currentErrorMessage = json["message"].string!
//                    caller.getConversationsFailed() // Abstract this later
                }
            case .failure(let error):
                print(error)
            }
            
        }
    }
    
    // Decouple later
    func getAllMessages(conversation: Conversation, callback: @escaping (Conversation, JSON)->()){
        let headers: HTTPHeaders = [
            "NYTECHSID": getSid(),
            "Accept": "application/json"
        ]
        
        Alamofire.request(baseUrl + endpoints["getMessagesP1"]! + conversation.entityId! + endpoints["getMessagesP2"]!, headers: headers).validate().responseJSON{ response in
            switch response.result {
            case .success(let value):
                let json = JSON(value)
                
                if(json["status"] == 200){
                    callback(conversation, json)
                } else {
                    print("In the Error")
                    print(json)
                    self.errorManager?.currentErrorMessage = json["message"].string!
                    //                    caller.getConversationsFailed() // Abstract this later
                }
            case .failure(let error):
                print(error)
            }
            
        }
    }
    
    func sidIsValid(sid: String) -> Bool{
        
        primeManager()
        
        return false
    }
}
