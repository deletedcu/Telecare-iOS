//
//  ModelManager.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 10/1/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation
import UIKit

class ModelManager {
    static var restManager = (UIApplication.shared.delegate as! AppDelegate).restManager
    static var appDelegate = (UIApplication.shared.delegate as! AppDelegate)
    static var currentRestController: RestViewController?
}
