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
    static func populateMessagesForConversation(conversation: Conversation){
        restManager?.getAllMessages(conversation: conversation, callback: finishGettingAllMessages)
    }
    
    static func finishGettingAllMessages(conversation: Conversation, restData: JSON){
        let messages: [Message] = []
        
        // FINISH THIS OUT
        print(restData)
        print("ABOVE IS REST DATA FROM MESSAGES")
    }
    
    static func getConversationUsing(json: JSON)-> Conversation{
        let conversation = Conversation()
        
        conversation.entityId = json["eid"].string!
        conversation.organizationId = json["organization_id"].string!
        conversation.recipientId = json["user_id"].string!
        conversation.status = json["status"].string!
        conversation.lastActivity = json["last_activity"].string!
        
        let person = Person()
        person.fullName = json["user_full_name"].string!
        person.birthdate = Date.init(timeIntervalSince1970: TimeInterval(json["user_birthdate"].string!)!)
        
        var userImage: UIImage?
        switch json["user_image"].type {
        case .string:
            let image = UIImageView()
            image.setImageFromURl(stringImageUrl: json["user_image"].string!)
            userImage = image.image!
            person.userImageUrl = json["user_image"].string!
        case .array:
            person.userImageUrl = ""
        default:break
        }
        
        if(userImage == nil){
            userImage = UIImage(named: "Default")
        }
        
        person.userImage = userImage
        
        conversation.person = person
        
        return conversation
    }
}
