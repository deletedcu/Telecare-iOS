//
//  Message.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 10/1/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation
import UIKit

class Message {
    var message:String? = ""
    var messageDate:Date? = Date()
    var isCurrentUsers:Bool? = false
    var isUnread:Bool? = true
    var isConsultMessage:Bool? = true
    var eid:String?
    var name:String?
    var conversationId:String?
    var mediaUrl:String? = ""
    var hasMedia:Bool? = false
    var imageMedia:UIImage?
    var imageThumb:UIImage?
    var mediaThumbUrl:String? = ""
    var hasAudio:Bool? = false
    var fileMime:String? = ""
    var fileId:String? = ""
    var fileName:String? = ""
    var consultId:String? = ""
}
