//
//  ViewController.swift
//  kwikut
//
//  Created by Apple on 18/12/2018.
//  Copyright © 2018 devstop. All rights reserved.
//

//import UIKit

import UIKit
import MobileCoreServices
import AVFoundation
import QBImagePickerController

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
//========================================================================
//============================== ELEMENTS ================================
//========================================================================
    

    let topContainerImageView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let middleContainerImageView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let bottomContainerImageView: UIView = {
        let view = UIView()
        view.backgroundColor = .blue
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let topImageview: UIImageView = {
        let imageview = UIImageView()
        imageview.image = UIImage(named: "top4")
        imageview.clipsToBounds = true
        imageview.contentMode = .scaleAspectFill
        imageview.translatesAutoresizingMaskIntoConstraints = false
        return imageview
    }()
    
    let bottomImageview: UIImageView = {
        let imageview = UIImageView()
        imageview.image = UIImage(named: "bottom")
        imageview.clipsToBounds = true
        imageview.contentMode = .scaleAspectFill
        imageview.translatesAutoresizingMaskIntoConstraints = false
        return imageview
    }()
    
    let leftImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.image = UIImage(named: "film_edit") //film_edit"
        imageview.backgroundColor = .black
        imageview.clipsToBounds = true
        imageview.contentMode = .scaleAspectFit
        imageview.translatesAutoresizingMaskIntoConstraints = false
        return imageview
    }()
    
    let upperView = customViews()
    let upperLeftView = customViews()
    let upperMiddleView = customViews()
    let uppperRightView = customViews()
    
    let bottomView = customViews()
    let bottomLeftView = customViews()
    let bottomMiddleView = customViews()
    let bottomRightView = customViews()
    
    let grayColor = UIColor(red: 241/255, green: 241/255, blue: 243/255, alpha: 1)
    let qbpicker = QBImagePickerController()
    
    var videoMode = Int()
    var URLcollection = [URL]()
    var collectionImage = [UIImage]()

//========================================================================
//=========================== VIEW WILL APPEAR ===========================
//========================================================================
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // HIDING NAVBAR
        self.navigationController?.navigationBar.isHidden = true
        UIApplication.shared.keyWindow?.windowLevel = UIWindow.Level.normal
    }
    
