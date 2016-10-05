//
//  AudioView.swift
//  TelecareLive
//
//  Created by Scott Metcalf on 10/4/16.
//  Copyright © 2016 Syworks LLC. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class AudioView : UIView, AVAudioRecorderDelegate {
    
    var audioRecorder: AVAudioRecorder?
    var recordingSession: AVAudioSession!
    
    var delegate: ConsultChatViewController?
    
    @IBOutlet weak var redDot: UIImageView!
    
    @IBOutlet weak var recordingButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var insertButton: UIButton!
    
    @IBAction func insertAudio(_ sender: AnyObject) {
        delegate?.hasAttachment = true
        delegate?.attachmentType = "audio"
        delegate?.audioUrl = delegate?.getDocumentsDirectory().appendingPathComponent("recording.m4a")
        hideView()
    }
    
    @IBAction func cancelAudio(_ sender: AnyObject) {
        if(delegate?.hasAttachment == false){
            delegate?.hasAttachment = false
            delegate?.attachmentType = "none"
            purgeAudioFiles()
        }
        hideView()
    }
    
    func purgeAudioFiles(){
        let fileManager = FileManager.default
        let audioUrl = delegate?.getDocumentsDirectory().appendingPathComponent("recording.m4a")
        
        do {
            try fileManager.removeItem(atPath: (audioUrl?.absoluteString)!)
        } catch {
            print("Could not purge audio files: \(error)")
        }
    }
    
    @IBAction func recordAudio(_ sender: AnyObject) {
        print(audioRecorder)
        if audioRecorder == nil || (audioRecorder?.isRecording)! {
            
            let audioFilename = delegate?.getDocumentsDirectory().appendingPathComponent("recording.m4a")
            
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            do {
                audioRecorder = try AVAudioRecorder(url: audioFilename!, settings: settings)
                audioRecorder?.delegate = self
                audioRecorder?.record()
                
            } catch {

            }
            
            redDot.fadeIn()
            insertButton.fadeOut()
            cancelButton.fadeOut()
            print(audioRecorder?.isRecording)
        }
    }
    
    @IBAction func stopRecordingAudio(_ sender: AnyObject) {
        if audioRecorder?.isRecording == true {
            audioRecorder?.stop()
            audioRecorder = nil
            redDot.fadeOut()
            insertButton.fadeIn()
            cancelButton.fadeIn()
        }
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            redDot.fadeOut()
        }
    }
    
    func viewDidLoad() {
//        let dirPaths =
//            NSSearchPathForDirectoriesInDomains(.documentDirectory,
//                                                .userDomainMask, true)
//        let docsDir = dirPaths[0]
//        let soundFilePath =
//            docsDir.appending("sound.caf")
//        let soundFileURL = NSURL(fileURLWithPath: soundFilePath)
//        let recordSettings =
//            [AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
//             AVSampleRateKey: 16000,
//             AVNumberOfChannelsKey: 1,
//             AVLinearPCMBitDepthKey: 0,
//              AVLinearPCMIsBigEndianKey: 0,
//             AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue] as [String : Any]
//        
//        audioSession = AVAudioSession.sharedInstance()
//        
//        do{
//            try audioSession.setCategory(AVAudioSessionCategoryRecord)
//            
//            try audioRecorder = AVAudioRecorder(url: soundFileURL as URL,
//                                            settings: recordSettings as [String : AnyObject])
//            
//                audioRecorder?.prepareToRecord()
//        } catch {
//            print("Error info: \(error)")
//        }
        
        recordingSession = AVAudioSession.sharedInstance()
        
        do {
            try recordingSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
            try recordingSession.setActive(true)
        } catch {
            // failed to record!
        }
    }
        
    @IBAction func cancel(_ sender: UIButton) {
        self.hideView()
    }

    
    func audioPlayerDecodeErrorDidOccur(error: Error!) {
        print("Audio Play Decode Error")
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder!, successfully flag: Bool) {
        audioRecorder?.stop()
        audioRecorder = nil
        redDot.fadeOut()
    }
    
    func audioRecorderEncodeErrorDidOccur(error: NSError!) {
        print("Audio Record Encode Error")
    }
    
    var localAudioView: UIView!

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
        let nib = UINib(nibName: "AudioView", bundle: bundle)
        localAudioView = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return localAudioView
    }
    
    func setupView(){
        localAudioView = loadViewFromXibFile()
        localAudioView.frame = bounds
        localAudioView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(localAudioView)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        /// Adds a shadow to our view
        localAudioView.layer.cornerRadius = 4.0
        localAudioView.layer.shadowColor = UIColor.black.cgColor
        localAudioView.layer.shadowOpacity = 0.2
        localAudioView.layer.shadowRadius = 4.0
        localAudioView.layer.shadowOffset = CGSize(width: 0, height: 5)
        
        viewDidLoad()
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
        addConstraint(NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 303.0))
        addConstraint(NSLayoutConstraint(item: self, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 230.0))
        
        addConstraint(NSLayoutConstraint(item: localAudioView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: localAudioView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: localAudioView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        addConstraint(NSLayoutConstraint(item: localAudioView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0))
    }
    
    func displayView(onView: UIView) {
        self.alpha = 0.0
        onView.addSubview(self)
        
        onView.addConstraint(NSLayoutConstraint(item: self, attribute: .centerY, relatedBy: .equal, toItem: onView, attribute: .centerY, multiplier: 1.0, constant: 50.0))
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
