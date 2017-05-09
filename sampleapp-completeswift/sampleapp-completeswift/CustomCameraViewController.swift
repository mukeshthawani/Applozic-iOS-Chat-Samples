//
//  CustomCameraViewController.swift
//  sampleapp-completeswift
//
//  Created by Mukesh Thawani on 08/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import UIKit
import AVFoundation
import Photos


enum CameraPhotoType {
    case NoCropOption
    case CropOption
}

enum CameraType {
    case Front
    case Back
}

var camera = CameraType.Back

protocol CustomCameraProtocol {
    func customCameraDidTakePicture(cropedImage:UIImage)
}

//final class CustomCameraViewController: AXBaseViewController {
//    
//    //delegate
//    var customCamDelegate:CustomCameraProtocol!
//    var camera = CameraType.Back
//    
//    //photo library
//    var asset: PHAsset!
//    var allPhotos: PHFetchResult<PHAsset>!
//    var selectedImage:UIImage!
//    var cameraMode:CameraPhotoType = .NoCropOption
//    let option = PHImageRequestOptions()
//    
//    @IBOutlet private var previewView: UIView!
//    @IBOutlet private var btnCapture: UIButton!
//    @IBOutlet private var previewGallery: UICollectionView!
//    @IBOutlet private var btnSwitchCam: UIButton!
//    
//    private var captureSession = AVCaptureSession()
//    private let stillImageOutput = AVCaptureStillImageOutput()
//    private var previewLayer : AVCaptureVideoPreviewLayer?
//    // If we find a device we'll store it here for later use
//    private var captureDevice : AVCaptureDevice?
//    private var captureDeviceInput: AVCaptureDeviceInput?
//    fileprivate var isUserControlEnable = true
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        self.title = "Camera"
//        btnSwitchCam.isHidden = true
//        checkPhotoLibraryPermission()
//        reloadCamera()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        setupNavigation()
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        
//        //ask for permission
//        let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
//        switch authStatus {
//        case .denied:
//            Logger.debug(message:"denied")
//            // ask for permissions
//            let alertController = UIAlertController (title: SystemMessage.Warning.CamNotAvaiable, message: SystemMessage.Camera.PleaseAllowCamera, preferredStyle: .alert)
//            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
//                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
//                    return
//                }
//                if UIApplication.shared.canOpenURL(settingsUrl) {
//                    if #available(iOS 10.0, *) {
//                        UIApplication.shared.open(settingsUrl, completionHandler: {(success) in
//                            //
//                        })
//                    } else {
//                        // Fallback on earlier versions
//                        UIApplication.shared.openURL(settingsUrl)
//                    }
//                }
//            }
//            alertController.addAction(settingsAction)
//            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
//            alertController.addAction(cancelAction)
//            present(alertController, animated: true, completion: nil)
//        default:()
//        }
//        
//    }
//    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }
//    
//    
//    override func viewDidLayoutSubviews()
//    {
//        //set frame
//        self.previewLayer?.frame = self.previewView.frame
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    //MARK: - Set protocol and Observer
//    func setCustomCamDelegate(camMode:CameraPhotoType, camDelegate:CustomCameraProtocol)
//    {
//        self.cameraMode = camMode
//        self.customCamDelegate = camDelegate
//    }
//    
//    //MARK: - UI control
//    private func setupNavigation() {
//        self.navigationController?.title = title
//        self.navigationController?.navigationBar.setBackgroundImage(UIImage(color: .main, alpha: 0.6), for: .default)
//        guard let navVC = self.navigationController else {return}
//        navVC.navigationBar.shadowImage = UIImage()
//        navVC.navigationBar.isTranslucent = true
//    }
//    
//    private func reloadCamera()
//    {
//        //stop previous capture session
//        captureSession.stopRunning()
//        guard let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) else {
//            Logger.debug(message:"no preview layer")
//            return
//        }
//        previewLayer.removeFromSuperlayer()
//        self.previewLayer?.removeFromSuperlayer()
//        
//        // Do any additional setup after loading the view.
//        captureSession.sessionPreset = AVCaptureSessionPresetHigh
//        
//        if let devices = AVCaptureDevice.devices() as? [AVCaptureDevice] {
//            for device in devices {
//                // Make sure this particular device supports video
//                if (device.hasMediaType(AVMediaTypeVideo)) {
//                    if(camera == .Back)
//                    {
//                        if(device.position == AVCaptureDevicePosition.back) {
//                            captureDevice = device
//                            if captureDevice != nil {
//                                Logger.debug(message:"Capture back camera found")
//                                checkCameraPermission()
//                            }
//                        }
//                    }
//                    else
//                    {
//                        if(device.position == AVCaptureDevicePosition.front) {
//                            captureDevice = device
//                            if captureDevice != nil {
//                                Logger.debug(message:"Capture front camera found")
//                                checkCameraPermission()
//                            }
//                        }
//                    }
//                    
//                }
//            }
//        }
//    }
//    
//    private func checkPhotoLibraryPermission() {
//        let status = PHPhotoLibrary.authorizationStatus()
//        switch status {
//        case .authorized:
//            self.getAllImage(completion: { [weak self] (isGrant) in
//                guard let weakSelf = self else {return}
//                weakSelf.createScrollGallery(isGrant:isGrant)
//            })
//            break
//        //handle authorized status
//        case .denied, .restricted :
//            break
//        //handle denied status
//        case .notDetermined:
//            // ask for permissions
//            PHPhotoLibrary.requestAuthorization() { status in
//                switch status {
//                case .authorized:
//                    self.getAllImage(completion: {[weak self] (isGrant) in
//                        guard let weakSelf = self else {return}
//                        weakSelf.createScrollGallery(isGrant:isGrant)
//                    })
//                    break
//                // as above
//                case .denied, .restricted:
//                    break
//                default: break
//                    //whatever
//                }
//            }
//        }
//    }
//    
//    private func checkCameraPermission()
//    {
//        let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
//        switch authStatus {
//        case .authorized:
//            btnSwitchCam.isHidden = false
//            beginSession()
//        case .denied:
//            Logger.debug(message:"denied")
//            // ask for permissions
//            let alertController = UIAlertController (title: SystemMessage.Warning.CamNotAvaiable, message: SystemMessage.Camera.PleaseAllowCamera, preferredStyle: .alert)
//            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
//                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
//                    return
//                }
//                
//                if UIApplication.shared.canOpenURL(settingsUrl) {
//                    if #available(iOS 10.0, *) {
//                        UIApplication.shared.open(settingsUrl, completionHandler: {(success) in
//                            //
//                        })
//                    } else {
//                        // Fallback on earlier versions
//                        UIApplication.shared.openURL(settingsUrl)
//                    }
//                }
//            }
//            alertController.addAction(settingsAction)
//            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
//            alertController.addAction(cancelAction)
//            present(alertController, animated: true, completion: nil)
//        case .notDetermined:
//            // ask for permissions
//            AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: { [weak self] (isGrant) in
//                guard let weakSelf = self else{return}
//                if isGrant {
//                    DispatchQueue.main.async {
//                        weakSelf.btnSwitchCam.isHidden = false
//                    }
//                }
//            })
//            self.beginSession()
//        default:()
//        }
//    }
//    
//    @IBAction private func actionCameraCapture(_ sender: AnyObject) {
//        saveToCamera()
//    }
//    
//    private func beginSession() {
//        
//        do {
//            try captureDeviceInput = AVCaptureDeviceInput(device: captureDevice)
//            captureSession.addInput(captureDeviceInput)
//            stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
//            
//            if captureSession.canAddOutput(stillImageOutput) {
//                captureSession.addOutput(stillImageOutput)
//            }
//        }
//        catch {
//            Logger.debug(message:"error: \(error.localizedDescription)")
//        }
//        
//        guard let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession) else {
//            Logger.debug(message:"no preview layer")
//            return
//        }
//        
//        //orientation of video
//        let statusBarOrientation    = UIApplication.shared.statusBarOrientation
//        var initialVideoOrientation = AVCaptureVideoOrientation.portrait
//        if (statusBarOrientation != UIInterfaceOrientation.unknown) {
//            initialVideoOrientation = AVCaptureVideoOrientation(rawValue: statusBarOrientation.rawValue)!
//        }
//        
//        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
//        previewLayer.connection.videoOrientation = initialVideoOrientation
//        self.previewLayer = previewLayer
//        //add camera view
//        self.previewView.layer.addSublayer(previewLayer)
//        captureSession.startRunning()
//    }
//    
//    private func saveToCamera() {
//        
//        if isUserControlEnable {
//            
//            isUserControlEnable = false
//            
//            if let videoConnection = stillImageOutput.connection(withMediaType: AVMediaTypeVideo) {
//                
//                if videoConnection.isVideoOrientationSupported,
//                    let orientation = AVCaptureVideoOrientation(orientation: UIDevice.current.orientation) {
//                    videoConnection.videoOrientation = orientation
//                }
//                
//                stillImageOutput.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (CMSampleBuffer, Error) in
//                    if let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(CMSampleBuffer) {
//                        
//                        if let cameraImage = UIImage(data: imageData) {
//                            self.selectedImage = cameraImage
//                            switch self.cameraMode {
//                            case .CropOption:
//                                self.performSegue(withIdentifier: "goToCropImageView", sender: nil)
//                            default:
//                                self.performSegue(withIdentifier: "pushToCustomCameraPreviewViewController", sender: nil)
//                            }
//                        }
//                    }
//                })
//            }
//            enableCameraControl(inSec: 1)
//        }
//    }
//    
//    private func convertCIImageToCGImage(inputImage: CIImage) -> CGImage! {
//        let context = CIContext(options: nil)
//        return context.createCGImage(inputImage, from: inputImage.extent)
//    }
//    
//    @IBAction private func switchCamPress(_ sender: Any) {
//        
//        if isUserControlEnable {
//            isUserControlEnable = false
//            
//            if(camera == .Back)
//            {
//                camera = .Front
//            }
//            else
//            {
//                camera = .Back
//            }
//            
//            if let devices = AVCaptureDevice.devices() as? [AVCaptureDevice] {
//                for device in devices {
//                    if (device.hasMediaType(AVMediaTypeVideo)) {
//                        
//                        let currentCameraInput: AVCaptureInput = captureSession.inputs[0] as! AVCaptureInput
//                        captureSession.removeInput(currentCameraInput)
//                        
//                        let newCamera: AVCaptureDevice?
//                        if(camera == .Front){
//                            newCamera = self.cameraWithPosition(position: AVCaptureDevicePosition.front)
//                        } else {
//                            newCamera = self.cameraWithPosition(position: AVCaptureDevicePosition.back)
//                        }
//                        do {
//                            try captureSession.addInput(AVCaptureDeviceInput(device: newCamera))
//                            stillImageOutput.outputSettings = [AVVideoCodecKey:AVVideoCodecJPEG]
//                            if captureSession.canAddOutput(stillImageOutput) {
//                                captureSession.addOutput(stillImageOutput)
//                            }
//                        }
//                        catch {
//                            Logger.debug(message:"error: \(error.localizedDescription)")
//                        }
//                        captureSession.commitConfiguration()
//                        
//                        enableCameraControl(inSec: 1)
//                        break
//                    }
//                }
//            }
//        }
//    }
//    
//    private func cameraWithPosition(position: AVCaptureDevicePosition) -> AVCaptureDevice {
//        let devices = AVCaptureDevice.devices()
//        for device in devices! {
//            if((device as AnyObject).position == position){
//                return device as! AVCaptureDevice
//            }
//        }
//        return AVCaptureDevice()
//    }
//    
//    
//    @IBAction private func dismissCameraPress(_ sender: Any) {
//        self.navigationController?.dismiss(animated: false, completion:nil)
//    }
//    
//    private func enableCameraControl(inSec:Double)
//    {
//        let disT:DispatchTime = DispatchTime.now() + inSec
//        DispatchQueue.main.asyncAfter(deadline: disT, execute: {
//            self.isUserControlEnable = true
//        })
//    }
//    
//    //MARK: - Access to gallery images
//    private func getAllImage(completion: (_ success: Bool) -> Void) {
//        let allPhotosOptions = PHFetchOptions()
//        allPhotosOptions.includeHiddenAssets = false
//        allPhotosOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
//        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
//        allPhotos = PHAsset.fetchAssets(with: allPhotosOptions)
//        (allPhotos != nil) ? completion(true) :  completion(false)
//    }
//    
//    private func createScrollGallery(isGrant:Bool) {
//        if isGrant
//        {
//            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
//                self.previewGallery.reloadData()
//            })
//        }
//        
//    }
//    
//    // MARK: - Navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        var destination = segue.destination
//        
//        if let topViewController = (destination as? UINavigationController)?.topViewController {
//            destination = topViewController
//        }
//        
//        if let cropView = destination as? CustomCropImageViewController {
//            cropView.setSelectedImage(pickImage: self.selectedImage,camDelegate: customCamDelegate)
//            
//        } else if let customCameraPreviewVC = destination as? CustomCameraPreviewViewController {
//            customCameraPreviewVC.setSelectedImage(pickImage: self.selectedImage, camDelegate: customCamDelegate)
//        }
//    }
//}
//
//extension CustomCameraViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
//{
//    // MARK: CollectionViewEnvironment
//    private class CollectionViewEnvironment {
//        struct Spacing {
//            static let lineitem: CGFloat = 5.0
//            static let interitem: CGFloat = 0.0
//            static let inset: UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 6.0, bottom: 0.0, right: 6.0)
//        }
//    }
//    
//    // MARK: UICollectionViewDelegate
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        //grab all the images
//        let asset = allPhotos.object(at: indexPath.item)
//        PHCachingImageManager.default().requestImageData(for: asset, options:nil) { (imageData, _, _, _) in
//            let image = UIImage(data: imageData!)
//            self.selectedImage = image
//            
//            switch self.cameraMode {
//            case .CropOption:
//                self.performSegue(withIdentifier: "goToCropImageView", sender: nil)
//            default:
//                self.performSegue(withIdentifier: "pushToCustomCameraPreviewViewController", sender: nil)
//            }
//        }
//    }
//    
//    // MARK: UICollectionViewDataSource
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        if(allPhotos == nil)
//        {
//            return 0
//        }
//        else
//        {
//            return allPhotos.count//horizontal
//        }
//        
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCollectionCell", for: indexPath) as! PhotoCollectionCell
//        
//        let asset = allPhotos.object(at: indexPath.item)
//        let thumbnailSize:CGSize = CGSize(width: 200, height: 200)
//        option.isSynchronous = true
//        PHCachingImageManager.default().requestImage(for: asset, targetSize: thumbnailSize, contentMode: .aspectFill, options: option, resultHandler: { image, _ in
//            cell.imgPreview.image = image
//        })
//        
//        cell.imgPreview.backgroundColor = UIColor.white
//        
//        return cell
//    }
//    
//    func numberOfSections(in collectionView: UICollectionView) -> Int {
//        return 1//the vertical side
//    }
//    
//    // MARK: UICollectionViewDelegateFlowLayout
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
//        return CollectionViewEnvironment.Spacing.lineitem
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
//        return CollectionViewEnvironment.Spacing.interitem
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
//        return CollectionViewEnvironment.Spacing.inset
//    }
//}
