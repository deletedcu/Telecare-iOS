//
//  loadingController.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 11/10/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation
import SwiftOverlays

class LoadingController: UIViewController {
    override func viewDidLoad() {
        self.showTextOverlay("Loading...")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.removeAllOverlays()
    }
}
