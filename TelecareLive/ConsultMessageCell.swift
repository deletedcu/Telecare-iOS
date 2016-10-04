//
//  ConsultMessageCell.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 10/3/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation
import UIKit

class ConsultMessageCell : UITableViewCell {
    
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var messageDate: UILabel!
    
    override func layoutMarginsDidChange() {
        contentView.layoutMargins = layoutMargins
    }
}
