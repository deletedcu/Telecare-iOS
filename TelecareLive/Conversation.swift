//
//  Conversations.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 10/1/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation

class Conversation {
    var entityId: String?
    var organizationId: String?
    var recipientId: String?
    var status: String?
    var lastActivity: String?
    var person: Person?
    var messages: [Message]? = []
    var consults: [Consult]? = []
    var staffConversation: Bool = false
}
