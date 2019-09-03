//
//  VideoPlaybackSaveVideo.swift
//  kwikut
//
//  Created by Apple on 09/08/2019.
//  Copyright © 2019 devstop. All rights reserved.
//


import UIKit
import AVFoundation
import CoreMedia
import LCActionSheet
import Photos
import ProgressiveAlertView
import MobileCoreServices



class VideoPlaybackSaveVideo: UIViewController, LCActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let topContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "previous_arrow"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    

    
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Save Video"
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let bottomIconsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let saveButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "movie_icon.png"), for: UIControl.State.normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let playButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "play_button.png"), for: UIControl.State.normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
   
    
    let avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!
    var videoURL: URL!
    var videoCount: Int?
    let output = AVPlayerItemVideoOutput(pixelBufferAttributes: nil)
    var tapCheck = false
    var selectedFilter: String?
    var filteredVideoURL: URL?
    var audioAddedURL: URL?
    var finalAudioVideoURL: URL?
    var backgroundPlayer = AVAudioPlayer()
    var index: Int!
    
    
    @IBOutlet weak var videoImageViewSave: UIImageView!
    
    
    // view will appear
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
//        avPlayer.pause() // 1. pause the player to stop it
//        avPlayerLayer?.player = nil // 2. set the playerLayer's player to nil
//        avPlayerLayer?.removeFromSuperlayer()
        
    }
    
    // MARK:- VIEW DID LOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // observer
        NotificationCenter.default.addObserver(self, selector: #selector(finishVideo), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.avPlayer.currentItem)
        
        // back button target
        self.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        self.saveButton.addTarget(self, action: #selector(saveButtonHandler), for: .touchUpInside)
        self.playButton.addTarget(self, action: #selector(playButtonHandler), for: .touchUpInside)

        
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = view.bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoImageViewSave.layer.insertSublayer(avPlayerLayer, at: 0)
        
        view.layoutIfNeeded()
        
        let playerItem = AVPlayerItem(url: videoURL as URL)
        avPlayer.replaceCurrentItem(with: playerItem)
        avPlayer.play()
        
        //        addGesture()
        
        // setupviews calling
        setupViews()
        
    }
    
    // MARK:- VIEW WILL DISAPPEAR
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        avPlayer.pause() // 1. pause the player to stop it
        avPlayerLayer?.player = nil // 2. set the playerLayer's player to nil
        avPlayerLayer?.removeFromSuperlayer()
    }
    
    
    
    //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    //
    //        let vc = segue.destination as! VideoPlaybackSound
    //        vc.videoURL = sender as! URL
    //        //        vc.videoCount = URLcollection.count
    //
    //    }
    
    // ==========================================================================================
    // ================================= SETUP VIEW FUNCTION ====================================
    // ==========================================================================================
    
    func setupViews() {
        
        // ================= ADDING VIEWS ======================
        //        view.addSubview(backButton)
        view.addSubview(topContainerView)
        view.addSubview(bottomIconsContainerView)
        topContainerView.addSubview(backButton)
        //        topContainerView.addSubview(musicButton)
        //        topContainerView.addSubview(saveButton)
        topContainerView.addSubview(titleLabel)

        
        
        bottomIconsContainerView.addSubview(saveButton)
        bottomIconsContainerView.addSubview(playButton)
        
        // =================== CONSTRAINTS ====================
        
        topContainerView.topAnchor.constraint(equalTo: videoImageViewSave.topAnchor).isActive = true
        topContainerView.leftAnchor.constraint(equalTo: videoImageViewSave.leftAnchor).isActive = true
        topContainerView.rightAnchor.constraint(equalTo: videoImageViewSave.rightAnchor).isActive = true
        topContainerView.heightAnchor.constraint(equalTo: videoImageViewSave.heightAnchor, multiplier: 0.1).isActive = true
        
        backButton.centerYAnchor.constraint(equalTo: topContainerView.centerYAnchor).isActive = true
        backButton.leftAnchor.constraint(equalTo: topContainerView.leftAnchor, constant: 20).isActive = true
        backButton.heightAnchor.constraint(equalTo: topContainerView.heightAnchor, multiplier: 0.35).isActive = true
        backButton.widthAnchor.constraint(equalTo: topContainerView.heightAnchor, multiplier: 0.35).isActive = true
        
        
        
        //        backButton.centerYAnchor.constraint(equalTo: topContainerView.centerYAnchor).isActive = true
        //        backButton.leftAnchor.constraint(equalTo: topContainerView.leftAnchor, constant: 10).isActive = true
        
        //
        //        musicButton.rightAnchor.constraint(equalTo: topContainerView.rightAnchor, constant: -10).isActive = true
        //        musicButton.centerYAnchor.constraint(equalTo: topContainerView.centerYAnchor).isActive = true
        //
        //        saveButton.centerXAnchor.constraint(equalTo: topContainerView.centerXAnchor).isActive = true
        //        saveButton.centerYAnchor.constraint(equalTo: topContainerView.centerYAnchor).isActive = true
        
        titleLabel.centerXAnchor.constraint(equalTo: topContainerView.centerXAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: topContainerView.centerYAnchor).isActive = true
        
        
        bottomIconsContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        bottomIconsContainerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        bottomIconsContainerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        bottomIconsContainerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.13).isActive = true
        
        saveButton.centerXAnchor.constraint(equalTo: bottomIconsContainerView.centerXAnchor).isActive = true
        saveButton.centerYAnchor.constraint(equalTo: bottomIconsContainerView.centerYAnchor).isActive = true
        saveButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        saveButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        playButton.centerYAnchor.constraint(equalTo: bottomIconsContainerView.centerYAnchor).isActive = true
        playButton.rightAnchor.constraint(equalTo: bottomIconsContainerView.rightAnchor, constant: -30).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        
    }

    
    // ==========================================================================================
    // ================================ PLAYING AUDIO FUNCTION ==================================
    // ==========================================================================================
    
    func playBackgroundMusic(fileName: String) {
        
        let url = Bundle.main.url(forResource: fileName, withExtension: nil)
        guard let newURL = url else {
            print("count not find filed called: \(fileName)")
            return
        }
        do{
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: .mixWithOthers)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print(error)
            }
            
            self.audioAddedURL = newURL
            
            backgroundPlayer = try AVAudioPlayer(contentsOf: newURL)
            backgroundPlayer.numberOfLoops = -1
            backgroundPlayer.prepareToPlay()
            backgroundPlayer.play()
        }
        catch let error as NSError{
            print(error.description)
        }
        
    }
    
    
    func playBackgroundMusicOriginal(newURL: URL) {
        
        do{
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback, mode: AVAudioSession.Mode.default, options: .mixWithOthers)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print(error)
            }
            
            self.audioAddedURL = newURL
            
            backgroundPlayer = try AVAudioPlayer(contentsOf: newURL)
            backgroundPlayer.numberOfLoops = -1
            backgroundPlayer.prepareToPlay()
            
            if let getFilteredVideoPlay = self.filteredVideoURL{
                let playerItem = AVPlayerItem(url: getFilteredVideoPlay)
                avPlayer.replaceCurrentItem(with: playerItem)
                avPlayer.play()
            }else{
                let playerItem = AVPlayerItem(url: self.videoURL)
                avPlayer.replaceCurrentItem(with: playerItem)
                avPlayer.play()
            }
            
            
            backgroundPlayer.play()
            
        }
        catch let error as NSError{
            print(error.description)
        }
        
    }
    
    
    
    
    // CUSTOM ALERT FUNCTION
    
    func displayMyAlertMessage(userMessage: String) {
        var myalert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        myalert.addAction(okAction)
        present(myalert, animated: true, completion: nil)
    }
    
    
    // FOR LOOPING THE VIDEO
    
    @objc func finishVideo(){
        
        print("Video Finished")
        self.avPlayer.seek(to: CMTime.zero)
        self.avPlayer.play()
        
    }
    
    // back button
    @objc func backButtonTapped() {
        print("backbutton tapped")
        self.avPlayer.pause()
        self.avPlayerLayer.removeFromSuperlayer()
        self.performSegue(withIdentifier: "unwindToFifteenSecondsFromSave", sender: self)
    }
    
    
    @objc func saveButtonHandler() {
        print("music tapped")
        // saving code
        saveVideoButtonTapped()
    }

    
    
    // MARK:- PLAY BUTTON
    @objc func playButtonHandler() {
        print("play tapped")

    }
    
    
    // MARK:- PROGRESS BAR
    
    // increasing progress bar
    @objc func increaseProgress(){
        var progress = HCProgressiveAlertView.shared().progress
        progress += 0.05
        HCProgressiveAlertView.shared().progress = progress
        
        if(progress < 1.0){
            self.perform(#selector(increaseProgress), with: nil, afterDelay: 0.1)
        }
        
    }
    
    // save video button tapped
    @objc func saveVideoButtonTapped() {
        print("save video button tapped")
        print(self.filteredVideoURL)
        print(self.audioAddedURL)
        
        HCProgressiveAlertView.shared().show()
        HCProgressiveAlertView.shared().topTitle = "Saving Your Kwikut"
        HCProgressiveAlertView.shared().bottomButtonText = "OK"
        self.perform(#selector(self.increaseProgress), with: nil, afterDelay: 0.1)
        HCProgressiveAlertView.shared().bottomButtonClickedBlock = {
            print("bottom button pressed")
            HCProgressiveAlertView.shared().dismiss()
        }
        
        if let url = self.audioAddedURL{
            
            if let urlfilteredVideo = self.filteredVideoURL{
                self.mergeVideoWithAudio(videoUrl: urlfilteredVideo, audioUrl: self.audioAddedURL!, success: { (URL) in
                    print("success URL: \(URL)")
                }, failure: { (error) in
                    print("error here: \(error)")
                })
            }else{
                self.mergeVideoWithAudio(videoUrl: self.videoURL, audioUrl: self.audioAddedURL!, success: { (URL) in
                    print("success URL: \(URL)")
                }, failure: { (error) in
                    print("error here: \(error)")
                })
                
            }
            
            
            
        }else if let url = self.filteredVideoURL{
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url) // self.filteredVideoURL!
            }) { saved, error in
                if saved {
                    print("video saved")
                }else{
                    let alertController = UIAlertController(title: "Video not saved Please try again", message: nil, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            
        }else{
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: self.videoURL)
            }) { saved, error in
                if saved {
                    print("video saved")
                }else{
                    let alertController = UIAlertController(title: "Video not saved Please try again", message: nil, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        
    }
    
    
    // Remove Observer
    deinit {
        print("de init calling")
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // merging
    
    func mergeVideoWithAudio(videoUrl: URL, audioUrl: URL, success: @escaping ((URL) -> Void), failure: @escaping ((Error?) -> Void)) {
        
        
        let mixComposition: AVMutableComposition = AVMutableComposition()
        var mutableCompositionVideoTrack: [AVMutableCompositionTrack] = []
        var mutableCompositionAudioTrack: [AVMutableCompositionTrack] = []
        let totalVideoCompositionInstruction : AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        
        let aVideoAsset: AVAsset = AVAsset(url: videoUrl)
        let aAudioAsset: AVAsset = AVAsset(url: audioUrl)
        
        if let videoTrack = mixComposition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid), let audioTrack = mixComposition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid) {
            mutableCompositionVideoTrack.append(videoTrack)
            mutableCompositionAudioTrack.append(audioTrack)
            
            if let aVideoAssetTrack: AVAssetTrack = aVideoAsset.tracks(withMediaType: .video).first, let aAudioAssetTrack: AVAssetTrack = aAudioAsset.tracks(withMediaType: .audio).first {
                do {
                    try mutableCompositionVideoTrack.first?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration), of: aVideoAssetTrack, at: CMTime.zero)
                    try mutableCompositionAudioTrack.first?.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: aVideoAssetTrack.timeRange.duration), of: aAudioAssetTrack, at: CMTime.zero)
                    videoTrack.preferredTransform = aVideoAssetTrack.preferredTransform
                    
                } catch{
                    print(error)
                }
                
                
                totalVideoCompositionInstruction.timeRange = CMTimeRangeMake(start: CMTime.zero,duration: aVideoAssetTrack.timeRange.duration)
            }
        }
        
        let mutableVideoComposition: AVMutableVideoComposition = AVMutableVideoComposition()
        mutableVideoComposition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        mutableVideoComposition.renderSize = CGSize(width: 480, height: 640)
        
        if let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first {
            let outputURL = URL(fileURLWithPath: documentsPath).appendingPathComponent("\("fileName").mp4")
            
            do {
                if FileManager.default.fileExists(atPath: outputURL.path) {
                    
                    try FileManager.default.removeItem(at: outputURL)
                }
            } catch { }
            
            if let exportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality) {
                exportSession.outputURL = outputURL
                exportSession.outputFileType = AVFileType.mp4
                exportSession.shouldOptimizeForNetworkUse = true
                
                /// try to export the file and handle the status cases
                exportSession.exportAsynchronously(completionHandler: {
                    switch exportSession.status {
                    case .completed:
                        
                        print("status completed")
                        //if u want to store your video in asset
                        
                        PHPhotoLibrary.shared().performChanges({
                            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputURL)
                        }) { saved, error in
                            if saved {
                                
                                print("video saved to gallery with audio")
                                
                            }
                        }
                    case .failed:
                        if let _error = exportSession.error {
                            failure(_error)
                        }
                        
                    case .cancelled:
                        if let _error = exportSession.error {
                            failure(_error)
                        }
                        
                    default:
                        print("finished")
                        success(outputURL)
                    }
                })
            } else {
                failure(nil)
            }
        }
    }
    
}


/// ================================================================================


