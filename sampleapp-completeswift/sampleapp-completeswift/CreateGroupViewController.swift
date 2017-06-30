//
//  CreateGroupViewController.swift
//  
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//


import UIKit
import Kingfisher

enum AddContactMode {
    case newChat
    case existingChat
    
    var navigationBarTitle: String {
        switch self {
        case .newChat:
            return "Create Group"
        default:
            return "Edit Group"
        }
    }
    
    var doneButtonTitle: String {
        return "Save"
    }
}

protocol CreateGroupChatAddFriendProtocol {
    func createGroupGetFriendInGroupList(friendsSelected: [FriendViewModel],groupName:String,groupImgUrl:String, friendsAdded: [FriendViewModel])
}

final class CreateGroupViewController: ALBaseViewController {

    var groupList = [FriendViewModel]()
    var addedList = [FriendViewModel]()
    var groupProfileImgUrl = ""
    var groupDelegate: CreateGroupChatAddFriendProtocol!
    private var groupName:String = ""
    var addContactMode: AddContactMode = AddContactMode.newChat
    
    @IBOutlet fileprivate var btnCreateGroup: UIButton!
    @IBOutlet fileprivate var tblParticipants: UICollectionView!
    @IBOutlet fileprivate var txtfGroupName: ALGroupChatTextField!
    
    @IBOutlet fileprivate weak var viewGroupImg: UIView!
    @IBOutlet fileprivate weak var imgGroupProfile: UIImageView!
    fileprivate var tempSelectedImg:UIImage!
    fileprivate var cropedImage: UIImage?
    
    var viewModel: CreateGroupViewModel?
    
    private var createGroupBGColor: UIColor {
        return btnCreateGroup.isEnabled ? UIColor.mainRed() : UIColor.disabledButton()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        setupUI()
        self.hideKeyboard()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        txtfGroupName.resignFirstResponder()
        //self.hideKeyboard()
    }
    
    //MARK: - UI controller
    @IBAction func dismisssPress(_ sender: Any) {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func createGroupPress(_ sender: Any) {

        guard let groupName = self.txtfGroupName.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            alert(msg: "Please fill out group name")
            return
        }
        
        if groupName.lengthOfBytes(using: .utf8) < 1 {
            
            alert(msg: "Please fill out group name")
            return
        }
        
        if self.groupDelegate != nil
        {
//            if let image = cropedImage {

//                let hud = MBProgressHUD.showTransparentAdded(to: view, animated: true)

//                let request = UploadPicProfileRequest(pictureFileName: getPictureFilename() , image: image)

//                API.uploadWithToken(request: request) { [weak self] (result: UploadProfilePicResult?, isCache, error) in
//                    guard let weakSelf = self else { return }
//                    
//                    //upload image first
//                    if let result = result, let urlString = result.urlString, error == nil {
//                        hud.hide(animated: true)
            //upload profile pic
                        groupDelegate.createGroupGetFriendInGroupList(friendsSelected: groupList, groupName: groupName, groupImgUrl: "", friendsAdded: addedList)
//                    } else {
//                        //error
//                        hud.hide(animated: true)
//                        weakSelf.view.makeToast(SystemMessage.Update.Failed, duration: 1.0, position: .center)
//                    }
//                }
//
            } else {
                groupDelegate.createGroupGetFriendInGroupList(friendsSelected:groupList, groupName: groupName, groupImgUrl: groupProfileImgUrl, friendsAdded:addedList)
            }
//        }
    }
    
