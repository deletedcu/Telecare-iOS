//
//  MultilineChatTextView.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 12/26/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation
import UIKit
import Chatto

class MultilineChatTextView : GrowingTextView {

    let amountOfLinesToBeShown:CGFloat = 6
    var bottomConstraintConstant: CGFloat = 8
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder:aDecoder)
        self.setup()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    func setup(){
        self.layer.cornerRadius = Constants.cmFieldCornerRadius
        self.layer.backgroundColor = Constants.cmWhite.cgColor
        self.font = Constants.cmFont
        self.textColor = Constants.cmBlack
        self.layer.borderWidth = 1
        self.layer.borderColor = Constants.cmSlightGrey.cgColor
        self.backgroundColor = Constants.cmWhite
        
        maxHeight = self.font!.lineHeight * amountOfLinesToBeShown
    }
    
    func initializeLayout(parentView: UIView){
       
    }
    
//    func textViewDidChange(_ textView: UITextView) {
//        let fixedWidth = textView.frame.size.width
//        textView.sizeThatFits(CGSize(width: fixedWidth, height: (textView as! MultilineChatTextView).maxHeight))
//        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
//        var newFrame = textView.frame
//        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
//        textView.frame = newFrame;
//    }
}
