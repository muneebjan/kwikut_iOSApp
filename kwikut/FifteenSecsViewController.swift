import UIKit
import AVFoundation
import CoreMedia
import CountdownLabel
import Photos
import QBImagePickerController
import SwiftVideoGenerator
import RAReorderableLayout


class FifteenSecsViewController: UIViewController, AVCaptureFileOutputRecordingDelegate, RAReorderableLayoutDelegate, RAReorderableLayoutDataSource, UINavigationControllerDelegate {
    
    // , UIImagePickerControllerDelegate, UINavigationControllerDelegate
    
    // ELEMEMTS
    
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
    
    let collectionViewPreviewContainer: UICollectionView = {
        let layout = RAReorderableLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = UIColor.clear
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let countDownlabel: CountdownLabel = {
        let label = CountdownLabel()
        label.textColor = .white
        label.text = "3"
        label.font = UIFont.systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let bottomContainerView: UIView = {
        let view = UIView()
        //        view.backgroundColor = UIColor.black.withAlphaComponent(0.15)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let bottomIconsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let cameraButton: UIView = {
        let button = UIView()
        button.backgroundColor = UIColor.red
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 23
        button.clipsToBounds = true
        return button
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
    let switchCameraButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icons8-switch-camera-100.png"), for: UIControl.State.normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    let galleryButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "gallery.png"), for: UIControl.State.normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    var removingURL: String = ""
    private let cellId = "cellId"
    var isSwitchTapped: Bool = false
    var collectionImage: [UIImage] = []
    var URLcollection: [URL] = []
    var videoModeCheck: Int = 0
    var selectedVideoIndex: Int = 0
    var importedVideoIndex: [Int] = []
    let myPickerController = UIImagePickerController()
    var filteredVideoExists: Bool = false
    var audioFileURL: URL!
    
    var filmTapped: Bool?
    
    
    let qbpicker = QBImagePickerController()
    
    var importedAssetArray:[PHAsset] = []
    // OUTLETS
    
    @IBOutlet weak var camPreview: UIView!
    
    let captureSession = AVCaptureSession()
    let movieOutput = AVCaptureMovieFileOutput()
    var previewLayer: AVCaptureVideoPreviewLayer!
    var activeInput: AVCaptureDeviceInput!
    var outputURL: URL!
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let vc = segue.destination as! VideoPlayback
        vc.videoURL = sender as! URL
        vc.videoCount = URLcollection.count
        vc.delegate = self
        
    }
    
    
    // VIEW WILL APPEAR
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if self.filmTapped == true {
            print("film tapped")
        }
        
        UserDefaults.standard.set(nil, forKey: "mergePressed")
        UserDefaults.standard.synchronize()
        
        //        UserDefaults.standard.set(nil, forKey: "retakePressed")
        //        UserDefaults.standard.synchronize()
        
        print("Screen Selected: \(self.videoModeCheck)")
        UIApplication.shared.keyWindow?.windowLevel = UIWindow.Level.statusBar
        
        if(UserDefaults.standard.bool(forKey: "retakePressed")){
            print("retakePressed is true")
            self.countDownlabel.text = "Please Retake"
        }else{
            print("else statement")
            return
        }
        
    }
    
    
    let merge = Merge(config: .standard)
    
    
    // VIEW DID LOAD
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        qbpicker.delegate = self
        // ==========================================================================
        
        if setupSession() {
            setupPreview()
            startSession()
        }
        
        // switch Camera button Target
        self.switchCameraButton.addTarget(self, action: #selector(switchButtonTapped), for: .touchUpInside)
//        self.galleryButton.addTarget(self, action: #selector(openGallery), for: .touchUpInside)
        self.galleryButton.addTarget(self, action: #selector(showActionSheet), for: .touchUpInside)
        
        
        // back button target
        self.backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        
        // CAMERA BUTTON TARGET
        cameraButton.isUserInteractionEnabled = true
        //        let cameraButtonRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(FifteenSecsViewController.startCapture))
        let cameraButtonRecognizer = UITapGestureRecognizer(target: self, action: #selector(FifteenSecsViewController.startCapture))
        cameraButton.addGestureRecognizer(cameraButtonRecognizer)
        
        
        countDownlabel.countdownDelegate = self
        
//        (collectionViewPreviewContainer.collectionViewLayout as! RAReorderableLayout).scrollDirection = .horizontal
        collectionViewPreviewContainer.delegate = self
        collectionViewPreviewContainer.dataSource = self
        
        collectionViewPreviewContainer.register(baseCell.self, forCellWithReuseIdentifier: self.cellId)
        
        
        
        // CALLING SETUP
        setupView()
//        addGesture()
        
    }
    
    // ADDING GESTURES
    
//    func addGesture() {
//        let tap = UITapGestureRecognizer(target: self, action: #selector(showActionSheet))
//        view.addGestureRecognizer(tap)
//
//
//    }
    
    // CUSTOM VIEW SETUP
    
    func setupView() {
        
        // ================= ADDING VIEWS ======================
        
        camPreview.addSubview(bottomIconsContainerView)
        bottomIconsContainerView.addSubview(outerCameraButton)
        outerCameraButton.addSubview(cameraButton)
        camPreview.addSubview(topContainerView)
        topContainerView.addSubview(backButton)
        //        camPreview.addSubview(switchCameraButton)
        bottomIconsContainerView.addSubview(switchCameraButton)
        bottomIconsContainerView.addSubview(galleryButton)
        //        camPreview.addSubview(galleryButton)
        camPreview.addSubview(bottomContainerView)
        bottomContainerView.addSubview(collectionViewPreviewContainer)
        topContainerView.addSubview(countDownlabel)
        
        countDownlabel.isHidden = true
        //        switchCameraButton.isHidden = true
        
        
        bottomContainerView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        // =================== CONSTRAINTS ====================
        
        
        let bottomIconsContainerViewConstraints: [NSLayoutConstraint] = [
            bottomIconsContainerView.bottomAnchor.constraint(equalTo: camPreview.bottomAnchor),
            bottomIconsContainerView.leftAnchor.constraint(equalTo: camPreview.leftAnchor),
            bottomIconsContainerView.rightAnchor.constraint(equalTo: camPreview.rightAnchor),
            bottomIconsContainerView.heightAnchor.constraint(equalTo: camPreview.heightAnchor, multiplier: 0.13)
        ]
        
        let CameraButtonViewConstraints: [NSLayoutConstraint] = [
            cameraButton.centerYAnchor.constraint(equalTo: outerCameraButton.centerYAnchor),
            cameraButton.centerXAnchor.constraint(equalTo: outerCameraButton.centerXAnchor),
            cameraButton.widthAnchor.constraint(equalToConstant: 46),
            cameraButton.heightAnchor.constraint(equalToConstant: 46)
        ]
        let OuterCameraButtonViewConstraints: [NSLayoutConstraint] = [
            outerCameraButton.centerYAnchor.constraint(equalTo: bottomIconsContainerView.centerYAnchor),
            outerCameraButton.centerXAnchor.constraint(equalTo: bottomIconsContainerView.centerXAnchor),
            outerCameraButton.widthAnchor.constraint(equalToConstant: 60),
            outerCameraButton.heightAnchor.constraint(equalToConstant: 60)
        ]
        
        let topContainerViewConstraints: [NSLayoutConstraint] = [
            topContainerView.topAnchor.constraint(equalTo: camPreview.topAnchor),
            topContainerView.leftAnchor.constraint(equalTo: camPreview.leftAnchor),
            topContainerView.rightAnchor.constraint(equalTo: camPreview.rightAnchor),
            topContainerView.heightAnchor.constraint(equalTo: camPreview.heightAnchor, multiplier: 0.1)
        ]
        let backButtonConstraints: [NSLayoutConstraint] = [
            backButton.centerYAnchor.constraint(equalTo: topContainerView.centerYAnchor),
            backButton.leftAnchor.constraint(equalTo: topContainerView.leftAnchor, constant: 20),
            backButton.heightAnchor.constraint(equalTo: topContainerView.heightAnchor, multiplier: 0.35),
            backButton.widthAnchor.constraint(equalTo: topContainerView.heightAnchor, multiplier: 0.35)
        ]
        let switchButtonConstraints: [NSLayoutConstraint] = [
            switchCameraButton.centerYAnchor.constraint(equalTo: outerCameraButton.centerYAnchor),
            switchCameraButton.rightAnchor.constraint(equalTo: camPreview.rightAnchor, constant: -30),
            switchCameraButton.widthAnchor.constraint(equalToConstant: 40),
            switchCameraButton.heightAnchor.constraint(equalToConstant: 40)
        ]
        let galleryButtonConstraints: [NSLayoutConstraint] = [
            galleryButton.centerYAnchor.constraint(equalTo: outerCameraButton.centerYAnchor),
            galleryButton.leftAnchor.constraint(equalTo: camPreview.leftAnchor, constant: 30),
            galleryButton.widthAnchor.constraint(equalToConstant: 40),
            galleryButton.heightAnchor.constraint(equalToConstant: 40)
        ]
        let bottomContainerViewConstraints: [NSLayoutConstraint] = [
            bottomContainerView.bottomAnchor.constraint(equalTo: bottomIconsContainerView.topAnchor, constant: -10),
            bottomContainerView.leftAnchor.constraint(equalTo: camPreview.leftAnchor),
            bottomContainerView.rightAnchor.constraint(equalTo: camPreview.rightAnchor),
            bottomContainerView.heightAnchor.constraint(equalTo: camPreview.widthAnchor, multiplier: 1/5)
        ]
        let collectionImageViewConstraints: [NSLayoutConstraint] = [
            collectionViewPreviewContainer.bottomAnchor.constraint(equalTo: bottomContainerView.bottomAnchor),
            collectionViewPreviewContainer.topAnchor.constraint(equalTo: bottomContainerView.topAnchor),
            collectionViewPreviewContainer.leftAnchor.constraint(equalTo: bottomContainerView.leftAnchor),
            collectionViewPreviewContainer.rightAnchor.constraint(equalTo: bottomContainerView.rightAnchor)
        ]
        let countDownLabelConstraints: [NSLayoutConstraint] = [
            countDownlabel.centerXAnchor.constraint(equalTo: topContainerView.centerXAnchor),
            countDownlabel.centerYAnchor.constraint(equalTo: topContainerView.centerYAnchor)
        ]
        
        // =================== ACTIVATING CONSTRAINTS ====================
        
        NSLayoutConstraint.activate(galleryButtonConstraints)
        NSLayoutConstraint.activate(CameraButtonViewConstraints)
        NSLayoutConstraint.activate(OuterCameraButtonViewConstraints)
        NSLayoutConstraint.activate(topContainerViewConstraints)
        NSLayoutConstraint.activate(backButtonConstraints)
        NSLayoutConstraint.activate(switchButtonConstraints)
        NSLayoutConstraint.activate(bottomContainerViewConstraints)
        NSLayoutConstraint.activate(collectionImageViewConstraints)
        NSLayoutConstraint.activate(countDownLabelConstraints)
        
        NSLayoutConstraint.activate(bottomIconsContainerViewConstraints)
    }
    
    // ==========================================================================================
    // =========================== FULL CAMERA SETUP FUNCTION ===================================
    // ==========================================================================================
    
    func setupPreview() {
        // Configure previewLayer
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        //        previewLayer.frame = camPreview.bounds
        previewLayer.frame = UIScreen.main.bounds
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        camPreview.layer.addSublayer(previewLayer)
    }
    
    //MARK:- Get Device
    
    func getDevice(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices: NSArray = AVCaptureDevice.devices() as NSArray
        for de in devices {
            let deviceConverted = de as! AVCaptureDevice
            if(deviceConverted.position == position){
                return deviceConverted
            }
        }
        return nil
    }
    
    
    let frontDevice: AVCaptureDevice? = {
        for device in AVCaptureDevice.devices(for: AVMediaType.video) {
            if device.position == .front {
                return device
            }
        }
        
        return nil
    }()
    
    lazy var frontDeviceInput: AVCaptureDeviceInput? = {
        if let _frontDevice = self.frontDevice {
            return try? AVCaptureDeviceInput(device: _frontDevice)
        }
        
        return nil
    }()
    
    //MARK:- Setup Camera
    
    func setupSession() -> Bool {
        
        captureSession.sessionPreset = AVCaptureSession.Preset.iFrame1280x720
        
        // Setup Camera
        let camera: AVCaptureDevice?
        camera = AVCaptureDevice.default(for: .video)
        
        do {
            let input = try AVCaptureDeviceInput(device: camera!)
            
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
                activeInput = input
            }
        } catch {
            print("Error setting device video input: \(error)")
            return false
        }
        
        // Setup Microphone
        
        let microphone = AVCaptureDevice.default(for: .audio)
        do {
            let micInput = try AVCaptureDeviceInput(device: microphone!)
            if captureSession.canAddInput(micInput) {
                captureSession.addInput(micInput)
            }
        } catch {
            print("Error setting device audio input: \(error)")
            return false
        }
        
        
        // Movie output
        let seconds : Int64 = 3
        let maxDuration = CMTime(seconds: Double(seconds), preferredTimescale: 1)
        movieOutput.maxRecordedDuration = maxDuration
        if captureSession.canAddOutput(movieOutput) {
            captureSession.addOutput(movieOutput)
        }
        
        return true
    }
    
    func setupCaptureMode(_ mode: Int) {
        // Video Mode
        
    }
    
    //MARK:- Camera Session
    func startSession() {
        
        
        if !captureSession.isRunning {
            videoQueue().async {
                self.captureSession.startRunning()
            }
        }
    }
    
    func stopSession() {
        if captureSession.isRunning {
            videoQueue().async {
                self.captureSession.stopRunning()
            }
        }
    }
    
    func videoQueue() -> DispatchQueue {
        return DispatchQueue.main
    }
    
    
    
    func currentVideoOrientation() -> AVCaptureVideoOrientation {
        var orientation: AVCaptureVideoOrientation
        
        switch UIDevice.current.orientation {
        case .portrait:
            orientation = AVCaptureVideoOrientation.portrait
        case .landscapeRight:
            orientation = AVCaptureVideoOrientation.landscapeLeft
        case .portraitUpsideDown:
            orientation = AVCaptureVideoOrientation.portraitUpsideDown
        default:
            orientation = AVCaptureVideoOrientation.landscapeRight
        }
        
        return orientation
    }
    
    //EDIT 1: I FORGOT THIS AT FIRST
    
    func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mov") // set it to mp4
            return URL(fileURLWithPath: path)
        }
        
        return nil
    }
    
