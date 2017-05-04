//
//  SystemMessage.swift
//  sampleapp-completeswift
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import Foundation

//handle all in app's display messages
struct SystemMessage {
    struct ComingSoon {
        static let EmailSignIn = "Email sign in is coming soon!"
        static let EmailSignUp = "Email sign up is coming soon!"
        static let ForgotPassword = "Forgot password is coming soon!"
        static let Community = "Community is coming soon!"
        static let OtherService = "Other services is coming soon!"
        static let VoIP = "VoIP is coming soon!"
        static let BuyVMSim = "Buy VM SIM is coming soon!"
        static let JustUseVMApp = "Just use a VM App is coming soon!"
        static let LuckyNumber = "Lucky number is coming soon!"
        static let InviteFriends = "Invite Friends is coming soon!"
        static let FindFriends = "Find Friends is coming soon!"
        static let BuyData = "Buy Data is coming soon!"
        static let BuyVoice = "Buy Voice is coming soon!"
        static let AutoRenew = "Auto Renew is coming soon!"
        static let SettingMenu = "Setting Menu is coming soon!"
        static let Basket   = "Basket is coming soon!"
        static let CallOnChatList   = "Calling is coming soon!"
        static let Favorite   = "Save as Favorite is coming soon!"
        static let Mute   = "Mute Conversation is coming soon!"
        static let ExtraMenu   = "Extra Menu is coming soon!"
        static let Store   = "Store is coming soon!"
        static let ChatForAssist   = "Chat for Assistance is coming soon!"
        static let Voice   = "Voice Message is coming soon!"
        
        static let HelpFeedBack   = "Help & Feedback is coming soon!"
        static let Notification   = "Notifications is coming soon!"
        static let PaymentDetails   = "Payment details is coming soon!"
        static let ChatRenew   = "Free Chat auto renew is coming soon!"
        static let WalletReload   = "Wallet auto reload is coming soon!"
        static let DataRenew   = "Data auto renew is coming soon!"
        static let VoiceRenew   = "Voice auto renew is coming soon!"
        static let WhatHot   = "Deals & Recommendations coming soon!"
        static let CustomerCare   = "Customer Care is coming soon!"
    }
    
    struct Camera {
        static let CamNotAvailable = "Camera is not available"
        static let GalleryAvailable = "Gallery is not available"
        static let PictureCropped = "Image cropped"
        static let PictureReset = "Image reset"
        static let PleaseAllowCamera = "Please change Settings to allow to access your camera"
    }
    
    struct Microphone {
        static let MicNotAvailable = "Microphone is not available"
        static let PleaseAllowMic = "Please change Settings to allow sound recording"
    }
    
    struct Map {
        static let NoGPS = "Cannot detects current location, please turn on GPS"
        static let MapIsLoading = "Map is loading, please wait"
        static let AllowPermission = "Please change Settings to allow GPS"
    }
    
    struct Information {
        static let FriendAdded = "Friend Added"
        static let FriendRemoved = "Friend Removed"
        static let AppName = "Axiata"
        static let ChatHere = "Chat here..."
    }
    
    struct Update {
        static let CheckRequiredField = "Please input display name and profile image"
        static let UpdateMood = "Update Mood success"
        static let UpdateProfileName = "Update Profile success"
        static let Failed = "Failed to update"
    }
    
    struct Warning {
        static let NoEmail = "Please enter email address"
        static let InvalidEmail = "Invalid email address"
        static let FillInAllFields = "Please fill-in all fields"
        static let FillInPassword = "Please fill-in password"
        static let PasswordNotMatched = "Password does not match the confirm password"
        static let CamNotAvaiable = "Unable to start your camera"
        static let Cancelled = "Cancelled"
        static let PleaseTryAgain = "Connection failed. Please retry again"
        static let FetchFail = "Fetch data failed. Please retry again"
        static let OperationFail = "Operation could not be completed. Please retry again"
        static let DeleteSingleConversation = "Are you sure you want to remove the chat with"
        static let DeleteGroupConversation = "Are you sure you want to remove the group"
        static let DeleteContactWith = "Are you sure you want to remove"
        static let DownloadOriginalImageFail = "Fail to download the original image"
        static let ImageBeingUploaded = "The image is being uploaded"
        static let SignOut = "Are you sure you want to sign out?"
    }
    
    struct ButtonName {
        static let SignOut = "Sign out"
        static let Retry = "Retry"
        static let Remove = "Remove"
        static let Cancel = "Cancel"
        static let Discard = "Discard"
    }
    
    struct NoData {
        static let NoName = "No Name"
    }
    
    struct UIError {
        static let unspecifiedLocation = "Unspecified Location"
    }
    
    struct PhotoAlbum {
        static let Success  = "Photo saved"
        static let Fail     = "Save failed"
    }
}