//========================================================================
//=========================== VIEW DID LOAD ==============================
//========================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        qbpicker.delegate = self
        
        
        
        self.bottomLeftView.isUserInteractionEnabled = true
        let firstpicTap = UITapGestureRecognizer(target: self, action: #selector(fifteenSecondTapped))
        bottomLeftView.addGestureRecognizer(firstpicTap)

        bottomMiddleView.isUserInteractionEnabled = true
        let secondpicTap = UITapGestureRecognizer(target: self, action: #selector(thirtySecondTapped))
        bottomMiddleView.addGestureRecognizer(secondpicTap)

        bottomRightView.isUserInteractionEnabled = true
        let thirdpicTap = UITapGestureRecognizer(target: self, action: #selector(sixtySecondTapped))
        bottomRightView.addGestureRecognizer(thirdpicTap)
     
        // upper views
        
        self.upperLeftView.isUserInteractionEnabled = true
        let firstpicGallery = UITapGestureRecognizer(target: self, action: #selector(fifteenSecondGalleryTapped))
        upperLeftView.addGestureRecognizer(firstpicGallery)
        
        self.upperMiddleView.isUserInteractionEnabled = true
        let secondpicGallery = UITapGestureRecognizer(target: self, action: #selector(thirtySecondGalleryTapped))
        upperMiddleView.addGestureRecognizer(secondpicGallery)
        
        
        self.uppperRightView.isUserInteractionEnabled = true
        let thirdpicGallery = UITapGestureRecognizer(target: self, action: #selector(sixtySecondGalleryTapped))
        uppperRightView.addGestureRecognizer(thirdpicGallery)
        
        
        self.setupView()
    }
    
//===========================================================================
//=========================== CUSTOM FUNCTIONS ==============================
//===========================================================================
    
    func setupView() {
        
        // ================= ADDING VIEWS ======================
        
//        view.addSubview(backgroundImageview)

        view.addSubview(topContainerImageView)
        view.addSubview(middleContainerImageView)
        view.addSubview(bottomContainerImageView)
        

        topContainerImageView.addSubview(topImageview)
        bottomContainerImageView.addSubview(bottomImageview)
        
        middleContainerImageView.addSubview(leftImageView)
        
        middleContainerImageView.addSubview(upperView)
        upperView.addSubview(upperLeftView)
        upperView.addSubview(upperMiddleView)
        upperView.addSubview(uppperRightView)
        
        middleContainerImageView.addSubview(bottomView)
        bottomView.addSubview(bottomLeftView)
        bottomView.addSubview(bottomMiddleView)
        bottomView.addSubview(bottomRightView)
        
        // =================== CONSTRAINTS ====================
        
        let topViewAnchors: [NSLayoutConstraint] = [
            topContainerImageView.topAnchor.constraint(equalTo: view.topAnchor),
            topContainerImageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            topContainerImageView.rightAnchor.constraint(equalTo: view.rightAnchor),
            topContainerImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.55)
        ]
        let middleViewAnchors: [NSLayoutConstraint] = [
            middleContainerImageView.topAnchor.constraint(equalTo: topContainerImageView.bottomAnchor),
            middleContainerImageView.leftAnchor.constraint(equalTo: view.leftAnchor),
            middleContainerImageView.rightAnchor.constraint(equalTo: view.rightAnchor),
            middleContainerImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.2)
        ]
        let bottomViewAnchors: [NSLayoutConstraint] = [
            bottomContainerImageView.topAnchor.constraint(equalTo: middleContainerImageView.bottomAnchor),
            bottomContainerImageView.leftAnchor.constraint(equalTo: middleContainerImageView.leftAnchor),
            bottomContainerImageView.rightAnchor.constraint(equalTo: middleContainerImageView.rightAnchor),
            bottomContainerImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.25)
        ]

        // ========================== ADDING IMAGEVIEW CONSTRAINTS INTO MIDDLE VIEW ====================
        let topImageViewConstraints: [NSLayoutConstraint] = [
            topImageview.topAnchor.constraint(equalTo: topContainerImageView.topAnchor),
            topImageview.leftAnchor.constraint(equalTo: topContainerImageView.leftAnchor),
            topImageview.bottomAnchor.constraint(equalTo: topContainerImageView.bottomAnchor),
            topImageview.rightAnchor.constraint(equalTo: topContainerImageView.rightAnchor)
        ]
        let bottomImageViewConstraints: [NSLayoutConstraint] = [
            bottomImageview.topAnchor.constraint(equalTo: bottomContainerImageView.topAnchor),
            bottomImageview.leftAnchor.constraint(equalTo: bottomContainerImageView.leftAnchor),
            bottomImageview.bottomAnchor.constraint(equalTo: bottomContainerImageView.bottomAnchor),
            bottomImageview.rightAnchor.constraint(equalTo: bottomContainerImageView.rightAnchor)
        ]
       
        leftImageView.leftAnchor.constraint(equalTo: middleContainerImageView.leftAnchor).isActive = true
        leftImageView.topAnchor.constraint(equalTo: middleContainerImageView.topAnchor).isActive = true
        leftImageView.bottomAnchor.constraint(equalTo: middleContainerImageView.bottomAnchor).isActive = true
        leftImageView.widthAnchor.constraint(equalTo: middleContainerImageView.widthAnchor, multiplier: 0.12).isActive = true
        

        upperView.leftAnchor.constraint(equalTo: leftImageView.rightAnchor).isActive = true
        upperView.topAnchor.constraint(equalTo: middleContainerImageView.topAnchor).isActive = true
        upperView.heightAnchor.constraint(equalTo: middleContainerImageView.heightAnchor, multiplier: 0.5).isActive = true
        upperView.rightAnchor.constraint(equalTo: middleContainerImageView.rightAnchor).isActive = true
        

        bottomView.leftAnchor.constraint(equalTo: upperView.leftAnchor).isActive = true
        bottomView.topAnchor.constraint(equalTo: upperView.bottomAnchor).isActive = true
        bottomView.bottomAnchor.constraint(equalTo: middleContainerImageView.bottomAnchor).isActive = true
        bottomView.rightAnchor.constraint(equalTo: upperView.rightAnchor).isActive = true
        
        upperLeftView.backgroundColor = .white
        upperLeftView.leftAnchor.constraint(equalTo: upperView.leftAnchor).isActive = true
        upperLeftView.topAnchor.constraint(equalTo: upperView.topAnchor).isActive = true
        upperLeftView.bottomAnchor.constraint(equalTo: upperView.bottomAnchor).isActive = true
        upperLeftView.widthAnchor.constraint(equalTo: upperView.widthAnchor, multiplier: 0.33333333333).isActive = true
        
        
        let formattedString1 = NSMutableAttributedString()
        let formattedString2 = NSMutableAttributedString()
        formattedString1.bold("30")
        formattedString1.normal(" SECS")
        formattedString2.bold("60")
        formattedString2.normal(" SECS")
        
        upperMiddleView.backgroundColor = grayColor
        upperMiddleView.textLabel.attributedText = formattedString1
        upperMiddleView.detailTextLabel.text = "(10 clips)"
        upperMiddleView.leftAnchor.constraint(equalTo: upperLeftView.rightAnchor).isActive = true
        upperMiddleView.topAnchor.constraint(equalTo: upperView.topAnchor).isActive = true
        upperMiddleView.bottomAnchor.constraint(equalTo: upperView.bottomAnchor).isActive = true
        upperMiddleView.widthAnchor.constraint(equalTo: upperView.widthAnchor, multiplier: 0.33333333333).isActive = true

        uppperRightView.backgroundColor = .white
        uppperRightView.textLabel.attributedText = formattedString2
        uppperRightView.detailTextLabel.text = "(20 clips)"
        uppperRightView.leftAnchor.constraint(equalTo: upperMiddleView.rightAnchor).isActive = true
        uppperRightView.topAnchor.constraint(equalTo: upperView.topAnchor).isActive = true
        uppperRightView.bottomAnchor.constraint(equalTo: upperView.bottomAnchor).isActive = true
        uppperRightView.widthAnchor.constraint(equalTo: upperView.widthAnchor, multiplier: 0.33333333333).isActive = true
        
        
        
        bottomLeftView.backgroundColor = grayColor
        bottomLeftView.leftAnchor.constraint(equalTo: bottomView.leftAnchor).isActive = true
        bottomLeftView.topAnchor.constraint(equalTo: bottomView.topAnchor).isActive = true
        bottomLeftView.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor).isActive = true
        bottomLeftView.widthAnchor.constraint(equalTo: bottomView.widthAnchor, multiplier: 0.33333333333).isActive = true
        
        bottomMiddleView.backgroundColor = .white
        bottomMiddleView.textLabel.attributedText = formattedString1
        bottomMiddleView.detailTextLabel.text = "(10 clips)"
        bottomMiddleView.leftAnchor.constraint(equalTo: bottomLeftView.rightAnchor).isActive = true
        bottomMiddleView.topAnchor.constraint(equalTo: bottomView.topAnchor).isActive = true
        bottomMiddleView.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor).isActive = true
        bottomMiddleView.widthAnchor.constraint(equalTo: bottomView.widthAnchor, multiplier: 0.33333333333).isActive = true
        
        bottomRightView.backgroundColor = grayColor
        bottomRightView.textLabel.attributedText = formattedString2
        bottomRightView.detailTextLabel.text = "(20 clips)"
        bottomRightView.leftAnchor.constraint(equalTo: bottomMiddleView.rightAnchor).isActive = true
        bottomRightView.topAnchor.constraint(equalTo: bottomView.topAnchor).isActive = true
        bottomRightView.bottomAnchor.constraint(equalTo: bottomView.bottomAnchor).isActive = true
        bottomRightView.widthAnchor.constraint(equalTo: bottomView.widthAnchor, multiplier: 0.33333333333).isActive = true
        

        
        // =================== ACTIVATING CONSTRAINTS ====================
//        NSLayoutConstraint.activate(backgroundImageAnchors)
        NSLayoutConstraint.activate(topViewAnchors)
        NSLayoutConstraint.activate(middleViewAnchors)
        NSLayoutConstraint.activate(bottomViewAnchors)
        NSLayoutConstraint.activate(topImageViewConstraints)
        NSLayoutConstraint.activate(bottomImageViewConstraints)
        
    }
    
