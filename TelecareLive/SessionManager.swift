//
//  SessionManager.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 9/27/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation
import UIKit
import KeychainSwift

class SessionManager{
    
    var restManager:RestManager?
    
    var gcmId = ""
    
    var lockSession = -1 // Perhapms move this to a permanent store
    
    func primeManager(){
        restManager = (UIApplication.shared.delegate as! AppDelegate).restManager
    }
    
//    func sessionIsActive() -> Bool{
//        
//        primeManager()
//        
//        let keychain = KeychainSwift()
//        let sid = keychain.get("sid")
//        
//        if (sid != nil) {
//            if (restManager?.sidIsValid(sid: sid!))! {
//                return true
//            }
//        }
//        
//        return false
//    }
    
//    func finishIsSessionActive(){
//        
//    }
    
    func clearSession(){
        let keychain = KeychainSwift()
        keychain.set("", forKey: "sid")
    }
}
