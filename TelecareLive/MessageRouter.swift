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
import SwiftyJSON

class MessageRouter {
    static var appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    static var restManager = (UIApplication.shared.delegate as! AppDelegate).restManager
    
    static var sessionManager = (UIApplication.shared.delegate as! AppDelegate).sessionManager
    
    static var errorManager = (UIApplication.shared.delegate as! AppDelegate).errorManager
    
    static func routeMessage(messageData: [AnyHashable:Any], directRoute: Bool){
        let currentViewController = UIApplication.topViewController()
        
        
        print(messageData)
        
        // Refactor later?
        if(!directRoute){
            switch currentViewController {
            case is MCChatViewController:
                print ("IS MCChat")
                let localController:MCChatViewController = currentViewController as! MCChatViewController
                if messageData["eid"] as? String == localController.currentEid {
                    localController.refreshData()
                }
                break
            case is StaffConversationViewController:
                print ("IS StaffConversation")
                let localController:StaffConversationViewController = currentViewController as! StaffConversationViewController
                if messageData["eid"] as? String == localController.currentEid {
                    localController.refreshData()
                }
                break
            case is DSConversationViewController:
                print ("IS DSConversation")
                let localController:DSConversationViewController = currentViewController as! DSConversationViewController
                if messageData["eid"] as? String == localController.currentEid {
                    localController.refreshData()
                }
                break
            case is ConversationViewController:
                print ("IS Conversation")
                let localController:ConversationViewController = currentViewController as! ConversationViewController
                if messageData["eid"] as? String == localController.currentEid {
                    localController.refreshData()
                }
                break
            case is ConsultChatViewController:
                print ("IS ConsultChat")
                let localController:ConsultChatViewController = currentViewController as! ConsultChatViewController
                if messageData["eid"] as? String == localController.currentEid {
                    localController.refreshData()
                }
                break
            default:
                print ("IS Other")
                break
            }
        } else {
            if messageData["type"] != nil {
                if messageData["type"] as! String == "consult" {
                    appDelegate.resetViewToRootViewController()
                    getConsultForDirectRoute()
                } else if messageData["type"] as! String == "conversation" {
                    appDelegate.resetViewToRootViewController()
                    getConversationForDirectRoute()
                }
            }
        }
    }
    
    static func getConsultForDirectRoute(){
        print("consult")
        restManager?.getConsult(entityId:self.appDelegate.currentBackgroundNotificationPayload?["eid"] as! String, callback: finishDirectRouteMessageForConsult)
    }

    static func getConversationForDirectRoute(){
        print("conversation")
        restManager?.getConversation(entityId:self.appDelegate.currentBackgroundNotificationPayload?["eid"] as! String, callback: finishDirectRouteMessageForConversation)
    }
    
    static func finishDirectRouteMessageForConsult(restData: JSON){
        appDelegate.tabBarController?.selectedIndex = 0
        let currentViewController = UIApplication.topViewController() as! RestViewController
        currentViewController.handleDirectMessage(restData: restData)
    }
    
    static func finishDirectRouteMessageForConversation(restData: JSON){
        print(restData["data"])
        
        var isStaffConversation = false
        
        if let staffConversation = restData["data"]["staff_conversation"].string {
            if staffConversation == "1" {
                isStaffConversation = true
            }
        }
        
        if (appDelegate.currentlyLoggedInPerson?.isDoctor)! && !isStaffConversation{
            appDelegate.tabBarController?.selectedIndex = 0
        } else {
            appDelegate.tabBarController?.selectedIndex = 1
        }
        
        let currentViewController = UIApplication.topViewController() as! RestViewController
        currentViewController.handleDirectMessage(restData: restData)

    }
}