    // START RECORDING
    
    func startRecording() {
        print("Recording Starts")
        
        self.cameraButton.isUserInteractionEnabled = false
        self.cameraButton.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        
        if movieOutput.isRecording == false {
            
            let connection = movieOutput.connection(with: AVMediaType.video)
            if (connection?.isVideoOrientationSupported)! {
                connection?.videoOrientation = currentVideoOrientation()
            }
            
            if (connection?.isVideoStabilizationSupported)! {
                connection?.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.auto
            }
            
            let device = activeInput.device
            if (device.isSmoothAutoFocusSupported) {
                do {
                    try device.lockForConfiguration()
                    device.isSmoothAutoFocusEnabled = false
                    device.unlockForConfiguration()
                } catch {
                    print("Error setting configuration: \(error)")
                }
                
            }
            
            //EDIT2: And I forgot this
            outputURL = tempURL()
            movieOutput.startRecording(to: outputURL, recordingDelegate: self)
            
            
        }
        else {
            stopRecording()
        }
        
    }
    
    // STOP RECORDING
    
    func stopRecording() {
        print("Recording Stops")
        if movieOutput.isRecording == true {
            movieOutput.stopRecording()
        }
    }
    
    // CONFIRMING PROTOCOL METHODS
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        
        
        if (error != nil) {
            print("Error recording movie: \(error!.localizedDescription)")
            
            self.cameraButton.isUserInteractionEnabled = true
            self.cameraButton.backgroundColor = .red
            
            
            let videoRecorded = outputURL! as URL
            print("this is url: \(videoRecorded)")
            

            self.cropVideo(sourceURL: videoRecorded, startTime: 0.0, endTime: 3.05) { (cropedURL) in
                print("croped URL: \(cropedURL)")
                
                DispatchQueue.main.async {
                    
                    let urlString = cropedURL.absoluteString
                    let thumbnail = self.createThumbnailOfVideoFromFileURL(urlString)
                    
                    if(UserDefaults.standard.bool(forKey: "retakePressed")){
                        print("userdefaults: \(UserDefaults.standard.bool(forKey: "retakePressed"))")
                        self.collectionImage.remove(at: self.selectedVideoIndex)
                        self.URLcollection.remove(at: self.selectedVideoIndex)
                        
                        self.collectionImage.insert(thumbnail!, at: self.selectedVideoIndex)
                        self.URLcollection.insert(cropedURL, at: self.selectedVideoIndex)
                        
                        self.cameraButton.isUserInteractionEnabled = true
                        
                        DispatchQueue.main.async {
                            self.collectionViewPreviewContainer.reloadData()
                        }
                        
                        UserDefaults.standard.set(nil, forKey: "retakePressed")
                        UserDefaults.standard.synchronize()
                        
                    }else{
                        print("else statement")
                        print("userdefaults: \(UserDefaults.standard.bool(forKey: "retakePressed"))")
                        if let thumbn = thumbnail{
                            self.collectionImage.append(thumbn)
                        }else{
                            print("found nil while unwrapping an optional value")
                        }
                        self.URLcollection.append(cropedURL)
                        print("url array count: \(self.URLcollection.count)")
                        self.cameraButton.isUserInteractionEnabled = true
                        
                        DispatchQueue.main.async {
                            self.collectionViewPreviewContainer.reloadData()
                        }
                    }
                    
                }
            }

//            let urlString = videoRecorded.absoluteString
//            let thumbnail = self.createThumbnailOfVideoFromFileURL(urlString)
//
//            if(UserDefaults.standard.bool(forKey: "retakePressed")){
//                print("userdefaults: \(UserDefaults.standard.bool(forKey: "retakePressed"))")
//                self.collectionImage.remove(at: self.selectedVideoIndex)
//                self.URLcollection.remove(at: self.selectedVideoIndex)
//
//                self.collectionImage.insert(thumbnail!, at: self.selectedVideoIndex)
//                self.URLcollection.insert(videoRecorded, at: self.selectedVideoIndex)
//
//                self.cameraButton.isUserInteractionEnabled = true
//
//                DispatchQueue.main.async {
//                    self.collectionViewPreviewContainer.reloadData()
//                }
//
//                UserDefaults.standard.set(nil, forKey: "retakePressed")
//                UserDefaults.standard.synchronize()
//
//            }else{
//                print("else statement")
//                print("userdefaults: \(UserDefaults.standard.bool(forKey: "retakePressed"))")
//                if let thumbn = thumbnail{
//                    self.collectionImage.append(thumbn)
//                }else{
//                    print("found nil while unwrapping an optional value")
//                }
//                self.URLcollection.append(videoRecorded)
//                print("url array count: \(URLcollection.count)")
//                self.cameraButton.isUserInteractionEnabled = true
//
//                DispatchQueue.main.async {
//                    self.collectionViewPreviewContainer.reloadData()
//                }
//            }
            
        } else {
            
            print("did Finish Recording Function : else statement")
            
        }
        
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        
    }
    
    // GETTING IMAGE THUMBNAIL FROM VIDEO
    
    func createThumbnailOfVideoFromFileURL(_ strVideoURL: String) -> UIImage?{
        
        let asset = AVAsset(url: URL(string: strVideoURL)!)
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(Float64(1), preferredTimescale: 600)
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
        } catch {
            /* error handling here */
        }
        return nil
        
    }
    
    
    // ==========================================================================================
    // ================================ OBJECTIVE C FUNCTION ====================================
    // ==========================================================================================
    
    
