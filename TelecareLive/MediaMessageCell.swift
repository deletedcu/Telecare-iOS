//
//  MediaMessageCell.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 10/3/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class MediaMessageCell : UITableViewCell {
    
    @IBOutlet weak var media: MediaButton!
    @IBOutlet weak var messageText: MessageLabel!
    @IBOutlet weak var messageDate: UILabel!
    
    var message:Message? = Message()


    override func layoutMarginsDidChange() {
        contentView.layoutMargins = layoutMargins
    }
}
