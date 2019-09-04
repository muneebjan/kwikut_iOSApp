import UIKit
import AVFoundation
import CoreMedia
import LCActionSheet
import Photos
import ProgressiveAlertView
import DKImagePickerController
import MobileCoreServices



protocol sendingDataBacktoViewController{
    func gettingCropedVideoURL(videourl: URL)
}


class VideoPlayback: UIViewController, LCActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let topContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let backButton: UIButton = {
        let button = UIButton()
        //        button.setTitle("Back", for: .normal)
        button.setImage(UIImage(named: "previous_arrow"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        //        button.backgroundColor = .red
        return button
    }()
    
    let bottomIconsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let outerCameraButton: UIView = {
        let button = UIView()
        button.backgroundColor = UIColor.clear
        button.layer.borderWidth = 5
        button.layer.borderColor = UIColor.white.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 30
        button.clipsToBounds = true
        return button
    }()
    let cameraButton: UIView = {
        let button = UIView()
        button.backgroundColor = UIColor.red
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 23
        button.clipsToBounds = true
        return button
    }()
    let galleryButton: UIButton = {
        let button = UIButton()
        let origImage = UIImage(named: "galleryImage.png")
        let tintedImage = origImage?.withRenderingMode(.alwaysTemplate)
        button.setImage(tintedImage, for: UIControl.State.normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let playButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "play_button.png"), for: UIControl.State.normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    //    let context = CIContext(eaglContext: EAGLContext(api: .openGLES3) ?? EAGLContext(api: .openGLES2)!)
    
    var delegate: sendingDataBacktoViewController?
    let avPlayer = AVPlayer()
    var avPlayerLayer: AVPlayerLayer!
    var videoURL: URL!
    var videoCount: Int?
    let myPickerController = UIImagePickerController()
    let dkpicker = DKImagePickerController()
    
    @IBOutlet weak var videoImageView: UIImageView!
    
    
    // view will appear
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        print("here I am Video Playback")
        
        print("merge button: \(UserDefaults.standard.bool(forKey: "mergePressed"))")
        
    }
    
    
    // MARK:- OBJECTIVE C FUNCTIONS
    
    
    @objc func galleryButtonHandler(){
        print("gallery pressed")
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            self.myPickerController.delegate = self
            self.myPickerController.sourceType = .photoLibrary
            self.myPickerController.mediaTypes = [kUTTypeMovie as String]
            //                self.myPickerController.mediaTypes = ["public.movie"]
            self.present(self.myPickerController, animated: true, completion: nil)
        }
        
    }
    
    @objc func cameraButtonHandler(){
        print("camera pressed")

        UserDefaults.standard.set(true, forKey: "retakePressed")
        UserDefaults.standard.synchronize()
        self.performSegue(withIdentifier: "unwindToFifteenSeconds", sender: self)
        
    }
    
    @objc func playButtonHandler(){
        print("play button pressed")
    }
    
    // FOR LOOPING THE VIDEO
    
    @objc func finishVideo(){
        
        print("Video Finished")
        self.avPlayer.seek(to: CMTime.zero)
        self.avPlayer.play()
        
    }
    
    // back button
    @objc func backButtonTapped() {
        print("back pressed here")
        self.avPlayer.pause()
        self.avPlayerLayer.removeFromSuperlayer()
        dismiss(animated: true, completion: nil)
        //        self.performSegue(withIdentifier: "unwindToFifteenSec", sender: self)
    }
    
