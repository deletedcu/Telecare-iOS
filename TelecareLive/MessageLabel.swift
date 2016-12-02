//
//  MessageLabel.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 10/2/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class MessageLabel : UILabel {
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: -20, left: 10, bottom: -20, right: 10) // acts similar to padding
        super.drawText(in: UIEdgeInsetsInsetRect(rect, insets))
    }
    
    override public var intrinsicContentSize: CGSize {
        var intrinsicSuperViewContentSize = super.intrinsicContentSize
        intrinsicSuperViewContentSize.height += 30 // acts similar to margins
        intrinsicSuperViewContentSize.width += 25
        return intrinsicSuperViewContentSize
    }
}
