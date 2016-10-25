//
//  MessageRouter.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 10/16/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class MessageRouter {
    static var appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    static var restManager = (UIApplication.shared.delegate as! AppDelegate).restManager
    
    static var sessionManager = (UIApplication.shared.delegate as! AppDelegate).sessionManager
    
    static var errorManager = (UIApplication.shared.delegate as! AppDelegate).errorManager
    
    static func routeMessage(messageData: FIRMessagingRemoteMessage){
//        let data = messageData.appData
        
        let currentViewController = UIApplication.topViewController()

        switch currentViewController {
            case is MCChatViewController:
                print ("IS MCChat")
                break
            case is StaffConversationViewController:
                print ("IS StaffConversation")
                break
            case is DSConversationViewController:
                print ("IS DSConversation")
                break
            case is ConversationViewController:
                print ("IS Conversation")
                break
            case is ConsultChatViewController:
                print ("IS ConsultChat")
                break
            default:
                print ("IS Other")
                break
        }
        
    }
}