//    var videoUrl:URL // use your own url
    var frames:[UIImage] = []
    private var generator:AVAssetImageGenerator!
    
    func getAllFrames(sendingUrl: URL) {
        let asset:AVAsset = AVAsset(url:sendingUrl)
        let duration:Float64 = CMTimeGetSeconds(asset.duration)
        self.generator = AVAssetImageGenerator(asset:asset)
        self.generator.appliesPreferredTrackTransform = true
        self.frames = []
        for index:Int in 0 ..< Int(duration) {
            self.getFrame(fromTime:Float64(index))
        }
        self.generator = nil
    }
    
    private func getFrame(fromTime:Float64) {
        let time:CMTime = CMTimeMakeWithSeconds(fromTime, preferredTimescale:600)
        let image:CGImage
        do {
            try image = self.generator.copyCGImage(at:time, actualTime:nil)
        } catch {
            return
        }
        self.frames.append(UIImage(cgImage:image))
    }
    
    
    var videoFrames:[UIImage] = []
    func generateFrames(assetImgGenerate:AVAssetImageGenerator, fromTime:Float64) {
        
        let time:CMTime = CMTimeMakeWithSeconds(fromTime, preferredTimescale: 600)
        let cgImage:CGImage?
        
        do{
            cgImage = try assetImgGenerate.copyCGImage(at:time, actualTime:nil)
        }
        catch{
            cgImage = nil
        }
        guard let img:CGImage = cgImage else {
            return
        }
        
        let frameImg:UIImage = UIImage(cgImage:img)
        videoFrames.append(frameImg)
    }
    
    

    
    @objc func showActionSheet(){
        
        if(self.videoModeCheck == 1){
            if(self.URLcollection.count < 5){
                self.displayMyAlertMessage(userMessage: "Only 5 clips are allowed to merge")
            }else{
            
                    print("merging videos pressed")
                    self.filteredVideoExists = false
                    
                    //start loader
                    let sv = UIViewController.displaySpinner(onView: self.view)
                    
                    UserDefaults.standard.set(true, forKey: "mergePressed")
                    UserDefaults.standard.synchronize()
                    
                    print(self.URLcollection)
                    var arrayAVAsset: [AVAsset] = []
                    for url in self.URLcollection{
                        let asset = AVAsset(url: url)
                        arrayAVAsset.append(asset)
                        
                        if(url.pathExtension == "MP4" || url.pathExtension == "mp4"){
                            print("video extension is : MP4")
                            self.filteredVideoExists = true
                        }else{
                            print("video extension is not : MP4")
                        }
                        
                    }

                    if(self.filteredVideoExists){
                        print("KVVideoManager.Merge function called")
                        
                        KVVideoManager.shared.merge(arrayVideos: arrayAVAsset, completion: { (finalUrl, error) in
                            
                            let asset = AVURLAsset(url: finalUrl!, options: nil)
                            let pathWhereToSave = NSTemporaryDirectory().appending("myaudio.m4a")
                            let exportURL = URL.init(fileURLWithPath: pathWhereToSave)
                            
                            // Remove file if existed
                            FileManager.default.removeItemIfExisted(exportURL)
                            
                            asset.writeAudioTrackToURL(exportURL, completion: { (success, error) in
                                if(success){
                                    print("audio extracted successfull")
                                }
                            })
                            
                            self.removeAudioFromVideo(videoURL: finalUrl! as NSURL, completion: { (url, error) in
                                //                                print("url without audio: \(url!)")
                                UIViewController.removeSpinner(spinner: sv)
                                self.performSegue(withIdentifier: "showVideo", sender: url!)
                            })

                        })
                        
                    }else{
                        print("my merge function called")
                        
                        self.merge(arrayVideos: arrayAVAsset, completion: { (AVAssetExportSession) in

                            let asset = AVURLAsset(url: AVAssetExportSession.outputURL!, options: nil)
                            print("this is simple merge time: \(asset.duration.seconds)")
                            let pathWhereToSave = NSTemporaryDirectory().appending("myaudio.m4a")
                            let exportURL = URL.init(fileURLWithPath: pathWhereToSave)

                            // Remove file if existed
                            FileManager.default.removeItemIfExisted(exportURL)

                            asset.writeAudioTrackToURL(exportURL, completion: { (success, error) in
                                if(success){
//                                    print("url = \(UserDefaults.standard.value(forKey: "audioURL")!)")
                                }
                            })

                            self.removeAudioFromVideo(videoURL: AVAssetExportSession.outputURL! as NSURL, completion: { (url, error) in
//                                print("url without audio: \(url!)")
                                UIViewController.removeSpinner(spinner: sv)
                                let assets = AVURLAsset(url: url as! URL)
                                print("after removing audio merge time is : \(assets.duration.seconds)")
                                self.performSegue(withIdentifier: "showVideo", sender: url!)
                            })

                        })
                        
                    }
                
            }
        }
        else if(self.videoModeCheck == 2){
            print("url collection count: \(self.URLcollection.count)")
            if(self.URLcollection.count < 10){
                self.displayMyAlertMessage(userMessage: "Only 10 clips are allowed to merge")
            }else{
            
                    print("merging videos pressed")
                    
                    //start loader
                    let sv = UIViewController.displaySpinner(onView: self.view)
                    
                    UserDefaults.standard.set(true, forKey: "mergePressed")
                    UserDefaults.standard.synchronize()
                    
                    var arrayAVAsset: [AVAsset] = []
                    for url in self.URLcollection{
                        let asset = AVAsset(url: url)
                        arrayAVAsset.append(asset)
                        
                        if(url.pathExtension == "MP4" || url.pathExtension == "mp4"){
                            print("video extension is : MP4")
                            self.filteredVideoExists = true
                        }else{
                            print("video extension is not : MP4")
                        }
                        
                    }
                    
                    
                    if(self.filteredVideoExists){
                        
                        print("KVVideoManager.Merge function called")
                        
                        KVVideoManager.shared.merge(arrayVideos: arrayAVAsset, completion: { (finalUrl, error) in
                            
                            let asset = AVURLAsset(url: finalUrl!, options: nil)
                            let pathWhereToSave = NSTemporaryDirectory().appending("myaudio.m4a")
                            let exportURL = URL.init(fileURLWithPath: pathWhereToSave)
                            
                            // Remove file if existed
                            FileManager.default.removeItemIfExisted(exportURL)
                            
                            asset.writeAudioTrackToURL(exportURL, completion: { (success, error) in
                                if(success){
                                    print("audio extracted successfull")
                                }
                            })
                            
                            self.removeAudioFromVideo(videoURL: finalUrl! as NSURL, completion: { (url, error) in
                                //                                print("url without audio: \(url!)")
                                UIViewController.removeSpinner(spinner: sv)
                                self.performSegue(withIdentifier: "showVideo", sender: url!)
                            })
                            
                        })
                        
//                        print("KVVideoManager.Merge function called")
//                        KVVideoManager.shared.merge(arrayVideos: arrayAVAsset, completion: { (finalUrl, error) in
//                            print("printing merging url 1 : \(finalUrl)")
//                            UIViewController.removeSpinner(spinner: sv)
//                            self.performSegue(withIdentifier: "showVideo", sender: finalUrl!)
//                        })
                    }else{
                        
                        print("my merge function called")
                        
                        self.merge(arrayVideos: arrayAVAsset, completion: { (AVAssetExportSession) in
                            
                            let asset = AVURLAsset(url: AVAssetExportSession.outputURL!, options: nil)
                            print("this is simple merge time: \(asset.duration.seconds)")
                            let pathWhereToSave = NSTemporaryDirectory().appending("myaudio.m4a")
                            let exportURL = URL.init(fileURLWithPath: pathWhereToSave)
                            
                            // Remove file if existed
                            FileManager.default.removeItemIfExisted(exportURL)
                            
                            asset.writeAudioTrackToURL(exportURL, completion: { (success, error) in
                                if(success){
                                    //                                    print("url = \(UserDefaults.standard.value(forKey: "audioURL")!)")
                                }
                            })
                            
                            self.removeAudioFromVideo(videoURL: AVAssetExportSession.outputURL! as NSURL, completion: { (url, error) in
                                //                                print("url without audio: \(url!)")
                                UIViewController.removeSpinner(spinner: sv)
                                let assets = AVURLAsset(url: url as! URL)
                                print("after removing audio merge time is : \(assets.duration.seconds)")
                                self.performSegue(withIdentifier: "showVideo", sender: url!)
                            })
                            
                        })
                        
//                        print("my merge function called")
//                        self.merge(arrayVideos: arrayAVAsset, completion: { (AVAssetExportSession) in
//                            UIViewController.removeSpinner(spinner: sv)
//                            self.performSegue(withIdentifier: "showVideo", sender: AVAssetExportSession.outputURL!)
//                        })
                    }
                
            }
        }
        else if(self.videoModeCheck == 3){
            if(self.URLcollection.count < 20){
                self.displayMyAlertMessage(userMessage: "Only 20 clips are allowed to merge")
            }else{
                
                    print("merging videos pressed")
                    
                    //start loader
                    let sv = UIViewController.displaySpinner(onView: self.view)
                    
                    UserDefaults.standard.set(true, forKey: "mergePressed")
                    UserDefaults.standard.synchronize()
                    
                    var arrayAVAsset: [AVAsset] = []
                    for url in self.URLcollection{
                        let asset = AVAsset(url: url)
                        arrayAVAsset.append(asset)
                        
                        if(url.pathExtension == "MP4" || url.pathExtension == "mp4"){
                            print("video extension is : MP4")
                            self.filteredVideoExists = true
                        }else{
                            print("video extension is not : MP4")
                        }
                        
                    }
                    
                    
                    if(self.filteredVideoExists){
                        
                        print("KVVideoManager.Merge function called")
                        
                        KVVideoManager.shared.merge(arrayVideos: arrayAVAsset, completion: { (finalUrl, error) in
                            
                            let asset = AVURLAsset(url: finalUrl!, options: nil)
                            let pathWhereToSave = NSTemporaryDirectory().appending("myaudio.m4a")
                            let exportURL = URL.init(fileURLWithPath: pathWhereToSave)
                            
                            // Remove file if existed
                            FileManager.default.removeItemIfExisted(exportURL)
                            
                            asset.writeAudioTrackToURL(exportURL, completion: { (success, error) in
                                if(success){
                                    print("audio extracted successfull")
                                }
                            })
                            
                            self.removeAudioFromVideo(videoURL: finalUrl! as NSURL, completion: { (url, error) in
                                //                                print("url without audio: \(url!)")
                                UIViewController.removeSpinner(spinner: sv)
                                self.performSegue(withIdentifier: "showVideo", sender: url!)
                            })
                            
                        })
                        
//                        print("KVVideoManager.Merge function called")
//                        KVVideoManager.shared.merge(arrayVideos: arrayAVAsset, completion: { (finalUrl, error) in
//                            print("printing merging url 1 : \(finalUrl)")
//                            UIViewController.removeSpinner(spinner: sv)
//                            self.performSegue(withIdentifier: "showVideo", sender: finalUrl!)
//                        })
                        
                    }else{
                        
                        print("my merge function called")
                        
                        self.merge(arrayVideos: arrayAVAsset, completion: { (AVAssetExportSession) in
                            
                            let asset = AVURLAsset(url: AVAssetExportSession.outputURL!, options: nil)
                            print("this is simple merge time: \(asset.duration.seconds)")
                            let pathWhereToSave = NSTemporaryDirectory().appending("myaudio.m4a")
                            let exportURL = URL.init(fileURLWithPath: pathWhereToSave)
                            
                            // Remove file if existed
                            FileManager.default.removeItemIfExisted(exportURL)
                            
                            asset.writeAudioTrackToURL(exportURL, completion: { (success, error) in
                                if(success){
                                    //                                    print("url = \(UserDefaults.standard.value(forKey: "audioURL")!)")
                                }
                            })
                            
                            self.removeAudioFromVideo(videoURL: AVAssetExportSession.outputURL! as NSURL, completion: { (url, error) in
                                //                                print("url without audio: \(url!)")
                                UIViewController.removeSpinner(spinner: sv)
                                let assets = AVURLAsset(url: url as! URL)
                                print("after removing audio merge time is : \(assets.duration.seconds)")
                                self.performSegue(withIdentifier: "showVideo", sender: url!)
                            })
                            
                        })
                        
//                        print("my merge function called")
//                        self.merge(arrayVideos: arrayAVAsset, completion: { (AVAssetExportSession) in
//                            UIViewController.removeSpinner(spinner: sv)
//                            self.performSegue(withIdentifier: "showVideo", sender: AVAssetExportSession.outputURL!)
//                        })
                    }
                
            }
        }
        
    }
    
    func removeAudioFromVideo(videoURL: NSURL, completion: @escaping (NSURL?, NSError?) -> Void) -> Void {
        
        let fileManager = FileManager.default
        
        let composition = AVMutableComposition()
        
        let sourceAsset = AVURLAsset(url: videoURL as URL)
        
        let compositionVideoTrack = composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)
        
        let sourceVideoTrack: AVAssetTrack = sourceAsset.tracks(withMediaType: AVMediaType.video)[0]
        
        let x = CMTimeRangeMake(start: CMTime.zero, duration: sourceAsset.duration)
        
        try! compositionVideoTrack!.insertTimeRange(x, of: sourceVideoTrack, at: CMTime.zero)
        
        let exportPath : NSString = NSString(format: "%@%@", NSTemporaryDirectory(), "removeAudio.mov")
        
        let exportUrl: NSURL = NSURL.fileURL(withPath: exportPath as String) as NSURL
        
        if(fileManager.fileExists(atPath: exportPath as String)) {
            
            try! fileManager.removeItem(at: exportUrl as URL)
        }
        
        let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
        exporter!.outputURL = exportUrl as URL;
        exporter!.outputFileType = AVFileType.mov
        
