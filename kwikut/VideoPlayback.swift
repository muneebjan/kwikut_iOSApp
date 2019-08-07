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
    let musicButton: UIButton = {
        let button = UIButton()
        button.setTitle("Add Music", for: .normal)
        button.addTarget(self, action: #selector(addMusicButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let saveButton: UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.addTarget(self, action: #selector(saveVideoButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
//    let context = CIContext(eaglContext: EAGLContext(api: .openGLES3) ?? EAGLContext(api: .openGLES2)!)

    var delegate: sendingDataBacktoViewController?
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
    let myPickerController = UIImagePickerController()
    let dkpicker = DKImagePickerController()
    
    
    @IBOutlet weak var videoImageView: UIImageView!
    
    
    // view will appear
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        print("merge button: \(UserDefaults.standard.bool(forKey: "mergePressed"))")
        
        if(UserDefaults.standard.bool(forKey: "mergePressed")){
            self.musicButton.isHidden = false
        }else{
            self.musicButton.isHidden = true
        }
        
        if(self.tapCheck){
            self.musicButton.isHidden = false
            self.saveButton.isHidden = false
        }else{
            self.musicButton.isHidden = true
            self.saveButton.isHidden = true
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // observer
        NotificationCenter.default.addObserver(self, selector: #selector(finishVideo), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.avPlayer.currentItem)

        // back button target
        self.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        
        avPlayerLayer = AVPlayerLayer(player: avPlayer)
        avPlayerLayer.frame = view.bounds
        avPlayerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoImageView.layer.insertSublayer(avPlayerLayer, at: 0)

        view.layoutIfNeeded()
        
        let playerItem = AVPlayerItem(url: videoURL as URL)
        avPlayer.replaceCurrentItem(with: playerItem)
        avPlayer.play()
        
        addGesture()
        
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
        topContainerView.addSubview(musicButton)
        topContainerView.addSubview(saveButton)
        
        // =================== CONSTRAINTS ====================

        topContainerView.topAnchor.constraint(equalTo: videoImageView.topAnchor).isActive = true
        topContainerView.leftAnchor.constraint(equalTo: videoImageView.leftAnchor).isActive = true
        topContainerView.rightAnchor.constraint(equalTo: videoImageView.rightAnchor).isActive = true
        topContainerView.heightAnchor.constraint(equalTo: videoImageView.heightAnchor, multiplier: 0.1).isActive = true
        
        backButton.centerYAnchor.constraint(equalTo: topContainerView.centerYAnchor).isActive = true
        backButton.leftAnchor.constraint(equalTo: topContainerView.leftAnchor, constant: 20).isActive = true
        backButton.heightAnchor.constraint(equalTo: topContainerView.heightAnchor, multiplier: 0.35).isActive = true
        backButton.widthAnchor.constraint(equalTo: topContainerView.heightAnchor, multiplier: 0.35).isActive = true
        
        

//        backButton.centerYAnchor.constraint(equalTo: topContainerView.centerYAnchor).isActive = true
//        backButton.leftAnchor.constraint(equalTo: topContainerView.leftAnchor, constant: 10).isActive = true

        
        musicButton.rightAnchor.constraint(equalTo: topContainerView.rightAnchor, constant: -10).isActive = true
        musicButton.centerYAnchor.constraint(equalTo: topContainerView.centerYAnchor).isActive = true
        
        saveButton.centerXAnchor.constraint(equalTo: topContainerView.centerXAnchor).isActive = true
        saveButton.centerYAnchor.constraint(equalTo: topContainerView.centerYAnchor).isActive = true
        
    }
    
    
// ==========================================================================================
// ================================ PLAYING VIDEO FUNCTION ==================================
// ==========================================================================================

    //
    func playingVideo(videoUrl: URL, filterNames: String, completion:@escaping (_ exporter: AVAssetExportSession) -> ()) -> Void {
        let playerItem = AVPlayerItem(url: videoUrl)
        let filterComposition = createVideoComposition(for: playerItem, filterName: filterNames)

        playerItem.videoComposition = filterComposition
// =================================
        
        let outputFileURL = URL(fileURLWithPath: NSTemporaryDirectory() + "filteredVideo.mp4")
        let fileManager = FileManager()

        do {
            try fileManager.removeItem(at: outputFileURL)
        } catch let error as NSError {
            print("Error: \(error.domain)")
        }

        let exporter = AVAssetExportSession(asset: playerItem.asset, presetName: AVAssetExportPresetHighestQuality)
        
        self.filteredVideoURL = outputFileURL
        print("save filtered URL: \(self.filteredVideoURL)")
        exporter?.outputURL = outputFileURL
        exporter?.shouldOptimizeForNetworkUse = true
        exporter?.outputFileType = AVFileType.mp4
        exporter?.videoComposition = filterComposition

        exporter?.exportAsynchronously {
            DispatchQueue.main.async {
                completion(exporter!)
            }
        }
        
// =================================
        avPlayer.replaceCurrentItem(with: playerItem)
        avPlayer.play()
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
    
// ==========================================================================================
// ==================================== ADDING FILTERS ======================================
// ==========================================================================================
    
    func createVideoComposition(for playerItem: AVPlayerItem, filterName: String) -> AVVideoComposition {
        let composition = AVVideoComposition(asset: playerItem.asset, applyingCIFiltersWithHandler: { request in
            // Here we can use any CIFilter
            guard let filter = CIFilter(name: filterName) else {
                return request.finish(with: NSError())
            }
            filter.setValue(request.sourceImage, forKey: kCIInputImageKey)
            return request.finish(with: filter.outputImage!, context: nil)
        })
        return composition
        
    }
    
// ==========================================================================================
// ==================================== ADDING GESTURE ======================================
// ==========================================================================================

    func addGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(retakeActionSheet))
        let filtertap = UITapGestureRecognizer(target: self, action: #selector(filtersActionSheet))
        
        if(UserDefaults.standard.bool(forKey: "mergePressed")){
            view.addGestureRecognizer(filtertap)
        }else{
            view.addGestureRecognizer(tap)
        }
        let pinch = UIPinchGestureRecognizer(target: self, action: #selector(zoomPinchFunction))
        view.addGestureRecognizer(pinch)
    }


    
// ==========================================================================================
// ===================================== ACTION SHEET =======================================
// ==========================================================================================
    
    var imagescale: CGFloat = 1.0
    let maxScale: CGFloat = 2.0
    let minScale: CGFloat = 1.0
    
    @objc func zoomPinchFunction(_ pinch: UIPinchGestureRecognizer){
        print("pinch started\(pinch.scale)")
        
        if (pinch.state == UIGestureRecognizer.State.began || pinch.state == UIGestureRecognizer.State.changed) {
            let pinchScale = pinch.scale

            if imagescale * pinchScale < maxScale && imagescale * pinchScale > minScale{
                imagescale *= pinchScale
                let transform = CGAffineTransform.init(scaleX: imagescale, y: imagescale)
                avPlayerLayer.setAffineTransform(transform)
            }
            pinch.scale = 1.0
        }
        
    }
    
    
    func musicActionSheet() {

        
        let actionsheet: LCActionSheet = LCActionSheet(title: "Select a song", cancelButtonTitle: "None", clicked: { (lcactionSheet, index) in
            print("actionsheet: \(lcactionSheet), index: \(index)")
            
            if(index == 0){
                print("cancel pressed")
            }
            if(index == 1){
                self.playBackgroundMusic(fileName: "melodyloops-skater.mp3")
            }
            if(index == 2){
                self.playBackgroundMusic(fileName: "melodyloops-the-first-light.mp3")
            }
            if(index == 3){
                self.playBackgroundMusic(fileName: "melodyloops-find-the-key.mp3")
            }
            if(index == 4){
                self.playBackgroundMusic(fileName: "melodyloops-winter-love.mp3")
            }
            if(index == 5){
                self.playBackgroundMusic(fileName: "melodyloops-travel-dreams.mp3")
            }
            if(index == 6){
                let url = UserDefaults.standard.url(forKey: "audioURL")!
                self.playBackgroundMusicOriginal(newURL: url)
            }
            
            
        }, otherButtonTitleArray: ["skater", "the first light", "find the key", "winter love", "travel dreams", "Keep Original Audio"])
        actionsheet.show()
        
    }
    

    
    @objc func filtersActionSheet(){
        
        let actionsheet: LCActionSheet = LCActionSheet(title: "Filters", cancelButtonTitle: "None", clicked: { (lcactionSheet, index) in
            print("actionsheet: \(lcactionSheet), index: \(index)")
            
            if(index == 0){
                print("no filter select")
                self.tapCheck = true
                let playerItem = AVPlayerItem(url: self.videoURL)
                self.avPlayer.replaceCurrentItem(with: playerItem)
                self.avPlayer.play()
                self.musicButton.isHidden = false
                self.saveButton.isHidden = false
            }
            if(index == 1){
                self.tapCheck = true
                self.saveButton.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .normal)
                self.saveButton.isEnabled = false
                self.musicButton.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .normal)
                self.musicButton.isEnabled = false
                self.playingVideo(videoUrl: self.videoURL, filterNames: "CIPhotoEffectChrome", completion: { (AVAssetExportSession) in
                    print("printing Video URL: \(AVAssetExportSession.outputURL!)")
                    self.saveButton.isEnabled = true
                    self.saveButton.setTitleColor(UIColor.white.withAlphaComponent(1), for: .normal)
                    self.musicButton.isEnabled = true
                    self.musicButton.setTitleColor(UIColor.white.withAlphaComponent(1), for: .normal)
                })
                self.musicButton.isHidden = false
                self.saveButton.isHidden = false
            }
            if(index == 2){
                self.tapCheck = true
                self.saveButton.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .normal)
                self.saveButton.isEnabled = false
                self.musicButton.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .normal)
                self.musicButton.isEnabled = false
                self.playingVideo(videoUrl: self.videoURL, filterNames: "CISepiaTone", completion: { (AVAssetExportSession) in
                    print("printing Video URL: \(AVAssetExportSession.outputURL!)")
                    self.saveButton.isEnabled = true
                    self.saveButton.setTitleColor(UIColor.white.withAlphaComponent(1), for: .normal)
                    self.musicButton.isEnabled = true
                    self.musicButton.setTitleColor(UIColor.white.withAlphaComponent(1), for: .normal)
                })
                self.musicButton.isHidden = false
                self.saveButton.isHidden = false

            }
            if(index == 3){
                self.tapCheck = true
                self.saveButton.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .normal)
                self.saveButton.isEnabled = false
                self.musicButton.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .normal)
                self.musicButton.isEnabled = false
                self.playingVideo(videoUrl: self.videoURL, filterNames: "CIPhotoEffectTransfer", completion: { (AVAssetExportSession) in
                    print("printing Video URL: \(AVAssetExportSession.outputURL!)")
                    self.saveButton.isEnabled = true
                    self.saveButton.setTitleColor(UIColor.white.withAlphaComponent(1), for: .normal)
                    self.musicButton.isEnabled = true
                    self.musicButton.setTitleColor(UIColor.white.withAlphaComponent(1), for: .normal)
                })
                self.musicButton.isHidden = false
                self.saveButton.isHidden = false
            }
            if(index == 4){
                self.tapCheck = true
                self.saveButton.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .normal)
                self.saveButton.isEnabled = false
                self.musicButton.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .normal)
                self.musicButton.isEnabled = false
                self.playingVideo(videoUrl: self.videoURL, filterNames: "CIPhotoEffectTonal", completion: { (AVAssetExportSession) in
                    print("printing Video URL: \(AVAssetExportSession.outputURL!)")
                    self.saveButton.isEnabled = true
                    self.saveButton.setTitleColor(UIColor.white.withAlphaComponent(1), for: .normal)
                    self.musicButton.isEnabled = true
                    self.musicButton.setTitleColor(UIColor.white.withAlphaComponent(1), for: .normal)
                })
                self.musicButton.isHidden = false
                self.saveButton.isHidden = false
            }
            if(index == 5){
                self.tapCheck = true
                self.saveButton.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .normal)
                self.saveButton.isEnabled = false
                self.musicButton.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .normal)
                self.musicButton.isEnabled = false
                self.playingVideo(videoUrl: self.videoURL, filterNames: "CIPhotoEffectProcess", completion: { (AVAssetExportSession) in
                    print("printing Video URL: \(AVAssetExportSession.outputURL!)")
                    self.saveButton.isEnabled = true
                    self.saveButton.setTitleColor(UIColor.white.withAlphaComponent(1), for: .normal)
                    self.musicButton.isEnabled = true
                    self.musicButton.setTitleColor(UIColor.white.withAlphaComponent(1), for: .normal)
                })
                self.musicButton.isHidden = false
                self.saveButton.isHidden = false
            }
            
        }, otherButtonTitleArray: ["Chrome Effect", "SepiaTone", "Transfer Effect", "Tonal Effect", "Process Effect"])
        actionsheet.show()
        
    }
    
    @objc func retakeActionSheet(){

        let actionSheet = UIAlertController(title: "Options", message: "Would you like to Retake this Clip?", preferredStyle: .actionSheet)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            print("cancel pressed")
            self.performSegue(withIdentifier: "unwindToFifteenSeconds", sender: self)

        }
        
        let retake = UIAlertAction(title: "Retake", style: .default) { (action) in
            print("retake pressed")
            UserDefaults.standard.set(true, forKey: "retakePressed")
            UserDefaults.standard.synchronize()
            self.performSegue(withIdentifier: "unwindToFifteenSeconds", sender: self)
        }
        let chooseVideoFromGallery = UIAlertAction(title: "Choose Video From Gallery", style: .default) { (action) in
            print("gallery open")
    
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                self.myPickerController.delegate = self
                self.myPickerController.sourceType = .photoLibrary
                self.myPickerController.mediaTypes = [kUTTypeMovie as String]
//                self.myPickerController.mediaTypes = ["public.movie"]
                self.present(self.myPickerController, animated: true, completion: nil)
            }
            
        }

        actionSheet.addAction(retake)
        actionSheet.addAction(chooseVideoFromGallery)
        actionSheet.addAction(cancel)

        present(actionSheet, animated: true, completion: nil)

    }
// UIimagePIcker Controller delegate
    
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
        self.performSegue(withIdentifier: "unwindToFifteenSeconds", sender: self)
    }
    
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
    
// music button
    @objc func addMusicButtonTapped() {
        print("add music button tapped")
        musicActionSheet()
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


