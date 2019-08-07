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
        // CALLING CUSTOM FUNCTIONS
        
        self.bottomLeftView.isUserInteractionEnabled = true
        let firstpicTap = UITapGestureRecognizer(target: self, action: #selector(fifteenSecondTapped))
        bottomLeftView.addGestureRecognizer(firstpicTap)

        bottomMiddleView.isUserInteractionEnabled = true
        let secondpicTap = UITapGestureRecognizer(target: self, action: #selector(thirtySecondTapped))
        bottomMiddleView.addGestureRecognizer(secondpicTap)

        bottomRightView.isUserInteractionEnabled = true
        let thirdpicTap = UITapGestureRecognizer(target: self, action: #selector(sixtySecondTapped))
        bottomRightView.addGestureRecognizer(thirdpicTap)
     
        
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
