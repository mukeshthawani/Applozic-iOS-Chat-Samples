//
//  FriendViewModel.swift
//  Axiata
//
//  Created by Appsynth on 12/19/2559 BE.
//  Copyright © 2559 Appsynth. All rights reserved.
//

import Foundation
//import LayerKit

protocol ContactProtocol {
    
    var friendUUID: String? { get }
//    var friendLayerID: String? { get }
//    var friendLayerUserID: String? { get }
    var friendMood: String? { get }
    var friendProfileName: String? { get }
    var friendDisplayImgURL: URL? { get }
}

class FriendViewModel
{
    var friendUUID:String?
//    var friendLayerID:String?
//    var friendLayerUserID:String?
    var friendProfileName:String?
    var friendFirstName:String?
    var friendLastName:String?
    var friendEmail:String?
    var friendMood:String?
    var friendPhoneNumber:String?
    var friendDisplayImgURL:URL?
    var friendMoodExpiredAt: NSNumber?
    var isSelected:Bool = false
    
//    init(identity:Contact) {
//        
//        self.friendUUID = identity.uuid
////        self.friendLayerID = identity.layer_identity_id
////        self.friendLayerUserID = identity.layer_identity_userID
////        self.friendMood = identity.mood
//        self.friendProfileName = (identity.profileName).isEmpty ? "no name" : identity.profileName
//        self.friendMoodExpiredAt = identity.mood_expired_at
//        
//        if let profilePhotoURL = identity.profilePhotoURL {
//            self.friendDisplayImgURL = URL(string: profilePhotoURL.stripHTML())
//        } else {
//            self.friendDisplayImgURL = URL(fileURLWithPath: "placeholder")
//        }
//        
//    }
//    
//    
//    init(identity: IdentityProtocol) {
//        
//        self.friendUUID = identity.userID
////        self.friendLayerID = identity.layerID
////        self.friendLayerUserID = identity.userID
////        self.friendMood = identity.mood
//        self.friendMoodExpiredAt = identity.mood_expired_at
//        self.friendProfileName = (identity.displayName).isEmpty ? SystemMessage.NoData.NoName : identity.displayName
//        
//        if let displayPhoto = identity.displayPhoto {
//            self.friendDisplayImgURL = displayPhoto
//        } else {
//            self.friendDisplayImgURL = URL(fileURLWithPath: "placeholder")
//        }
//    }

    init(identity:ContactProtocol) {
        
        self.friendUUID = identity.friendUUID
//        self.friendLayerID = identity.friendLayerID
//        self.friendLayerUserID = identity.friendLayerUserID
//        self.friendMood = identity.friendMood
        self.friendProfileName = identity.friendProfileName
        //self.friendMoodExpiredAt = identity.friendMoodExpiredAt
        if let friendDisplayImgURL = identity.friendDisplayImgURL {
            self.friendDisplayImgURL = friendDisplayImgURL
        } else {
            self.friendDisplayImgURL = URL(fileURLWithPath: "placeholder")
        }
        
    }
    
    //MARK: - Get
    func getFriendDisplayName() -> String
    {
        return friendProfileName ?? "No Name"
    }
    
    func getFriendID() -> String
    {
        return friendUUID!
    }
    
//    func getFriendLayerID() -> String
//    {
//        return friendLayerID!
//    }

    func getFriendDisplayImgURL() -> URL
    {
        return friendDisplayImgURL!
    }
    
//    func getFriendLayerUserID() -> String
//    {
//        return friendLayerUserID!
//    }

//    func getFriendMood() -> String
//    {
//        return friendMood!
//    }

    func getIsSelected() -> Bool
    {
        return isSelected
    }
    
    //MARK: - Set
    func setIsSelected(select:Bool)
    {
        isSelected = select
    }
}