//================================================================================
//=========================== OBJECTIVE-C FUNCTIONS ==============================
//================================================================================
    
    @objc func fifteenSecondTapped(){
        
        print("15 seconds")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondViewController = storyboard.instantiateViewController(withIdentifier: "vc") as! FifteenSecsViewController
        secondViewController.videoModeCheck = 1
        secondViewController.filmTapped = true
        self.present(secondViewController, animated: true, completion: nil)
        
    }
    @objc func thirtySecondTapped(){
        
        print("30 seconds")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondViewController = storyboard.instantiateViewController(withIdentifier: "vc") as! FifteenSecsViewController
        secondViewController.videoModeCheck = 2
        secondViewController.filmTapped = true
        self.present(secondViewController, animated: true, completion: nil)

    }
    @objc func sixtySecondTapped(){
        
        print("60 seconds")
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondViewController = storyboard.instantiateViewController(withIdentifier: "vc") as! FifteenSecsViewController
        secondViewController.videoModeCheck = 3
        secondViewController.filmTapped = true
        self.present(secondViewController, animated: true, completion: nil)
    }
    
    @objc func fifteenSecondGalleryTapped(){
        print("15 seconds Galler")
        videoMode = 1
        openGallery(videoModeCheck: videoMode)
        
    }
    
    @objc func thirtySecondGalleryTapped(){
        print("30 seconds Galler")
        videoMode = 2
        openGallery(videoModeCheck: videoMode)
    }
    
    @objc func sixtySecondGalleryTapped(){
        print("60 seconds Galler")
        videoMode = 3
        openGallery(videoModeCheck: videoMode)
    }
    
    
    // MARK:- OPEN GALLERY
    
    @objc func openGallery(videoModeCheck: Int) {
        
        print("gallery open")
        
        if(videoModeCheck == 1){
            qbpicker.maximumNumberOfSelection = 5
            qbpicker.minimumNumberOfSelection = 5
        }else if(videoModeCheck == 2){
            qbpicker.maximumNumberOfSelection = 10
            qbpicker.minimumNumberOfSelection = 10
        }else if(videoModeCheck == 3){
            qbpicker.maximumNumberOfSelection = 20
            qbpicker.minimumNumberOfSelection = 20
        }else{
            print("nothing selected")
        }
        
        qbpicker.mediaType = .video
        qbpicker.allowsMultipleSelection = true
        qbpicker.showsNumberOfSelectedAssets = true
        self.present(qbpicker, animated: true, completion: nil)
        
    }
    
    // MARK:- CROP VIDEO FUNCTION
    
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
    
    // MARK:- CREATE THUMBNAILS FROM URL
    
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
    
    
}

