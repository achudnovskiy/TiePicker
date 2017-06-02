//
//  ViewController.swift
//  TiePicker
//
//  Created by Andrey Chudnovskiy on 2016-09-24.
//  Copyright © 2016 Simple Matters. All rights reserved.
//

import UIKit
import CoreImage
import AVFoundation


class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, AVCapturePhotoCaptureDelegate{

    let cameraIconTag = 100
    
    enum ActivityState {
        case PickShirt;
        case PickJacket;
        case ShowResult;
    }
    
    var currentState:ActivityState = .PickShirt;
    
    var chosenShirtColor:UIColor?
    var chosenJacketColor:UIColor?
    var chosenTieColor:UIColor?

    var tasteMachine:TasteMachine?
    
    var imagePicker:UIImagePickerController?
    
    var cameraCaptureSession:AVCaptureSession?
    var cameraImageOutput:AVCapturePhotoOutput?
    var cameraLayer:AVCaptureVideoPreviewLayer?
    var dynamicsAnimator:UIDynamicAnimator!
    var propertyAnimator:UIViewPropertyAnimator!

    var cameraIconSnap:UISnapBehavior?
    var cameraIcomBehaviour:UIDynamicItemBehavior?
    var photoModeOn = false
    
    @IBOutlet weak var vwMain: UIView!
    
    @IBOutlet weak var vwMask: UIView!
    @IBOutlet weak var vwCameraBackground: UIView!
    @IBOutlet weak var vwCameraIcon: UIImageView!
    
    @IBOutlet weak var vwEffects: UIVisualEffectView!
    
    @IBOutlet weak var cnstrMaskWidth: NSLayoutConstraint!
    @IBOutlet weak var cnstrMaskHeight: NSLayoutConstraint!
    
    @IBOutlet weak var vwJacketColor: UIView!
    @IBOutlet weak var lblJacket: UILabel!
    @IBOutlet weak var vwShirtColor: UIView!
    @IBOutlet weak var lblShirt: UILabel!
//    @IBOutlet weak var vwTieColor: UIView!
//    @IBOutlet weak var vwResultTie: UIView!
    @IBOutlet weak var lblHeader: UILabel!
//    @IBOutlet weak var vwColours: UIView!

    @IBOutlet weak var vwCameraCircle: UIView!
    
    
    @IBOutlet var tapMaskView: UITapGestureRecognizer!
    
    var originalMaskBounds:CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        dynamicsAnimator = UIDynamicAnimator(referenceView: self.vwMain)
        originalMaskBounds = vwMask.bounds
        
        vwCameraBackground.mask = vwMask
        vwMask.layer.cornerRadius = vwMask.bounds.width/2
        

        vwJacketColor.layer.borderColor = UIColor.darkGray.cgColor
        vwJacketColor.layer.borderWidth = 5
        vwJacketColor.layer.cornerRadius = vwJacketColor.bounds.width / 2
        vwJacketColor.layer.masksToBounds = true

        vwShirtColor.layer.borderColor = UIColor.darkGray.cgColor
        vwShirtColor.layer.borderWidth = 5
        vwShirtColor.layer.cornerRadius = vwShirtColor.bounds.width / 2
        vwShirtColor.layer.masksToBounds = true

        vwCameraCircle.layer.cornerRadius = vwCameraCircle.bounds.width / 2
        vwCameraCircle.layer.borderWidth = 2
        vwCameraCircle.layer.borderColor = UIColor.white.cgColor
        
