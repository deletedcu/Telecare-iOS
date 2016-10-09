//
//  NewConsult.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 10/5/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation
import UIKit
class NewConsult : UIView {

    @IBOutlet weak var visualEffect: UIVisualEffectView!
    
    @IBOutlet weak var startConsultButton: UIButton!
    
    @IBOutlet weak var issueTextField: UITextField!
    
    @IBOutlet weak var chargeForConsultSwitch: UISwitch!
    
    @IBAction func startConsult(_ sender: AnyObject) {
        if(chargeForConsultSwitch.isOn){
            delegate?.addChargedConsult(title: issueTextField.text!)
            (UIApplication.shared.delegate as! AppDelegate).restManager?.launchNewConsult(charge: true, title: issueTextField.text!, conversation:(delegate?.currentConversation)!, callback: (delegate?.finishAddingNewConsult)!)
        } else {
            delegate?.addFreeConsult(title: issueTextField.text!)
                        (UIApplication.shared.delegate as! AppDelegate).restManager?.launchNewConsult(charge: false, title: issueTextField.text!, conversation:(delegate?.currentConversation)!, callback: (delegate?.finishAddingNewConsult)!)
        }
        delegate?.removeCloseNewConsultViewWhenTapped()
        delegate?.refreshData()
        self.hideView()
    }
    
    
    
    var newConsult: UIView!
    
    var delegate: ConsultsViewController?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        setupView()
    }
    
    // Thanks to http://zappdesigntemplates.com/create-your-own-overlay-view-in-swift/
    func loadViewFromXibFile() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "NewConsult", bundle: bundle)
        newConsult = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return newConsult
    }
    
    func setupView(){
        newConsult = loadViewFromXibFile()
        newConsult.frame = bounds
        newConsult.translatesAutoresizingMaskIntoConstraints = false
        addSubview(newConsult)
        chargeForConsultSwitch.isOn = false
        
        translatesAutoresizingMaskIntoConstraints = false
        
        /// Adds a shadow to our view
        newConsult.layer.cornerRadius = 4.0
        newConsult.layer.shadowColor = UIColor.black.cgColor
        newConsult.layer.shadowOpacity = 0.2
        newConsult.layer.shadowRadius = 4.0
        newConsult.layer.shadowOffset = CGSize(width: 0, height: 5)
        
        visualEffect.layer.cornerRadius = 4.0
    }
    
    override func updateConstraints() {
        super.updateConstraints()
        addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 269))
        addConstraint(NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 255))
        
        addConstraint(NSLayoutConstraint(item: newConsult, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: newConsult, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: newConsult, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: newConsult, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0))
    }
    
    func displayView(onView: UIView) {
        onView.addSubview(self)
        
        onView.addConstraint(NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: onView, attribute: .centerY, multiplier: 1.0, constant: -80.0)) // move it a bit upwards
        onView.addConstraint(NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: onView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        onView.needsUpdateConstraints()
        
    }
    
    func hideView() {
            self.removeFromSuperview()
    }

}
