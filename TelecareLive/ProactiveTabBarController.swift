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
    
    
}

protocol ProactiveTab {
    func refresh()
}
