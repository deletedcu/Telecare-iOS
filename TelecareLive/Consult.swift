//
//  Consult.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 10/1/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation
import UIKit

class Consult {
    var entityId: String?
    var organizationId: String?
    var recipientId: String?
    var status: String?
    var lastActivity: String?
    var issue:String?
    var userImage:UIImage?
    var userImageUrl:String?
    var birthdate:Date?
    var messages:[Message]? = []
    var userId: String?
    var unreadCount: Int = 0
}
