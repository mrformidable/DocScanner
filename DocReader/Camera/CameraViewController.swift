//
//  CameraViewController.swift
//  DocReader
//
//  Created by Michael A on 2018-02-16.
//  Copyright © 2018 AI Labs. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Photos

enum SegueIdentifiers: String {
    case photosController = "ShowPhotosVC"
    case editController = "ShowEditVC"
}

class CameraViewController: UIViewController {
    
    @IBOutlet weak var scannerView: ScannerView!
    
    @IBOutlet weak var multiPagesButton: UIButton!
    
    @IBOutlet weak var photosImageView: UIImageView!
    
    // MARK: Session Management
    
    private enum SessionSetupResult {
        case success
        case notAuthorized
        case configurationFailed
    }
    
    private let session = AVCaptureSession()
    
    private var isSessionRunning = false
    
    private let sessionQueue = DispatchQueue(label: "session queue") // Communicate with the session and other session objects on this queue.
    
    private var setupResult: SessionSetupResult = .success
    
    var videoDeviceInput: AVCaptureDeviceInput!
    
    // MARK: Caputuring Photos
    
    var isForceStop = false
    var isStopped = false
    var isCapturing = false
    var borderDetectFrame = false
    var imageDedectionConfidence: CGFloat = 0.0
    var isEnableBorderDetection = true
    var borderDetectLastRectangleFeature: VNRectangleFeature?
    