//        exporter?.exportAsynchronouslyWithCompletionHandler({
//            dispatch_async(dispatch_get_main_queue(), {
//
//                completion(exporter?.outputURL, nil)
//            })
//
//        })
        exporter!.exportAsynchronously(completionHandler: {
            DispatchQueue.main.async {
                completion(exporter?.outputURL as NSURL?, nil)
            }
        })
    }
    
    
    @objc func startCapture(gestureRecognizer: UILongPressGestureRecognizer) {
        
        
        //        if gestureRecognizer.state == UIGestureRecognizer.State.began {
        
        if(self.videoModeCheck == 1){
            
            if(UserDefaults.standard.bool(forKey: "retakePressed")){
                
                self.countDownlabel.isHidden = false
                countDownlabel.setCountDownTime(minutes: 3)
                countDownlabel.timeFormat = "s"
                countDownlabel.countdownAttributedText = CountdownAttributedText(text: "HERE", replacement: "HERE")
                countDownlabel.start()
                startRecording()
                
            }else{
                if(collectionImage.count < 5){
                    self.countDownlabel.isHidden = false
                    countDownlabel.setCountDownTime(minutes: 3)
                    countDownlabel.timeFormat = "s"
                    countDownlabel.countdownAttributedText = CountdownAttributedText(text: "HERE", replacement: "HERE")
                    countDownlabel.start()
                    startRecording()
                }else{
                    self.displayMyAlertMessage(userMessage: "Only 5 Clips are Allowed")
                }
            }
            
        }else if(self.videoModeCheck == 2){
            
            if(UserDefaults.standard.bool(forKey: "retakePressed")){
                
                self.countDownlabel.isHidden = false
                countDownlabel.setCountDownTime(minutes: 3)
                countDownlabel.timeFormat = "s"
                countDownlabel.countdownAttributedText = CountdownAttributedText(text: "HERE", replacement: "HERE")
                countDownlabel.start()
                startRecording()
                
            }else{
                if(collectionImage.count < 10){
                    self.countDownlabel.isHidden = false
                    countDownlabel.setCountDownTime(minutes: 3)
                    countDownlabel.timeFormat = "s"
                    countDownlabel.countdownAttributedText = CountdownAttributedText(text: "HERE", replacement: "HERE")
                    countDownlabel.start()
                    startRecording()
                }else{
                    self.displayMyAlertMessage(userMessage: "Only 10 Clips are Allowed")
                }
            }
            
        }else if(self.videoModeCheck == 3){
            
            if(UserDefaults.standard.bool(forKey: "retakePressed")){
                
                self.countDownlabel.isHidden = false
                countDownlabel.setCountDownTime(minutes: 3)
                countDownlabel.timeFormat = "s"
                countDownlabel.countdownAttributedText = CountdownAttributedText(text: "HERE", replacement: "HERE")
                countDownlabel.start()
                startRecording()
                
            }else{
                if(collectionImage.count < 20){
                    self.countDownlabel.isHidden = false
                    countDownlabel.setCountDownTime(minutes: 3)
                    countDownlabel.timeFormat = "s"
                    countDownlabel.countdownAttributedText = CountdownAttributedText(text: "HERE", replacement: "HERE")
                    countDownlabel.start()
                    startRecording()
                }else{
                    self.displayMyAlertMessage(userMessage: "Only 20 Clips are Allowed")
                }
            }
        }else{
            print("video mode check is: \(self.videoModeCheck)")
        }
        
        //        }
        //        else if gestureRecognizer.state == UIGestureRecognizer.State.ended {
        //            debugPrint("longpress ended")
        //        }
        
    }
    
    
    @objc func switchButtonTapped(){
        
        captureSession.beginConfiguration()
        let currentInput = captureSession.inputs.first as? AVCaptureDeviceInput
        print("currently input devices used: \(currentInput)")
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            print("total inputs: \(inputs)")
            for input in inputs {
                print("input to be removed: \(input)")
                captureSession.removeInput(input)
            }
            
            let newCameraDevice = currentInput?.device.position == .back ? getDevice(position: .front) : getDevice(position: .back)
            let newVideoInput = try? AVCaptureDeviceInput(device: newCameraDevice!)
            captureSession.addInput(newVideoInput!)
            captureSession.commitConfiguration()
        }
        print("remaining inputs: \(captureSession.inputs)")
    }
    
    @objc func openGallery() {
        
        print("gallery open")
        
        if(videoModeCheck == 1){
            qbpicker.maximumNumberOfSelection = 5
        }else if(videoModeCheck == 2){
            qbpicker.maximumNumberOfSelection = 10
        }else if(videoModeCheck == 3){
            qbpicker.maximumNumberOfSelection = 20
        }else{
            print("nothing selected")
        }
        
        qbpicker.mediaType = .video
        qbpicker.allowsMultipleSelection = true
        qbpicker.showsNumberOfSelectedAssets = true
        self.present(qbpicker, animated: true, completion: nil)
        
    }
    
    @objc func backButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // ==========================================================================================
    // ========================= MERGING VIDEO CLIPS FUNCTION ===================================
    // ==========================================================================================
    
    
    func merge(arrayVideos:[AVAsset], completion:@escaping (_ exporter: AVAssetExportSession) -> ()) -> Void {


        // Create AVMutableComposition to contain all AVMutableComposition tracks
        let mix_composition = AVMutableComposition()
        var total_time = CMTime.zero

        // Loop over videos and create tracks, keep incrementing total duration
        let video_track = mix_composition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID())
        let audio_track = mix_composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID())

        let instruction = AVMutableVideoCompositionLayerInstruction(assetTrack: video_track!)
        
        for video in arrayVideos
        {
            print("recorded Video Duration: \(video.duration.seconds)")
            let shortened_duration = CMTimeSubtract(video.duration, CMTimeMake(value: 1,timescale: 10)); // CMTimeRangeGetIntersection
            let videoAssetTrack = video.tracks(withMediaType: AVMediaType.video)[0]
            let audioAssetTrack = video.tracks(withMediaType: AVMediaType.audio)[0]


            do
            {
                print("shortened Duration: \(shortened_duration.seconds)")
                try video_track!.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: shortened_duration), // shortened_duration
                                                 of: videoAssetTrack ,
                                                 at: total_time)

                video_track!.preferredTransform = videoAssetTrack.preferredTransform

                try audio_track!.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: shortened_duration), // shortened_duration
                                                 of: audioAssetTrack ,
                                                 at: total_time)

                audio_track!.preferredTransform = audioAssetTrack.preferredTransform


            }
            catch _
            {
            }

            instruction.setTransform(videoTransformForTrack(asset: video), at: total_time)

            // Add video duration to total time
            total_time = CMTimeAdd(total_time, shortened_duration)


        }

        // Create main instrcution for video composition
        let main_instruction = AVMutableVideoCompositionInstruction()
        main_instruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: total_time)
        main_instruction.layerInstructions = [instruction]

        let main_composition = AVMutableVideoComposition()
        main_composition.instructions = [main_instruction]
        main_composition.frameDuration = CMTimeMake(value: 1, timescale: 30)
        main_composition.renderSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)


        // Export to file
        let path = NSTemporaryDirectory().appending("mergedVideo123.mp4")
        let exportURL = URL.init(fileURLWithPath: path)

        // Remove file if existed
        FileManager.default.removeItemIfExisted(exportURL)

        let exporter = AVAssetExportSession(asset: mix_composition, presetName: AVAssetExportPresetHighestQuality)
        exporter!.outputURL = exportURL
        exporter!.outputFileType = AVFileType.mp4
        exporter!.shouldOptimizeForNetworkUse = true
        exporter!.videoComposition = main_composition


        exporter?.exportAsynchronously(completionHandler: {
            DispatchQueue.main.async {
                completion(exporter!)
            }
        })


    }
    
    
    // ==========================================================================================
    // ========================= PROTOCOL CONFIRMING FUNCTION ===================================
    // ==========================================================================================
    
    
    fileprivate func orientationFromTransform(transform: CGAffineTransform) -> (orientation: UIImage.Orientation, isPortrait: Bool) {
        var assetOrientation = UIImage.Orientation.up
        var isPortrait = false
        if transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0 {
            assetOrientation = .right
            isPortrait = true
        } else if transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0 {
            assetOrientation = .left
            isPortrait = true
        } else if transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0 {
            assetOrientation = .up
        } else if transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0 {
            assetOrientation = .down
        }
        return (assetOrientation, isPortrait)
    }
    
    func videoTransformForTrack(asset: AVAsset) -> CGAffineTransform
    {
        var return_value:CGAffineTransform?
        
        let assetTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
        
        let transform = assetTrack.preferredTransform
        let assetInfo = orientationFromTransform(transform: transform)
        
        var scaleToFitRatio = UIScreen.main.bounds.width / assetTrack.naturalSize.width
        
        if assetInfo.isPortrait
        {
            scaleToFitRatio = UIScreen.main.bounds.width / assetTrack.naturalSize.height
            let scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
            return_value = assetTrack.preferredTransform.concatenating(scaleFactor)
        }
        else
        {
            var scaleFactor = CGAffineTransform(scaleX: scaleToFitRatio, y: scaleToFitRatio)
//            scaleFactor.a = 0.7
//            scaleFactor.d = 0.7
            
            scaleFactor.a = 0.6
            scaleFactor.d = 0.7
            
            print("scaling factor: \(scaleFactor)")
            var concat = assetTrack.preferredTransform.concatenating(scaleFactor).concatenating(CGAffineTransform(translationX: 0, y: 0)) //UIScreen.main.bounds.width / 2
            print("this is concat: \(concat)")
            if assetInfo.orientation == .down
            {
                let fixUpsideDown = CGAffineTransform(rotationAngle: CGFloat(M_PI))
                let windowBounds = UIScreen.main.bounds
                let yFix = assetTrack.naturalSize.height + windowBounds.height
                let centerFix = CGAffineTransform(translationX: assetTrack.naturalSize.width, y: yFix)
                concat = fixUpsideDown.concatenating(centerFix).concatenating(scaleFactor)
            }
            return_value = concat
        }
        return return_value!
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
        
        //Remove existing file
        try? fileManager.removeItem(at: outputURL)
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetPassthrough) else { return }
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mp4
        exportSession.shouldOptimizeForNetworkUse = true
        
