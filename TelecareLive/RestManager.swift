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
        "getAccountData" : "user"
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
    
    func sidIsValid(sid: String) -> Bool{
        
        primeManager()
        
        return false
    }
}
