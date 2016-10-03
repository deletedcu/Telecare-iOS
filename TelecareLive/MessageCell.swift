//
//  MessageCell.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 10/1/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation
import UIKit

class MessageCell : UITableViewCell {
    
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var messageDate: UILabel!
    
    override func layoutMarginsDidChange() {
        contentView.layoutMargins = layoutMargins
    }
}