//        print("croped video url: \(exportSession.outputURL!)")
        
        let timeRange = CMTimeRange(start: CMTime(seconds: startTime, preferredTimescale: 1000),
                                    end: CMTime(seconds: endTime, preferredTimescale: 1000))
        
        exportSession.timeRange = timeRange
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
//                UserDefaults.standard.set(outputURL, forKey: "cropedVideoURL")
//                UserDefaults.standard.synchronize()
                completion?(outputURL)
            case .failed:
                print("failed \(exportSession.error.debugDescription)")
            case .cancelled:
                print("cancelled \(exportSession.error.debugDescription)")
            default: break
            }
        }
    }
    
    // MARK:- COLLECTION VIEW FUNCTIONS
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionImage.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let imageArray = collectionImage[indexPath.row]
        let cell = self.collectionViewPreviewContainer.dequeueReusableCell(withReuseIdentifier: self.cellId, for: indexPath) as! baseCell
        
        // =============== ADDING CONSTRAINTS ====================
        
        //        cell.backgroundColor = .green
        
//        cell.imagePreview.layer.cornerRadius = 7
        cell.imagePreview.clipsToBounds = true
//        cell.imagePreview.layer.borderWidth = 2
        cell.imagePreview.contentMode = .scaleAspectFill
//        cell.imagePreview.layer.borderColor = UIColor.white.cgColor
        
        cell.imagePreview.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(cell.imagePreview)
        
        cell.imagePreview.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -7).isActive = true
        cell.imagePreview.topAnchor.constraint(equalTo: cell.topAnchor, constant: 7).isActive = true
        cell.imagePreview.leftAnchor.constraint(equalTo: cell.leftAnchor, constant: 7).isActive = true
        
        cell.imagePreview.widthAnchor.constraint(equalTo: cell.widthAnchor, constant: -7).isActive = true
        
