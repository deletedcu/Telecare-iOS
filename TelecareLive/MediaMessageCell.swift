//
//  MediaMessageCell.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 10/3/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class MediaMessageCell : UITableViewCell {
    
    @IBOutlet weak var media: MediaButton!
    @IBOutlet weak var messageText: MessageLabel!
    @IBOutlet weak var messageDate: UILabel!
    
    var message:Message? = Message()
    var audioPlayer:AVAudioPlayer?
    
    @IBAction func playAudio(_ sender: AnyObject) {
        if(!(self.message?.hasAudio)!){
            return
        }
        
        if audioPlayer == nil {
            audioPlayer = AVAudioPlayer()
            
            do {
                let mediaUrl = URL(fileURLWithPath: (message?.mediaUrl)!)
                let sound = try AVAudioPlayer(contentsOf: mediaUrl)
                sound.play()
            } catch {
                let nsError = error as NSError
                print(nsError.localizedDescription)
            }
        } else {
            if (audioPlayer?.isPlaying)! {
                audioPlayer?.stop()
            } else {
                audioPlayer?.play()
            }
        }
    }
    
    
    
    override func layoutMarginsDidChange() {
        contentView.layoutMargins = layoutMargins
    }
}