extension ViewController: QBImagePickerControllerDelegate{
    
    func qb_imagePickerController(_ imagePickerController: QBImagePickerController!, didFinishPickingAssets assets: [Any]!) {
        
        let phasset = assets as! [PHAsset]
        for asset in phasset{
            
            if(asset.duration < 3.0){
                ToastView.shared.long(self.view, txt_msg: "Can't Import Video less than 3 seconds")
            }
            
        }
        
        print("am here now")
        self.dismiss(animated: true, completion: nil)
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let secondViewController = storyboard.instantiateViewController(withIdentifier: "vc") as! FifteenSecsViewController
        secondViewController.videoModeCheck = videoMode
        secondViewController.filmTapped = true
        
        secondViewController.URLcollection = self.URLcollection
        secondViewController.collectionImage = self.collectionImage
        
        self.present(secondViewController, animated: true, completion: nil)
        
        
        
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
                    
                    
                    
                    self.URLcollection.append(url) // COMMENTING INTENTIONALLY
                    
                    let urlString = url.absoluteString
                    print("cropvideo url: \(urlString)")
                    let thumbnail = self.createThumbnailOfVideoFromFileURL(urlString)  // COMMENTING INTENTIONALLY
                    
                    self.collectionImage.append(thumbnail!) // COMMENTING INTENTIONALLY
                    
                    
                    // COMMENTING INTENTIONALLY
//                    DispatchQueue.main.async {
//                        print("collectionURL: \(self.URLcollection)")
//                        self.collectionViewPreviewContainer.reloadData()
//                    }
                    
                    
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
            
            print("Did Deselect url: \(deselectURL)")
            let url = deselectURL?.absoluteString.suffix(8)
            
            // COMMENTING INTENTIONALLY
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


extension UIViewController {
    class func displaySpinner(onView : UIView) -> UIView {
        let spinnerView = UIView.init(frame: onView.bounds)
        spinnerView.backgroundColor = UIColor.init(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            onView.addSubview(spinnerView)
        }
        
        return spinnerView
    }
    
    class func removeSpinner(spinner :UIView) {
        DispatchQueue.main.async {
            spinner.removeFromSuperview()
        }
    }
}