//        cell.imagePreview.widthAnchor.constraint(equalTo: cell.heightAnchor, multiplier: 1).isActive = true
        
        // =============== ASSIGNING VALUES TO CELL ITEMS ====================
        cell.cellDelegate = self
        cell.indexpath = indexPath
        cell.imagePreview.image = imageArray
        
        if(self.videoModeCheck == 1){
            if(collectionImage.count == 5){
                self.countDownlabel.text = "Tap to merge Clips"
//                self.galleryButton.isEnabled = false
            }
        }else if(self.videoModeCheck == 2){
            if(collectionImage.count == 10){
                self.countDownlabel.text = "Tap to merge Clips"
//                self.galleryButton.isEnabled = false
            }
        }else if(self.videoModeCheck == 3){
            if(collectionImage.count == 20){
                self.countDownlabel.text = "Tap to merge Clips"
//                self.galleryButton.isEnabled = false
            }
        }
        
        return cell
        
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, at atIndexPath: IndexPath, didMoveTo toIndexPath: IndexPath) {
        
        var photo: UIImage
        var url: URL
        
        photo = self.collectionImage.remove(at: (atIndexPath as NSIndexPath).item)
        self.collectionImage.insert(photo, at: (toIndexPath as NSIndexPath).item)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, collectionView layout: RAReorderableLayout, didBeginDraggingItemAt indexPath: IndexPath) {

        removingURL = "\(self.URLcollection.remove(at: indexPath.item))"
    }
    
    func collectionView(_ collectionView: UICollectionView, collectionView layout: RAReorderableLayout, didEndDraggingItemTo indexPath: IndexPath) {
        
        self.URLcollection.insert(URL(string: removingURL)!, at: indexPath.item)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width/5, height: UIScreen.main.bounds.width/5)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
}