    fileprivate func setupUI() {
        // Textfield Group name
        txtfGroupName.layer.cornerRadius = 10
        txtfGroupName.layer.borderColor = UIColor.mainRed().cgColor
        txtfGroupName.layer.borderWidth = 1
        txtfGroupName.clipsToBounds = true
        txtfGroupName.delegate = self
        setupAttributedPlaceholder(textField: txtfGroupName)
        
        //set btns into circle
        viewGroupImg.layer.cornerRadius = 0.5 * viewGroupImg.frame.size.width
        viewGroupImg.clipsToBounds = true
        
        if addContactMode == .existingChat {
            // Button Create Group
            btnCreateGroup.layer.cornerRadius = 15
            btnCreateGroup.clipsToBounds = true
            btnCreateGroup.setTitle(addContactMode.doneButtonTitle, for: UIControlState.normal)
        } else {
            btnCreateGroup.isHidden = true
        }
        
        txtfGroupName.text = self.groupName
        
        updateCreateGroupButtonUI(contactInGroup: groupList.count,
                                  groupname: txtfGroupName.trimmedWhitespaceText())
        
        self.tblParticipants.reloadData()
        self.title = addContactMode.navigationBarTitle
        
        if let url = URL.init(string: groupProfileImgUrl) {
            let placeHolder = UIImage(named: "group_profile_picture-1")
            let resource = ImageResource(downloadURL: url, cacheKey:groupProfileImgUrl)
            imgGroupProfile.kf.setImage(with: resource, placeholder: placeHolder, options: nil, progressBlock: nil, completionHandler: nil)
//            imgGroupProfile.cropRedProfile()

        }

    }
    
    private func setupAttributedPlaceholder(textField: UITextField) {
        let style           = NSMutableParagraphStyle()
        style.alignment     = .left
        style.lineBreakMode = .byWordWrapping
        
        guard let font      = UIFont(name: "HelveticaNeue-Italic", size: 14) else { return }
        let attr:[String:Any] = [
            NSFontAttributeName:font,
            NSParagraphStyleAttributeName:style,
            NSForegroundColorAttributeName: UIColor.placeholderGray()
        ]
        textField.attributedPlaceholder  = NSAttributedString(string: "Type group name", attributes: attr)
    }
    
    @IBAction private func selectGroupImgPress(_ sender: Any) {
        let storyboard = UIStoryboard.name(storyboard: UIStoryboard.Storyboard.camera)
        
        if let vc = storyboard.instantiateViewController(withIdentifier: "CustomCameraNavigationController") as? ALBaseNavigationViewController {
            guard let firstVC = vc.viewControllers.first else {return}
            let cameraView = firstVC as! CustomCameraViewController
            cameraView.setCustomCamDelegate(camMode: .CropOption, camDelegate: self)
            self.present(vc, animated: false, completion: nil)
        }
    }

    private func getPictureFilename() -> String {
        var name = ""
        
        // Add user id
//        if let userID = ChatManager.shared.userID {
//            name = name + userID
//        }

        // Add time
        let dateFormatter       = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd_HHmmss"
        let dateString          = dateFormatter.string(from: Date())
        return name + "_" + dateString + "_profile.png"
    }
    
    func setCurrentGroupSelected(groupName: String, groupProfileImg: String?, groupSelected:[FriendViewModel],delegate: CreateGroupChatAddFriendProtocol) {
        // TODO: Plan to use groupname from view model
        viewModel = CreateGroupViewModel(groupName: groupName)
        self.groupName = groupName
        self.groupDelegate = delegate
        self.groupList = groupSelected
        
        guard let gImgUrl = groupProfileImg else {return}
        groupProfileImgUrl = gImgUrl
        
    }
    
    private func isAtLeastOneContact(contactCount: Int) -> Bool {
        return contactCount > 0
    }
    
    private func changeCreateGroupButtonState(isEnabled: Bool) {
        btnCreateGroup.isEnabled = isEnabled
        btnCreateGroup.backgroundColor = createGroupBGColor
    }
    
    fileprivate func updateCreateGroupButtonUI(contactInGroup: Int, groupname: String) {
        guard isAtLeastOneContact(contactCount: contactInGroup) else {
            changeCreateGroupButtonState(isEnabled: false)
            return
        }
        guard !groupname.isEmpty else {
            changeCreateGroupButtonState(isEnabled: false)
            return
        }
        changeCreateGroupButtonState(isEnabled: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToSelectFriendToAdd" {
            let selectParticipantViewController = segue.destination as? SelectParticipantToAddViewController
            selectParticipantViewController?.selectParticipantDelegate = self
            selectParticipantViewController?.friendsInGroup = self.groupList
        }
    }
}

