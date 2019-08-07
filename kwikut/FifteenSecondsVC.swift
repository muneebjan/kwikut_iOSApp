//
//  FifteenSecondsVC.swift
//  kwikut
//
//  Created by Apple on 18/12/2018.
//  Copyright © 2018 devstop. All rights reserved.
//

import UIKit
import AVFoundation

class FifteenSecondsVC: UIViewController, AVCapturePhotoCaptureDelegate {

    // VARIABLES
    var captureSession: AVCaptureSession!
    var stillImageOutput: AVCapturePhotoOutput!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    // ELEMENTS
    
    let previewView: UIView = {
        let view = UIView()
        view.backgroundColor = .gray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    let topContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let bottomContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .orange
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    let CapturePhotobutton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .orange
        button.setTitle("Take Photo", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
        
    }()
    let capturedImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.image = #imageLiteral(resourceName: "logo")
        imageview.contentMode = .scaleToFill
        imageview.translatesAutoresizingMaskIntoConstraints = false
        return imageview
    }()
    
//========================================================================
//========================== VIEW DID DISAPPEAR ==========================
//========================================================================
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.captureSession.stopRunning()
    }
    
//========================================================================
//=========================== VIEW DID APPEAR ===========================
//========================================================================
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Setup your camera here...
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .medium
        
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video)
            else {
                print("Unable to access back camera!")
                return
        }
        
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            stillImageOutput = AVCapturePhotoOutput()
            if captureSession.canAddInput(input) && captureSession.canAddOutput(stillImageOutput) {
                captureSession.addInput(input)
                captureSession.addOutput(stillImageOutput)
                setupLivePreview()
            }
            //Step 9
        }
        catch let error  {
            print("Error Unable to initialize back camera:  \(error.localizedDescription)")
        }
        
        
    }
    
    
//========================================================================
//=========================== VIEW WILL APPEAR ===========================
//========================================================================
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // HIDING NAVBAR
        self.navigationController?.navigationBar.isHidden = false
    }
    
//========================================================================
//=========================== VIEW DID LOAD ==============================
//========================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        CapturePhotobutton.addTarget(self, action: #selector(self.takePhotoPressed), for: .touchUpInside)
        setupView()
        
    }
    
//===========================================================================
//=========================== CUSTOM FUNCTIONS ==============================
//===========================================================================
    
    func setupView() {
        
        
        // ================= ADDING VIEWS ======================
        
        view.addSubview(previewView)
        view.addSubview(topContainerView)
        view.addSubview(bottomContainerView)
        topContainerView.addSubview(capturedImageView)
        bottomContainerView.addSubview(CapturePhotobutton)
        
        // =================== CONSTRAINTS ====================
        let previewViewConstraints: [NSLayoutConstraint] = [
            previewView.bottomAnchor.constraint(equalTo: topContainerView.topAnchor),
            previewView.leftAnchor.constraint(equalTo: view.leftAnchor),
            previewView.rightAnchor.constraint(equalTo: view.rightAnchor),
            previewView.topAnchor.constraint(equalTo: view.topAnchor)
        ]
        let topViewAnchors: [NSLayoutConstraint] = [
            topContainerView.bottomAnchor.constraint(equalTo: bottomContainerView.topAnchor),
            topContainerView.leftAnchor.constraint(equalTo: bottomContainerView.leftAnchor),
            topContainerView.rightAnchor.constraint(equalTo: bottomContainerView.rightAnchor),
            topContainerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.08)
        ]
        let bottomViewAnchors: [NSLayoutConstraint] = [
            bottomContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            bottomContainerView.leftAnchor.constraint(equalTo: view.leftAnchor),
            bottomContainerView.rightAnchor.constraint(equalTo: view.rightAnchor),
            bottomContainerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1)
        ]
        
        let captureButtonConstraints: [NSLayoutConstraint] = [
            CapturePhotobutton.centerXAnchor.constraint(equalTo: bottomContainerView.centerXAnchor),
            CapturePhotobutton.centerYAnchor.constraint(equalTo: bottomContainerView.centerYAnchor)

        ]
        let capturedImageViewConstraints: [NSLayoutConstraint] = [
            capturedImageView.bottomAnchor.constraint(equalTo: topContainerView.bottomAnchor),
            capturedImageView.topAnchor.constraint(equalTo: topContainerView.topAnchor),
            capturedImageView.leftAnchor.constraint(equalTo: topContainerView.leftAnchor),
            capturedImageView.widthAnchor.constraint(equalTo: topContainerView.heightAnchor, multiplier: 1)
        ]
        
        // =================== ACTIVATING CONSTRAINTS ====================
        
        NSLayoutConstraint.activate(previewViewConstraints)
        NSLayoutConstraint.activate(topViewAnchors)
        NSLayoutConstraint.activate(bottomViewAnchors)
        NSLayoutConstraint.activate(captureButtonConstraints)
        NSLayoutConstraint.activate(capturedImageViewConstraints)
        
    }
    
    
//================================================================================
//=========================== OBJECTIVE-C FUNCTIONS ==============================
//================================================================================
    
    @objc func takePhotoPressed(){
        print("Take photo Pressed")
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        stillImageOutput.capturePhoto(with: settings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        
        guard let imageData = photo.fileDataRepresentation()
            else { return }
        
        let image = UIImage(data: imageData)
        capturedImageView.image = image
    }
    
    func setupLivePreview() {
        
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        videoPreviewLayer.videoGravity = .resizeAspect
        videoPreviewLayer.connection?.videoOrientation = .portrait
        previewView.layer.addSublayer(videoPreviewLayer)
        
        DispatchQueue.global(qos: .userInitiated).async { //[weak self] in
            self.captureSession.startRunning()
            //Step 13
            DispatchQueue.main.async {
                self.videoPreviewLayer.frame = self.previewView.bounds
            }
        }
    }
}