// MARK:- Extensions

// ==========================================================================================
// ====================================== EXTENSION =========================================
// ==========================================================================================

extension FifteenSecsViewController: QBImagePickerControllerDelegate{
    
    func qb_imagePickerController(_ imagePickerController: QBImagePickerController!, didFinishPickingAssets assets: [Any]!) {
        
        let phasset = assets as! [PHAsset]
        for asset in phasset{
            
            if(asset.duration < 3.0){
                ToastView.shared.long(self.view, txt_msg: "Can't Import Video less than 3 seconds")
            }
            
        }
        self.dismiss(animated: true, completion: nil)
    }
    func qb_imagePickerControllerDidCancel(_ imagePickerController: QBImagePickerController!) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func gettingURLandCropVideos(asset: PHAsset) {
        
        asset.getURL(completionHandler: { (url) in
            print("this is url: \(url?.pathExtension)")
            
            if(asset.duration < 3.0){
                //                self.displayMyAlertMessage(userMessage: "Can't Import Video less than 3 seconds")
                // self.dismiss(animated: true, completion: nil)
            }else{
                
                self.cropVideo(sourceURL: url!, startTime: 0.0, endTime: 3.05) { (url) in
                    
                    self.URLcollection.append(url)
                    
                    let urlString = url.absoluteString
                    let thumbnail = self.createThumbnailOfVideoFromFileURL(urlString)
                    
                    self.collectionImage.append(thumbnail!)
                    
                    DispatchQueue.main.async {
                        print("collectionURL: \(self.URLcollection)")
                        self.collectionViewPreviewContainer.reloadData()
                    }
                    
                }
                
            }
            
        })
        
    }
    