        startVideoBackground()
    }
    
    override func viewWillAppear(_ animated: Bool) {
   
        super.viewWillAppear(animated)
    }
    
    func startVideoBackground() {
        cameraCaptureSession = AVCaptureSession()
        cameraCaptureSession?.sessionPreset = AVCaptureSessionPresetPhoto
        cameraImageOutput = AVCapturePhotoOutput()
       
        let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        
        if let input = try? AVCaptureDeviceInput(device: device) {
            if (cameraCaptureSession?.canAddInput(input)) != nil {
                
                cameraCaptureSession?.addInput(input)
                if (cameraCaptureSession?.canAddOutput(cameraImageOutput)) != nil {
                    cameraCaptureSession?.addOutput(cameraImageOutput)
                    cameraLayer = AVCaptureVideoPreviewLayer(session: cameraCaptureSession)
                    cameraLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
                    
                    cameraLayer?.frame = vwCameraBackground.bounds
                    vwCameraBackground.layer.addSublayer(cameraLayer!)
                    
                    cameraCaptureSession?.startRunning()
                    vwCameraBackground.bringSubview(toFront: vwEffects)
                    
                }
            } else {
                print("issue here : captureSesssion.canAddInput")
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    
    //MARK: Tap gesture handlers
    
    @IBAction func chooseJacketColor(_ sender: AnyObject) {
        currentState = .PickJacket
    }
    
    @IBAction func chooseShirtColor(_ sender: AnyObject) {
        currentState = .PickShirt
    }
    
    func headerTextForState(_ state:ActivityState) -> String {
        switch state {
        case .PickJacket:
            return "Snap your Jacket"
        case .PickShirt:
            return "Snap your Shirt"
        case .ShowResult:
            return "Our pick"
        }
    }

    @IBAction func chooseColorAction(_ sender: Any) {
        self.transition(toFullScreen: !self.photoModeOn)
    }
    
    func transition(toFullScreen:Bool) {
        DispatchQueue.main.async {
            self.vwCameraCircle.isHidden = !toFullScreen
            
            if toFullScreen {
                self.propertyAnimator = UIViewPropertyAnimator(duration: 0.25, curve: .linear) {
                    self.vwEffects.effect = nil
                }
            }
            else {
                self.propertyAnimator =  UIViewPropertyAnimator(duration: 0.25, curve: .linear) {
                    self.vwEffects.effect = UIBlurEffect(style: .light)
                }
            }
            self.propertyAnimator.startAnimation()
            
            UIView.animate(withDuration: 0.2, delay: 0, options: [.curveEaseIn], animations: {
                self.vwMask.bounds = toFullScreen ? self.vwCameraBackground.bounds : self.originalMaskBounds
                self.vwCameraIcon.tintColor = toFullScreen ? UIColor.white : UIColor.black
                if toFullScreen {
                    self.vwMask.bounds = self.vwCameraBackground.bounds
                    self.vwCameraIcon.tintColor = UIColor.white
                    self.vwCameraIcon.center = self.vwCameraCircle.center
                }
                else {
                    self.vwMask.bounds = self.originalMaskBounds
                    self.vwCameraIcon.tintColor = UIColor.black
                    self.vwCameraIcon.center = self.vwCameraBackground.center
                }
            }) { (finished) in
                self.photoModeOn = toFullScreen
                self.animateRoundCornersChange(makeRound: !toFullScreen)
                self.tapMaskView.isEnabled = !toFullScreen
            }
        
        }

    }
    
//    func snapCameraIconToPoint(point:CGPoint) {
//        if self.cameraIconSnap != nil {
//            self.dynamicsAnimator.removeBehavior(self.cameraIconSnap!)
//        }
//        if self.cameraIcomBehaviour != nil {
//            self.dynamicsAnimator.removeBehavior(self.cameraIcomBehaviour!)
//        }
//        self.cameraIconSnap = UISnapBehavior(item: self.vwCameraIcon!, snapTo: point)
//        self.cameraIcomBehaviour = UIDynamicItemBehavior(items: [self.vwCameraIcon!])
//        self.cameraIcomBehaviour!.allowsRotation = false
//        self.dynamicsAnimator.addBehavior(self.cameraIcomBehaviour!)
//        self.dynamicsAnimator.addBehavior(self.cameraIconSnap!)
//        
//    }
    
    func animateRoundCornersChange(makeRound:Bool) {
        let newRadius = makeRound ? self.vwMask.bounds.width / 2 : 0
        
        let animation = CABasicAnimation(keyPath: "cornerRadius")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        animation.fromValue = self.vwMask.layer.cornerRadius
        animation.toValue = newRadius
        animation.duration = 0.1
        self.vwMask.layer.add(animation, forKey: "cornerRadius")
        self.vwMask.layer.cornerRadius = newRadius
    }
    
    func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        
        if let error = error {
            print(error.localizedDescription)
        }
        
        if let sampleBuffer = photoSampleBuffer, let previewBuffer = previewPhotoSampleBuffer, let imageData = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: sampleBuffer, previewPhotoSampleBuffer: previewBuffer) {
        
            let image = UIImage(data: imageData)!
            let chosenColor = image.extractDominantColor()
            
            self.currentState = self.nextState(currentState: self.currentState)
            if self.currentState == .PickShirt {
                self.vwShirtColor.backgroundColor = chosenColor
            }
            else {
                self.vwJacketColor.backgroundColor = chosenColor
            }
            
        }
    }
    
    
    func nextState(currentState:ActivityState)->ActivityState {
        switch currentState {
        case .PickShirt:
            return .PickJacket
        case .PickJacket:
            return .ShowResult
        default:
            return .PickShirt;
        }
    }
    
    func updateUI(currentState:ActivityState) {
        if currentState == .PickShirt {
            lblShirt.isHidden = false
            vwShirtColor.isHidden = false
        }
        else if currentState == .PickJacket {
            lblJacket.isHidden = false
            vwShirtColor.isHidden = false
        }
    
        lblHeader.text = self.headerTextForState(currentState)
    }

    
    private func takePicture() {
        let settings = AVCapturePhotoSettings()
        let previewPixelType = settings.availablePreviewPhotoPixelFormatTypes.first!
        let previewFormat = [kCVPixelBufferPixelFormatTypeKey as String: previewPixelType,
                             kCVPixelBufferWidthKey as String: 160,
                             kCVPixelBufferHeightKey as String: 160]
        settings.previewPhotoFormat = previewFormat
        
        cameraImageOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    
//       
//    private func suggestTie() {
//        if chosenShirtColor != nil && chosenJacketColor != nil {
//            let tasteInput = [keyShirtColor:chosenShirtColor!,
//                              keyJacketColor:chosenJacketColor!]
//            let tasteMachine = TasteMachine(input: tasteInput)
//            chosenTieColor = tasteMachine.pickTieColor()
//        }
//        
//        moveStepForward()
//    }
}

