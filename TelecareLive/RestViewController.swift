//
//  RESTViewController.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 9/27/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import BadgeSwift

class RestViewController : UIViewController, UITabBarControllerDelegate {
    
    var appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    var restManager: RestManager?
    
    var sessionManager: SessionManager?
    
    var errorManager: ErrorManager?
    
    var currentEid:String?
    
    var controllerStack:[UIViewController]? = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        restManager = (UIApplication.shared.delegate as! AppDelegate).restManager!
        sessionManager = (UIApplication.shared.delegate as! AppDelegate).sessionManager!
        errorManager = (UIApplication.shared.delegate as! AppDelegate).errorManager!
        PersonManager.currentRestController = self
        navigationController?.navigationBar.tintColor = UIColor.white;
        refreshData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tabBarController?.delegate = self
    }
    
    func getCurrentErrorMessage() -> String {
        return errorManager!.currentErrorMessage!
    }
    
    func resetCurrentErrorMessage(){
        errorManager?.currentErrorMessage = ""
    }
    
    func setCurrentErrorMessage(message: String) {
        errorManager?.currentErrorMessage = message
    }
    
    func refreshData(){
        
    }
    
    func handleDirectMessage(restData: JSON){}
    
    func handleDirectMessage(){}
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
//        self.refreshData()
    }
    
    func hideKeyboardWhenViewTapped() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    public func createBadge(text:String, view: UIView) {
        let badge = BadgeSwift()
        view.addSubview(badge)
        configureBadge(badge, text: text)
        positionBadge(badge, view:view)
    }
    
    private func configureBadge(_ badge: BadgeSwift, text: String) {
        // Text
        badge.text = text
        
        // Insets
        badge.insets = CGSize(width: 1, height: 1)
        
        // Font
        badge.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
        
        // Text color
        badge.textColor = UIColor.white
        
        // Badge color
        badge.badgeColor = UIColor.red
        
        // Shadow
        badge.shadowOpacityBadge = 0.5
        badge.shadowOffsetBadge = CGSize(width: 0, height: 0)
        badge.shadowRadiusBadge = 1.0
        badge.shadowColorBadge = UIColor.black
        
        // No shadow
        badge.shadowOpacityBadge = 0
        
        // Border width and color
//        badge.borderWidth = 5.0
//        badge.borderColor = UIColor.magenta
    }
    
    private func positionBadge(_ badge: UIView, view: UIView) {
        badge.translatesAutoresizingMaskIntoConstraints = false
        var constraints = [NSLayoutConstraint]()
        
        // Center the badge vertically in its container
        constraints.append(NSLayoutConstraint(
            item: badge,
            attribute: NSLayoutAttribute.centerY,
            relatedBy: NSLayoutRelation.equal,
            toItem: view,
            attribute: NSLayoutAttribute.centerY,
            multiplier: 1, constant: 0)
        )
        
        // Center the badge horizontally in its container
        constraints.append(NSLayoutConstraint(
            item: badge,
            attribute: NSLayoutAttribute.centerX,
            relatedBy: NSLayoutRelation.equal,
            toItem: view,
            attribute: NSLayoutAttribute.centerX,
            multiplier: 1, constant: 0)
        )
        
        view.addConstraints(constraints)
    }
}
