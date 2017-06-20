//
//  SelectProfilePicViewController.swift
//  Axiata
//
//  Created by Appsynth on 12/13/2559 BE.
//  Copyright © 2559 Appsynth. All rights reserved.
//

import UIKit
import Kingfisher
import Applozic
import MBProgressHUD
//import VoxeetConferenceKit


typealias SaveProfileCompletion = (Bool, Bool?) -> ()

class SelectProfilePicViewController: ALBaseViewController {

//    @IBOutlet fileprivate var txtfProfileNAme: UITextField!
//    @IBOutlet fileprivate var imgProfile: UIImageView!
//    @IBOutlet fileprivate var btnCamera: UIButton!
//    @IBOutlet fileprivate var btnBack: UIBarButtonItem!
//    @IBOutlet fileprivate weak var btnDone: UIButton!
//    @IBOutlet fileprivate weak var viewProfileContainer: UIView!
//    
////    let chatManager = ChatManager.shared
//    var tempSelectedImg:UIImage!
////    var userProfile:Contact!
////    fileprivate var userDataService: UserDataService?
//    fileprivate var cropedImage: UIImage?
//    
//    private var existingDisplayName: String = ""
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        setupUserDataService()
//        setupUI()
//        hideKeyboard()
//    }
//
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        guard tempSelectedImg == nil else { return }
//        fetchUserProfile()
//    }
//    
//    override var preferredStatusBarStyle: UIStatusBarStyle {
//        return .lightContent
//    }
//    
//    //MARK: - UI controller
//    private func fetchUserProfile() {
////        userDataService?.fetch(complete: { [weak self] (user) in
//////            Logger.debug(message: "User from userDataService: \(user)")
////
////            guard let weakSelf = self else {return}
////            
////            let contact: Contact? = user.getObject()
////            guard let user = contact else { return }
////            
////            weakSelf.setUserProfile(user: user)
////        })
//    }
//    
//    private func setupUserDataService() {
//        if let account = AuthenticationManager.shared.account {
//            userDataService = UserDataService(account: account, apiService: apiClient, dbService: db)
//        }
//    }
//    
//    private func setupUI()
//    {
//        self.title = "Update Profile"
//        self.navigationController?.navigationBar.backgroundColor = UIColor.blue
//        
//        let color = UIColor.color(Color.Background.main)
//        
//        //set btns into circle
//        viewProfileContainer.layer.cornerRadius = 0.5 * viewProfileContainer.frame.size.width
//        viewProfileContainer.clipsToBounds = true
//        
//        txtfProfileNAme.layer.cornerRadius = 12
//        txtfProfileNAme.layer.borderColor = color.cgColor
//        txtfProfileNAme.layer.borderWidth = 1
//        txtfProfileNAme.clipsToBounds = true
//        txtfProfileNAme.delegate = self
//        
//        btnDone.layer.cornerRadius = 15
//    }
//    
//    private func setUserProfile(user:Contact)
//    {
//        userProfile = user
//        
//        if(userProfile != nil)
//        {
//            guard let txtName = txtfProfileNAme.text else {return}
//            if(txtName.isEmpty && !userProfile.profileName.isEmpty) {
//                txtfProfileNAme.text    = userProfile.profileName
//                existingDisplayName     = userProfile.profileName
//            }
//            
//            guard let profileURL = userProfile.profilePhotoURL else {return}
//            if !profileURL.isEmpty && tempSelectedImg == nil {
//                let placeHolder = UIImage(named: "profile_placeholder")
//
//                if let url = URL.init(string: profileURL) {
//                    let resource = ImageResource(downloadURL: url, cacheKey:userProfile.profilePhotoURL)
//                    
//                    imgProfile.kf.setImage(with: resource, placeholder: placeHolder, options: nil, progressBlock: nil, completionHandler: { [weak self] (image, error, cacheType, url) in
//                        guard let weakSelf = self else { return }
//                        
//                        weakSelf.imgProfile.contentMode = .scaleAspectFill
//                        weakSelf.imgProfile.cropRedProfile()
//                    })
//                    
//                }
//            }
//        }
//        
//        //enable btns
//        btnCamera.isUserInteractionEnabled = true
//        btnBack.isEnabled = true
//        btnDone.isEnabled = true
//    }
//    
//    @IBAction func cameraPress(_ sender: Any) {
//        let storyboard = UIStoryboard.name(storyboard: UIStoryboard.Storyboard.camera)
//        
//        if let vc = storyboard.instantiateViewController(withIdentifier: "CustomCameraNavigationController") as? AXBaseNavigationViewController {
//            guard let firstVC = vc.viewControllers.first else {return}
//            let cameraView = firstVC as! CustomCameraViewController
//            cameraView.setCustomCamDelegate(camMode: .CropOption, camDelegate: self)
//            self.present(vc, animated: false, completion: nil)
//        }
//    }
//    
//    /*
//    @IBAction func cancelPress(_ sender: Any) {
//        self.txtfProfileNAme.text = ""
//        self.dismiss(animated: false, completion: nil)
//    }
//    */
//    
//    @IBAction func backToPrevious(_ sender: Any) {
//        self.dismiss(animated: false, completion: nil)
//    }
//    
//    @IBAction func savePress(_ sender: Any) {
//        dismissKeyboard()
//        
//        let _ = MBProgressHUD.showTransparentAdded(to: view, animated: true)
//        disableInteraction()
//        
//        saveProfile(cropedImage: cropedImage, completion: { [weak self] (success: Bool, shouldShowAlert: Bool?) in
//            guard let weakSelf = self else { return }
//            
//            MBProgressHUD.hide(for: weakSelf.view, animated: true)
//            
//            if success {
//                let restoreUIState = {
//                    weakSelf.enableInteractionHUD()
//                    weakSelf.backToPrevious(Any.self)
//                }
//                
//                if let showAlert = shouldShowAlert, showAlert == false {
//                    restoreUIState()
//                } else {
//                    weakSelf.showSuccessToast(completion: {
//                        restoreUIState()
//                    })
//                }
//            } else {
//                weakSelf.showFailToast(completion: {
//                    weakSelf.enableInteractionHUD()
//                    
//                })
//            }
//        })
//    }
//    
//    private  func showFailToast(completion: @escaping () -> ()) {
//        view.makeToast(SystemMessage.Update.Failed, duration: 1.0, position: .center, title:nil, image: nil, style:nil, completion: {(Bool) in
//            completion()
//        })
//    }
//    
//    private func showSuccessToast(completion: @escaping () -> ()) {
//        view.makeToast(SystemMessage.Update.UpdateProfileName, duration: 2, position: .center, title:nil, image: nil, style:nil, completion: {(Bool) in
//            completion()
//        })
//    }
//    
//    private func resetProfileImage() {
//        imgProfile.image = tempSelectedImg
//    }
//    
//    private func disableInteraction() {
//        //if let view = self.view {
//            self.btnCamera.isUserInteractionEnabled = false
//            self.btnBack.isEnabled = false
//            self.btnDone.isEnabled = false
//    }
//    
//    private func enableInteractionHUD() {
//        //if let view = self.view {
//            self.btnCamera.isUserInteractionEnabled = true
//            self.btnBack.isEnabled = true
//            self.btnDone.isEnabled = true
//            //MBProgressHUD.hide(for: view, animated: true)
//        //}
//    }
//    
//    private func saveProfileInfo(newUrlString: String?, profileName: String, completion: @escaping SaveProfileCompletion) {
//        
//        guard let userProfile = userProfile else {
//            completion(false, nil)
//            return
//        }
//        
//        guard profileName.isEmpty == false else {
//            completion(false, nil)
//            return
//        }
//
//        let updateUserRequest = UpdateUserWithOptionalParamsRequest(myID: userProfile.layer_identity_userID,
//                                                                    profileName: profileName,
//                                                                    profilePhotoURLString:newUrlString)
//        
////        API.requestForItemWithToken(request: updateUserRequest) { [weak self] (contact: Contact?, isCache, error) in
////            
////            guard let weakSelf = self else { return }
////            
////            guard let contact = contact else {
////                return
////            }
////            
////            if error == nil {
////                weakSelf.existingDisplayName = contact.displayName
////                
////                Logger.debug(message: "Success to update contact \(contact)")
////                AuthenticationManager.shared.cacheUser(user: contact)
////
//                let userService = ALUserService()
//                print("new url string: ", newUrlString)
//                userService.updateUserDisplayName(profileName, andUserImage: newUrlString ?? "", userStatus: "", withCompletion: {
//                    _, error in
//                    if error == nil {
//                        ALUserDefaultsHandler.setDisplayName(profileName)
//                        if let url = newUrlString {
//                            ALUserDefaultsHandler.setProfileImageLink(url)
//                        }
//                        completion(true, nil)
//                    } else {
//                        completion(false, nil)
//                    }
//                })
////        }
//    }
//
//    private func isProfileNameExist() -> (Bool, String) {
//        if let profileName = txtfProfileNAme.text, profileName.isEmpty == false {
//            return (true, profileName)
//        }
//        return (false, "")
//    }
//    
//    private func saveProfile(cropedImage: UIImage?, completion: @escaping SaveProfileCompletion) {
//        
//        guard userProfile != nil else {
//            completion(false, nil)
//            return
//        }
//        
//        let (isExist, profileName) = isProfileNameExist()
//        
//        guard isExist else {
//            completion(false, nil)
//            return
//        }
//        
//        if let image = cropedImage {
//            
////            let request = UploadPicProfileRequest(pictureFileName: getPictureFilename() , image: image)
//
////            API.uploadWithToken(request: request) { [weak self] (result: UploadProfilePicResult?, isCache, error) in
////                guard let weakSelf = self else { return }
////                
////                if let result = result, let urlString = result.urlString, error == nil {
////                    weakSelf.saveProfileInfo(newUrlString: urlString, profileName: profileName, completion: completion)
////
////                } else {
////                    completion(false, nil)
////                }
////            }
//        } else {
////            if profileName != existingDisplayName {
////                saveProfileInfo(newUrlString: nil, profileName: profileName, completion: completion)
////            } else {
////                completion(true, false)
////            }
//        }
//    }
//    
//    private func getPictureFilename() -> String {
//        var name = ""
//        
//        // Add user id
//        if let userID = ChatManager.shared.userID {
//            name = name + userID
//        }
//        
//        // Add time
//        let dateFormatter       = DateFormatter()
//        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
//        let dateString          = dateFormatter.string(from: Date())
//        return name + "_" + dateString + "_profile.png"
//    }
//    
//    private func voxeetUpdateSession(userID: String, displayName: String, avatarURL: String) {
//        // Get user information.
////        var userInfo = [String: Any]()
////        userInfo["externalName"] = displayName
////        userInfo["externalPhotoUrl"] = avatarURL
////        
////        // Update Voxeet session.
////        VoxeetConferenceKit.shared.updateSession(userID: userID, userInfo: userInfo, completion: { (error) in
////            if let error = error {
////                Logger.debug(message:"[VoxeetConferenceKit] Update session error: \(error)")
////            }
////        })
//    }
}
//
//extension SelectProfilePicViewController:CustomCameraProtocol,UITextFieldDelegate
//{
//    func customCameraDidTakePicture(cropedImage: UIImage) {
//        // Be back from cropiing camera page
//        self.tempSelectedImg = self.imgProfile.image
//        self.imgProfile.image = cropedImage
//        self.cropedImage = cropedImage
//    }
//    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        self.txtfProfileNAme.resignFirstResponder()
//        return true
//    }
//}
//
