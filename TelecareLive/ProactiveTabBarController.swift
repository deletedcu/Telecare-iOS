//
//  ProactiveTabBarController.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 10/1/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation
import UIKit

class ProactiveTabBarController : UITabBarController {
    
    var registeredForRefresh: Dictionary<Int,ProactiveTab?>?
    
    func refreshRegisteredViewControllers(){
        for (_, ProactiveTab) in registeredForRefresh! {
            ProactiveTab?.refresh()
        }
    }
    
    override func viewDidLoad() {
        (UIApplication.shared.delegate as! AppDelegate).tabBarController = self
    }
    
    func trimTabBarController() {
            let doctorIndex = 0
            let patientIndex = 2
            if (viewControllers?.count)! > 3 {
                var tempViewControllers = viewControllers
                if ((UIApplication.shared.delegate as! AppDelegate).currentlyLoggedInPerson?.isDoctor)! {
                    tempViewControllers?.remove(at: patientIndex)
                    tempViewControllers?.remove(at: patientIndex)
                } else {
                    tempViewControllers?.remove(at: doctorIndex)
                    tempViewControllers?.remove(at: doctorIndex)
                }
                viewControllers = tempViewControllers
            }
    }
    
}

protocol ProactiveTab {
    func refresh()
}
