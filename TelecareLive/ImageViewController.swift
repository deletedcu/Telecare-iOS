//
//  ImageViewController.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 10/13/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation
import UIKit

class ImageViewController : RestViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var currentMessage:Message? = Message()
    
    var delegate:RestViewController?
    
    override func viewDidLoad(){
        super.viewDidLoad()
        
        if currentMessage?.mediaUrl != nil && currentMessage?.mediaUrl != "" {
            imageView.setImageFromURl(stringImageUrl: (currentMessage?.mediaUrl!)!)
    
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        imageView.alpha = 1
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        imageView.alpha = 0
    }

    @IBAction func scaleImage(_ sender: UIPinchGestureRecognizer) {
        self.view.transform = self.view.transform.scaledBy(x: sender.scale, y: sender.scale)
        sender.scale = 1
    }
    
    @IBAction func rotateImage(_ sender: UIRotationGestureRecognizer) {
        self.view.transform = self.view.transform.rotated(by: sender.rotation)
        sender.rotation = 0
    }
    @IBAction func panImage(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: self.view)
        if let view = sender.view {
            view.center = CGPoint(x:view.center.x + translation.x, y:view.center.y + translation.y)
        }
        sender.setTranslation(CGPoint.zero, in: self.view)
    }
}
