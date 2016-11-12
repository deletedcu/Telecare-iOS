//
//  ConversationManager.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 10/1/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON

class ConversationManager : ModelManager{
//    static func populateMessagesForConversation(conversation: Conversation){
//        restManager?.getAllMessages(entityId: conversation, callback: finishGettingAllMessages)
//    }
//    
//    static func populateMessagesForStaffConversation(conversation: Conversation){
//        restManager?.getAllStaffMessages(conversation: conversation, callback: finishGettingAllStaffMessages)
//    }
    
    static func finishGettingAllMessages(conversation: Conversation, restData: JSON){
        var messages: [Message] = []
        
        // FINISH THIS OUT
        
        for (_, subJson) in restData["data"]["messages"] {
            messages.append(ConversationManager.getMessageUsing(json: subJson))
        }
        
        conversation.messages = messages
        
        currentRestController?.refreshData()
    }
    
    static func finishGettingAllStaffMessages(conversation:Conversation, restData: JSON){
        print(restData)
        var messages: [Message] = []
        
        // FINISH THIS OUT
        
        for (_, subJson) in restData["data"]["messages"] {
            messages.append(ConsultManager.getConsultMessageUsing(json: subJson))
        }
        
        conversation.messages = messages
        
        currentRestController?.refreshData()
    }
    
    static func getConversationUsing(json: JSON)-> Conversation{
        let conversation = Conversation()
        
        print(json)
        
        // Eventually always check to see if json["xxxx"] is nil first
        
        conversation.entityId = json["eid"].string!
        conversation.organizationId = json["organization_id"].string!
        conversation.recipientId = json["user_id"].string!
        conversation.status = json["status"].string!
        conversation.lastActivity = json["last_activity"].string!
        
        let person = Person()
        person.userImage = UIImage(named: "Default")
        person.userId = json["user_id"].string!
        
        if(json["user_full_name"] != nil){
            person.fullName = json["user_full_name"].string!
            if(json["user_birthdate"] != nil){
                person.birthdate = Date.init(timeIntervalSince1970: TimeInterval(json["user_birthdate"].string!)!)
            } else {
                person.birthdate = Date.init(timeIntervalSince1970: 0)
            }
            
            var userImage: UIImage?
            switch json["user_image"].type {
            case .string:
                userImage = DynamicCacheManager.getImage(url: json["user_image"].string!)
                person.userImageUrl = json["user_image"].string!
            case .array:
                person.userImageUrl = ""
            default:break
            }
            
            
            if(userImage == nil){
                userImage = UIImage(named: "Default")
            }
            
            person.userImage = userImage
        }
        
        if(json["staff_conversation"] != nil){
            conversation.staffConversation = (json["staff_conversation"].string! == "1")
        }
        
        conversation.person = person
        
        return conversation
    }
    
    static func getMessageUsing(json: JSON) -> Message {
        let message = Message()
    
        message.message = json["message_text"].string!
        message.messageDate = Date.init(timeIntervalSince1970: TimeInterval(json["created"].string!)!)
        message.isCurrentUsers = json["name"] != nil ? (UIApplication.shared.delegate as! AppDelegate).currentlyLoggedInPerson?.email == json["name"].string! : false
        message.isUnread = (json["unread"].string! == "0")
        message.isConsultMessage = (json["consult_id"].string! != "0")
        message.eid = json["eid"].string!
        message.name = json["name"] != nil ? json["name"].string! : ""
        message.conversationId = json["conversation_id"].string!
        
        return message
    }
}
