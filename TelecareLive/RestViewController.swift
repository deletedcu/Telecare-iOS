//
//  RESTViewController.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 9/27/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation
import UIKit

class RestViewController : UIViewController, UITabBarControllerDelegate {
    
    var appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    
    var restManager: RestManager?
    
    var sessionManager: SessionManager?
    
    var errorManager: ErrorManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        restManager = (UIApplication.shared.delegate as! AppDelegate).restManager!
        sessionManager = (UIApplication.shared.delegate as! AppDelegate).sessionManager!
        errorManager = (UIApplication.shared.delegate as! AppDelegate).errorManager!
        PersonManager.currentRestController = self
        navigationController?.navigationBar.tintColor = UIColor.white;
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
}
