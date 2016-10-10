//
//  PhotoView.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 9/30/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation
import UIKit

class PhotoView : UIView {
    @IBOutlet weak var visualEffect: UIVisualEffectView!
    
    @IBOutlet weak var takePhotoButton: UIButton!
    
    @IBOutlet weak var chooseFromGalleryButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    var delegate: AccountViewController?
    
    @IBAction func takePhoto(_ sender: UIButton) {
        delegate?.getPhotoFromCamera()
    }
    
    @IBAction func openGallery(_ sender: UIButton) {
       delegate?.getPhotoFromLibrary()
    }
    
    @IBAction func cancel(_ sender: UIButton) {
        self.hideView()
    }
    
   var photoView: UIView!
    
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
        let nib = UINib(nibName: "PhotoView", bundle: bundle)
        photoView = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return photoView
    }
    
    func setupView(){
        photoView = loadViewFromXibFile()
        photoView.frame = bounds
        photoView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(photoView)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        /// Adds a shadow to our view
        photoView.layer.cornerRadius = 4.0
        photoView.layer.shadowColor = UIColor.black.cgColor
        photoView.layer.shadowOpacity = 0.2
        photoView.layer.shadowRadius = 4.0
        photoView.layer.shadowOffset = CGSize(width: 0, height: 5)
        
        visualEffect.layer.cornerRadius = 4.0
    }

//    func xibSetup() {
//        photoView = loadViewFromXibFile()
//        
//        // use bounds not frame or it'll be offset
//        photoView.frame = bounds
//        
//        // Make the view stretch with containing view
//        photoView.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
//        // Adding custom subview on top of our view (over any custom drawing > see note below)
//        addSubview(photoView)
//    }
    
    override func updateConstraints() {
        super.updateConstraints()
        addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 200.0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 200.0))
        
        addConstraint(NSLayoutConstraint(item: photoView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: photoView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: photoView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: photoView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0))
    }
    
    func displayView(onView: UIView) {
        self.alpha = 0.0
        onView.addSubview(self)
        
        onView.addConstraint(NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: onView, attribute: .centerY, multiplier: 1.0, constant: -80.0)) // move it a bit upwards
        onView.addConstraint(NSLayoutConstraint(item: self, attribute: .centerX, relatedBy: .equal, toItem: onView, attribute: .centerX, multiplier: 1.0, constant: 0.0))
        onView.needsUpdateConstraints()
        
        transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.alpha = 1.0
            self.transform = CGAffineTransform.identity
        }) { (finished) -> Void in
            // When finished wait 1.5 seconds, than hide it
//            let delayTime = DispatchTime.now(DispatchTime.now, Int64(1.5 * Double(NSEC_PER_SEC)))
//            DispatchQueue.asyncAfter(self: DispatchQueue.main) {
//                self.hideView()
//            }
        }
    }
    
    func hideView() {
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            self.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }) { (finished) -> Void in
            self.removeFromSuperview()
        }
    }
}
