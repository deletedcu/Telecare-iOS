//
//  AVCRestViewController.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 10/8/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation
import UIKit
import SwiftyJSON
import AVFoundation

class AVCRestViewController : RestViewController, UINavigationBarDelegate, UIGestureRecognizerDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var originalFrameOriginX:CGFloat?
    
    var originalFrameOriginY:CGFloat?
    
    var audioPlayer:AVPlayer!
    
    var attachmentImage:UIImage?
    
    let picker = UIImagePickerController()
    
    var currentConversation:Conversation? = Conversation()
    
    var currentConsult:Consult? = Consult()
    
    public var hasAttachment:Bool? = false
    
    public var attachmentType:String? = "none"
    
    public var audioUrl:URL?
    
    var delegate: RestViewController? = RestViewController()
    
    lazy var audioView: AudioView = {
        let audioView = AudioView()
        return audioView
    }()
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    
    func sendMessageFailed(message:Message){
        errorManager?.postErrorMessage(controller: self)
    }
    
    deinit {
        audioView.purgeAudioFiles()
    }
}