    // MARK:- VIEW DID LOAD
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // observer
        NotificationCenter.default.addObserver(self, selector: #selector(finishVideo), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.avPlayer.currentItem)
        
        // button target
        self.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        self.galleryButton.addTarget(self, action: #selector(galleryButtonHandler), for: .touchUpInside)
        let gs = UITapGestureRecognizer(target: self, action: #selector(cameraButtonHandler))
        self.cameraButton.addGestureRecognizer(gs)
        self.playButton.addTarget(self, action: #selector(playButtonHandler), for: .touchUpInside)
        
        
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = view.bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoImageView.layer.insertSublayer(avPlayerLayer, at: 0)
        
        view.layoutIfNeeded()
        
        let playerItem = AVPlayerItem(url: videoURL as URL)
        avPlayer.replaceCurrentItem(with: playerItem)
        avPlayer.play()
        
        // setupviews calling
        setupViews()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        avPlayer.pause() // 1. pause the player to stop it
        avPlayerLayer?.player = nil // 2. set the playerLayer's player to nil
        avPlayerLayer?.removeFromSuperlayer()
    }
    
    // ==========================================================================================
    // ================================= SETUP VIEW FUNCTION ====================================
    // ==========================================================================================
    
    func setupViews() {
        
        // ================= ADDING VIEWS ======================
        //        view.addSubview(backButton)
        view.addSubview(topContainerView)
        topContainerView.addSubview(backButton)
        
        view.addSubview(bottomIconsContainerView)
        bottomIconsContainerView.addSubview(outerCameraButton)
        bottomIconsContainerView.addSubview(galleryButton)
        bottomIconsContainerView.addSubview(playButton)
        outerCameraButton.addSubview(cameraButton)
        
        
        // =================== CONSTRAINTS ====================
        
        topContainerView.topAnchor.constraint(equalTo: videoImageView.topAnchor).isActive = true
        topContainerView.leftAnchor.constraint(equalTo: videoImageView.leftAnchor).isActive = true
        topContainerView.rightAnchor.constraint(equalTo: videoImageView.rightAnchor).isActive = true
        topContainerView.heightAnchor.constraint(equalTo: videoImageView.heightAnchor, multiplier: 0.1).isActive = true
        
        backButton.centerYAnchor.constraint(equalTo: topContainerView.centerYAnchor).isActive = true
        backButton.leftAnchor.constraint(equalTo: topContainerView.leftAnchor, constant: 20).isActive = true
        backButton.heightAnchor.constraint(equalTo: topContainerView.heightAnchor, multiplier: 0.35).isActive = true
        backButton.widthAnchor.constraint(equalTo: topContainerView.heightAnchor, multiplier: 0.35).isActive = true

        
        bottomIconsContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        bottomIconsContainerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        bottomIconsContainerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        bottomIconsContainerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.13).isActive = true
        
        outerCameraButton.centerYAnchor.constraint(equalTo: bottomIconsContainerView.centerYAnchor).isActive = true
        outerCameraButton.centerXAnchor.constraint(equalTo: bottomIconsContainerView.centerXAnchor).isActive = true
        outerCameraButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        outerCameraButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        cameraButton.centerYAnchor.constraint(equalTo: outerCameraButton.centerYAnchor).isActive = true
        cameraButton.centerXAnchor.constraint(equalTo: outerCameraButton.centerXAnchor).isActive = true
        cameraButton.widthAnchor.constraint(equalToConstant: 46).isActive = true
        cameraButton.heightAnchor.constraint(equalToConstant: 46).isActive = true
        
        galleryButton.centerYAnchor.constraint(equalTo: outerCameraButton.centerYAnchor).isActive = true
        galleryButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
        galleryButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        galleryButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        playButton.centerYAnchor.constraint(equalTo: outerCameraButton.centerYAnchor).isActive = true
        playButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
    }
    
    
    // ==========================================================================================
    // ===================================== IMAGE PICKER =======================================
    // ==========================================================================================
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let videoURL = info[UIImagePickerController.InfoKey.referenceURL] as! URL
        //        let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL
        
        print("selecting video URL: \(videoURL)")
        let asset = AVAsset(url: videoURL as! URL)
        
        if(asset.duration.seconds < 3){
            self.displayMyAlertMessage(userMessage: "Can't Import Video less than 3 seconds")
            self.dismiss(animated: true, completion: nil)
        }else{
            
            self.cropVideo(sourceURL: videoURL as! URL, startTime: 0.0, endTime: 3.0) { (url) in
                self.dismiss(animated: true, completion: nil)
                self.delegate?.gettingCropedVideoURL(videourl: url)
                self.performSegue(withIdentifier: "unwindToFifteenSeconds", sender: self)
            }
        }
    }
    
    // CUSTOM ALERT FUNCTION
    
    func displayMyAlertMessage(userMessage: String) {
        var myalert = UIAlertController(title: "Alert", message: userMessage, preferredStyle: UIAlertController.Style.alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil)
        myalert.addAction(okAction)
        present(myalert, animated: true, completion: nil)
    }
    
    // ==========================================================================================
    // ====================================== CROP VIDEO ========================================
    // ==========================================================================================
    
    func cropVideo(sourceURL: URL, startTime: Double, endTime: Double, completion: ((_ outputUrl: URL) -> Void)? = nil) {
        
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        
        let asset = AVAsset(url: sourceURL)
        let length = Float(asset.duration.value) / Float(asset.duration.timescale)
        print("video length: \(length) seconds")
        
        var outputURL = documentDirectory.appendingPathComponent("output")
        do {
            try fileManager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
            outputURL = outputURL.appendingPathComponent("\(sourceURL.lastPathComponent)")
        }catch let error {
            print(error)
        }
        
        print("output url: \(outputURL)")
        //Remove existing file
        try? fileManager.removeItem(at: outputURL)
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough) else { return }
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mp4
        exportSession.shouldOptimizeForNetworkUse = true
        print("defualt video url: \(sourceURL)")
        print("croped video url: \(exportSession.outputURL!)")
        
        let timeRange = CMTimeRange(start: CMTime(seconds: startTime, preferredTimescale: 1000),
                                    end: CMTime(seconds: endTime, preferredTimescale: 1000))
        
        exportSession.timeRange = timeRange
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                completion?(outputURL)
            case .failed:
                print("failed \(exportSession.error.debugDescription)")
            case .cancelled:
                print("cancelled \(exportSession.error.debugDescription)")
            default: break
            }
        }
    }
    
    // Remove Observer
    deinit {
        print("de init calling")
        NotificationCenter.default.removeObserver(self)
    }
    
}