extension CreateGroupViewController: UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if(self.groupList.count == 0) {
            return 1//just an add button
        } else {
            return self.groupList.count + 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = self.tblParticipants.dequeueReusableCell(withReuseIdentifier:"AddParticipantCollectionCell", for: indexPath) as! AddParticipantCollectionCell
        
        if(indexPath.row == self.groupList.count) {
            //it's an added btn
            cell.setDelegate(friend: nil, atIndex: indexPath, delegate: self)
            
            guard let viewModel = viewModel else { return cell }
            cell.setStatus(isAddButtonEnabled: viewModel.isAddParticipantButtonEnabled())
        } else if (self.groupList.count == 0) {
            //it's an added btn
            cell.setDelegate(friend: nil, atIndex: indexPath, delegate: self)
            guard let viewModel = viewModel else { return cell }
            cell.setStatus(isAddButtonEnabled: viewModel.isAddParticipantButtonEnabled())
        } else {
            let temp = self.groupList[indexPath.row]
            cell.setDelegate(friend: temp, atIndex: indexPath, delegate: self)
        }
        return cell
    }
}

extension CreateGroupViewController:AddParticipantProtocol
{
    func addParticipantAtIndex(atIndex: IndexPath) {
        if (atIndex.row == self.groupList.count || self.groupList.count == 0) {
            txtfGroupName.resignFirstResponder()
            self.performSegue(withIdentifier: "goToSelectFriendToAdd", sender: nil)
        } else {
            //do nothing yet
        }
    }
}


extension CreateGroupViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.txtfGroupName?.resignFirstResponder()
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let str = textField.text as NSString?
        if let text  = str?.replacingCharacters(in: range, with: string) {
            updateCreateGroupButtonUI(contactInGroup: groupList.count, groupname: text)
            
            guard let viewModel = viewModel else { return true }
            
            let oldStatus = viewModel.isAddParticipantButtonEnabled()
            
            viewModel.groupName = text.trimmingCharacters(in: .whitespacesAndNewlines)
            
            let newStatus = viewModel.isAddParticipantButtonEnabled()
            if oldStatus != newStatus {
                tblParticipants.reloadData()
            }
        }
        return true
    }
}


extension CreateGroupViewController: SelectParticipantToAddProtocol {
    func selectedParticipant(selectedList: [FriendViewModel], addedList: [FriendViewModel]) {
        self.groupList = selectedList
        self.addedList = addedList
        
        //createGroup()
        self.createGroupPress(btnCreateGroup)
        
        /*
        self.tblParticipants.reloadData()
        
        updateCreateGroupButtonUI(contactInGroup: groupList.count, groupname: txtfGroupName.trimmedWhitespaceText())
        */
    }
    
    private func createGroup() {
        guard let groupName = self.txtfGroupName.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return
        }
        
        if groupName.lengthOfBytes(using: .utf8) < 1 {
            return
        }
        
        if self.groupDelegate != nil {
            self.groupDelegate.createGroupGetFriendInGroupList(friendsSelected: self.groupList,
                                                               groupName: groupName,groupImgUrl:"",
                                                               friendsAdded: self.addedList)
        }
    }
}

extension CreateGroupViewController
{
    override func hideKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(CreateGroupViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    override func dismissKeyboard() {
        txtfGroupName.resignFirstResponder()
        view.endEditing(true)
    }
    
    override func backTapped() {
        guard let createGroupViewModel = viewModel else {
            _ = navigationController?.popViewController(animated: true)
            return
        }
        guard let navigationController = navigationController else { return }
        
        UIAlertController.presentDiscardAlert(onPresenter: navigationController,
                                              onlyForCondition: { () -> Bool in
                                                return (
                                                    createGroupViewModel.groupName != createGroupViewModel.originalGroupName || cropedImage != nil
                                                )
        }) { [weak self] in
            guard let weakSelf = self else { return }
            _ = weakSelf.navigationController?.popViewController(animated: true)
        }
    }
}

extension CreateGroupViewController:CustomCameraProtocol
{
    func customCameraDidTakePicture(cropedImage: UIImage) {
        // Be back from cropiing camera page
        self.tempSelectedImg = self.imgGroupProfile.image
        self.imgGroupProfile.image = cropedImage
        self.cropedImage = cropedImage
    }
}