    private let photoOutput = AVCapturePhotoOutput()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //fetchPhotos()
        loadPhotoFromLibrary()
        setupPhotosButton()
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // The user has previously granted access to the camera.
            break
        case .notDetermined:
            /*
             The user has not yet been presented with the option to grant
             video access. We suspend the session queue to delay session
             setup until the access request has completed.
             
             Note that audio access will be implicitly requested when we
             create an AVCaptureDeviceInput for audio during session setup.
             */
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
            })
            
        default:
            // The user has previously denied access.
            setupResult = .notAuthorized
        }

        sessionQueue.async {
            self.configureSession()
        }
    }
    
    private var borderDetectTimeKeeper: Timer?
    
    private func start() {
        isStopped = false
        session.startRunning()
        DispatchQueue.main.async {
            self.borderDetectTimeKeeper = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.enableBorderDetectFrame), userInfo: nil, repeats: true)
            self.hideGLKView(false)
        }
    }
    
    private func stop() {
        isStopped = true
        session.stopRunning()
        borderDetectTimeKeeper?.invalidate()
        DispatchQueue.main.async {
            self.hideGLKView(true)
        }
    }
    
    @objc
    private func enableBorderDetectFrame() {
        borderDetectFrame = true
    }
    
    private func hideGLKView(_ hidden: Bool) {
        UIView.animate(withDuration: 0.1, animations: {() -> Void in
            self.scannerView.glkView?.alpha = (hidden) ? 0.0 : 1.0
        }, completion: {(_ finished: Bool) -> Void in
            if !finished {
                return
            }
        })
    }
    
    private func setupPhotosButton() {
        photosImageView.layer.cornerRadius = 5
        photosImageView.layer.masksToBounds = true
        photosImageView.layer.shouldRasterize = true
        photosImageView.layer.shadowOpacity = 1
        photosImageView.layer.shadowColor = UIColor.black.cgColor
        //iv.layer.shadowOffset = CGSize.init(width: 2, height: 5)
        photosImageView.layer.shadowOffset = .zero
        photosImageView.layer.shadowRadius = 4
        photosImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapPhotosButton)))
    }
    
    private func loadPhotoFromLibrary() {
        DispatchQueue.global(qos: .background).async {
            let allPhotos = PHAsset.fetchAssets(with: .image, options: PHFetchOptions())
            let imageManager = PHImageManager()
            let imageOptions = PHImageRequestOptions()
            guard let firstPhotoAsset = allPhotos.lastObject else { print("failed to get image"); return}
            
            DispatchQueue.main.async { [weak self] in
                guard let _self = self else {return}
                let size = _self.photosImageView.frame.size
                imageManager.requestImage(for: firstPhotoAsset, targetSize: size, contentMode: .aspectFill, options: imageOptions, resultHandler: { (image, nil) in
                    guard let image = image else {
                        print("Could not retreive image")
                        return
                    }
                    DispatchQueue.main.async {
                        _self.photosImageView.image = image
                    }
                })
            }
        }
    }
    
    @objc
    private func didTapPhotosButton() {
      performSegue(withIdentifier: SegueIdentifiers.photosController.rawValue, sender: self)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sessionQueue.async {
            switch self.setupResult {
            case .success:
                // Only setup observers and start the session running if setup succeeded.
                //self.addObservers()
                self.session.startRunning()
                //self.isEnableBorderDetection = true
                self.start()
                self.isSessionRunning = self.session.isRunning
                
            case .notAuthorized:
                DispatchQueue.main.async {
                    let changePrivacySetting = "AVCam doesn't have permission to use the camera, please change privacy settings"
                    let message = NSLocalizedString(changePrivacySetting, comment: "Alert message when the user has denied access to the camera")
                    let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
                                                            style: .cancel,
                                                            handler: nil))
                    
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: "Alert button to open Settings"),
                                                            style: .`default`,
                                                            handler: { _ in
                                                                UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
                    }))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
                
            case .configurationFailed:
                DispatchQueue.main.async {
                    let alertMsg = "Alert message when something goes wrong during capture session configuration"
                    let message = NSLocalizedString("Unable to capture media", comment: alertMsg)
                    let alertController = UIAlertController(title: "AVCam", message: message, preferredStyle: .alert)
                    
                    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: "Alert OK button"),
                                                            style: .cancel,
                                                            handler: nil))
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sessionQueue.async {
            if self.setupResult == .success {
                self.session.stopRunning()
                self.isSessionRunning = self.session.isRunning
                //self.removeObservers()
            }
        }
    }
    
    private func configureSession() {
        if setupResult != .success {
            return
        }
        
        DispatchQueue.main.async {
            self.scannerView.createGLKView()
        }
        
        session.beginConfiguration()
        session.sessionPreset = .photo
        
        // Add video input.
        do {
            var defaultVideoDevice: AVCaptureDevice?
            
            // Choose the back dual camera if available, otherwise default to a wide angle camera.
            if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
                defaultVideoDevice = dualCameraDevice
            } else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                // If the back dual camera is not available, default to the back wide angle camera.
                defaultVideoDevice = backCameraDevice
            } else  {
                /*
                 In some cases where users break their phones, the back wide angle camera is not available.
                 In this case, we should default to the front wide angle camera.
                 */
                // SHOW SOME ERROR HERE THAT User does not have back camera availabel
                return
            }
            
            let videoDeviceInput = try AVCaptureDeviceInput(device: defaultVideoDevice!)
            
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                self.videoDeviceInput = videoDeviceInput
                
            } else {
                print("Could not add video device input to the session")
                setupResult = .configurationFailed
                session.commitConfiguration()
                return
            }
        } catch {
            print("Could not create video device input: \(error)")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        
        // Add photo output.
        if session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
            let dataOutput = AVCaptureVideoDataOutput()
            dataOutput.alwaysDiscardsLateVideoFrames = true
            dataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as AnyHashable as! String: kCVPixelFormatType_32BGRA]
            dataOutput.setSampleBufferDelegate(self, queue: sessionQueue)
            session.addOutput(dataOutput)
            photoOutput.isHighResolutionCaptureEnabled = true
            let connection: AVCaptureConnection? = dataOutput.connections.first
            connection?.videoOrientation = .portrait
            
            if connection != nil {
                print("connection is not nil")
            }
            
        } else {
            print("Could not add photo output to the session")
            setupResult = .configurationFailed
            session.commitConfiguration()
            return
        }
        session.commitConfiguration()
    }
    
    @IBAction func captuePhoto(_ sender: Any) {
        sessionQueue.async {
            var photoSettings = AVCapturePhotoSettings()
            // Capture HEIF photo when supported, with flash set to auto and high resolution photo enabled.
            if self.photoOutput.availablePhotoCodecTypes.contains(.hevc) {
                photoSettings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.hevc])
            }
            photoSettings.isHighResolutionPhotoEnabled = true
            if !photoSettings.__availablePreviewPhotoPixelFormatTypes.isEmpty {
                photoSettings.previewPhotoFormat = [kCVPixelBufferPixelFormatTypeKey as String: photoSettings.__availablePreviewPhotoPixelFormatTypes.first!]
            }
            self.photoOutput.capturePhoto(with: photoSettings, delegate: self)
        }
    }
    
    @IBAction func proceedButtonTapped(_ sender: Any) {
        performSegue(withIdentifier: SegueIdentifiers.editController.rawValue, sender: self)
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}