    func qb_imagePickerController(_ imagePickerController: QBImagePickerController!, didSelect asset: PHAsset!) {
        
        self.gettingURLandCropVideos(asset: asset)
        
    }
    func qb_imagePickerController(_ imagePickerController: QBImagePickerController!, didDeselect asset: PHAsset!) {
        print("de select: \(asset)")
        
        asset.getURL { (deselectURL) in
            
            print(deselectURL)
            let url = deselectURL?.absoluteString.suffix(8)
            
            for (index, urls) in self.URLcollection.enumerated(){
                if(urls.absoluteString.suffix(8) == url){
                    print("this is index: \(index)")
                    self.URLcollection.remove(at: index)
                    self.collectionImage.remove(at: index)
                }
            }
        }
    }
    
    
}

extension FifteenSecsViewController: tapImageProtocol{
    
    func tapImage(index: Int) {
        print("tapped index: \(index)")
        self.selectedVideoIndex = index
        
//        VSVideoSpeeder.shared.scaleAsset(fromURL: URLcollection[index], by: 1, withMode: SpeedoMode.Slower) { (exporter) in
//            print(exporter?.outputURL)
//            self.performSegue(withIdentifier: "showVideo", sender: exporter?.outputURL!)
//        }
        performSegue(withIdentifier: "showVideo", sender: URLcollection[index])
    }
    
    // UNWIND SEGUE
    
    @IBAction func unwindToFifteenSecondVC(segue: UIStoryboardSegue) {
    }
    
}

extension FifteenSecsViewController: CountdownLabelDelegate {
    
    func countdownFinished() {
        
        debugPrint("countdownFinished at delegate.")
        //        self.cameraButton.isUserInteractionEnabled = true
        //        self.cameraButton.backgroundColor = .red
        self.countDownlabel.text = "Captured"
    }
    
    func countingAt(timeCounted: TimeInterval, timeRemaining: TimeInterval) {
        debugPrint("time counted at delegate=\(timeCounted)")
        debugPrint("time remaining at delegate=\(timeRemaining)")
    }
    
    
}

extension FifteenSecsViewController: sendingDataBacktoViewController {
    
    func gettingCropedVideoURL(videourl: URL) {
        
        
        let urlString = videourl.absoluteString
        let thumbnail = self.createThumbnailOfVideoFromFileURL(urlString)
        
        self.collectionImage.remove(at: self.selectedVideoIndex)
        self.URLcollection.remove(at: self.selectedVideoIndex)
        
        self.collectionImage.insert(thumbnail!, at: self.selectedVideoIndex)
        self.URLcollection.insert(videourl, at: self.selectedVideoIndex)
        
        self.importedVideoIndex.append(self.selectedVideoIndex)
        
        DispatchQueue.main.async {
            self.collectionViewPreviewContainer.reloadData()
        }
        
        
    }
}


// ==========================================================================================
// ================================ CUSTOM CELL FUNCTION ====================================
// ==========================================================================================

protocol tapImageProtocol{
    func tapImage(index: Int)
}

class baseCell: UICollectionViewCell {
    
    var cellDelegate: tapImageProtocol?
    var indexpath: IndexPath?
    let imagePreview = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        self.backgroundColor = .red
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imagePreviewTapped))
        imagePreview.addGestureRecognizer(tapGesture)
        imagePreview.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func imagePreviewTapped(){
        cellDelegate?.tapImage(index: (indexpath?.row)!)
    }
    
}


//// ===========================================================

extension PHAsset {
    
    func getURL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)){
        if self.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) -> Void in
                completionHandler(contentEditingInput!.fullSizeImageURL as URL?)
            })
        } else if self.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl: URL = urlAsset.url as URL
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            })
        }
    }
}

extension AVAsset {
    
    func videoOrientation() -> (orientation: UIInterfaceOrientation, device: AVCaptureDevice.Position) {
        var orientation: UIInterfaceOrientation = .unknown
        var device: AVCaptureDevice.Position = .unspecified
        
        let tracks :[AVAssetTrack] = self.tracks(withMediaType: AVMediaType.video)
        if let videoTrack = tracks.first {
            
            let t = videoTrack.preferredTransform
            
            if (t.a == 0 && t.b == 1.0 && t.d == 0) {
                orientation = .portrait
                
                if t.c == 1.0 {
                    device = .front
                } else if t.c == -1.0 {
                    device = .back
                }
            }
            else if (t.a == 0 && t.b == -1.0 && t.d == 0) {
                orientation = .portraitUpsideDown
                
                if t.c == -1.0 {
                    device = .front
                } else if t.c == 1.0 {
                    device = .back
                }
            }
            else if (t.a == 1.0 && t.b == 0 && t.c == 0) {
                orientation = .landscapeRight
                
                if t.d == -1.0 {
                    device = .front
                } else if t.d == 1.0 {
                    device = .back
                }
            }
            else if (t.a == -1.0 && t.b == 0 && t.c == 0) {
                orientation = .landscapeLeft
                
                if t.d == 1.0 {
                    device = .front
                } else if t.d == -1.0 {
                    device = .back
                }
            }
        }
        
        return (orientation, device)
    }
}


//// =====================================================

extension AVAsset {
    
    func writeAudioTrackToURL(_ url: URL, completion: @escaping (Bool, Error?) -> ()) {
        do {
            let audioAsset = try self.audioAsset()
            audioAsset.writeToURL(url, completion: completion)
        } catch (let error as NSError){
            completion(false, error)
        }
    }
    
    func writeToURL(_ url: URL, completion: @escaping (Bool, Error?) -> ()) {
        
        guard let exportSession = AVAssetExportSession(asset: self, presetName: AVAssetExportPresetAppleM4A) else {
            completion(false, nil)
            return
        }
        
        exportSession.outputFileType = .m4a
        exportSession.outputURL      = url
        
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
//                print("this is URL:: \(exportSession.outputURL!)")
                UserDefaults.standard.set(exportSession.outputURL!, forKey: "audioURL")
                UserDefaults.standard.synchronize()
                completion(true, nil)
            case .unknown, .waiting, .exporting, .failed, .cancelled:
                completion(false, nil)
            }
        }
    }
    
    func audioAsset() throws -> AVAsset {
        
        let composition = AVMutableComposition()
        let audioTracks = tracks(withMediaType: .audio)
        
        for track in audioTracks {
            
            let compositionTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: kCMPersistentTrackID_Invalid)
            try compositionTrack?.insertTimeRange(track.timeRange, of: track, at: track.timeRange.start)
            compositionTrack?.preferredTransform = track.preferredTransform
        }
        return composition
    }
}
