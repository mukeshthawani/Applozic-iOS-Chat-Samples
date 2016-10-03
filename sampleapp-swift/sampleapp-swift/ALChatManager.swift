//
//  ALChatManager.swift
//  applozicswift
//
//  Created by Devashish on 30/12/15.
//  Copyright © 2015 Applozic. All rights reserved.
//

import UIKit
import Applozic

var TYPE_CLIENT : Int16 = 0
var TYPE_APPLOZIC : Int16 = 1
var TYPE_FACEBOOK : Int16 = 2

var APNS_TYPE_DEVELOPMENT : Int16 = 0
var APNS_TYPE_DISTRIBUTION : Int16 = 1

class ALChatManager: NSObject {
    
    static let applicationId = "applozic-sample-app"
    
    init(applicationKey: NSString) {
        
        ALUserDefaultsHandler.setApplicationKey(applicationKey as String)
    }
    
    // ----------------------
    // Call This at time of your app's user authentication OR User registration.
    // This will register your User at applozic server.
    //----------------------
    
     func registerUser(_ alUser: ALUser) {
        
        let alChatLauncher: ALChatLauncher = ALChatLauncher(applicationId: getApplicationKey() as String)
        ALDefaultChatViewSettings()

        let registerUserClientService: ALRegisterUserClientService = ALRegisterUserClientService()
        registerUserClientService.initWithCompletion(alUser, withCompletion: { (response, error) in
            
            if (error != nil)
            {
                print("error while registering to applozic");
            }
            else if(response?.message.isEqual("PASSWORD_INVALID"))!
            {
                ALUtilityClass.showAlertMessage("Invalid Passoword", andTitle: "Oops!!!")
            }
            else
            {
                print("registered")
                if(ALChatManager.isNilOrEmpty(ALUserDefaultsHandler.getApnDeviceToken() as NSString?))
                {
                    alChatLauncher.registerForNotification()
                }
            }
        })
    }
    
     func registerUser(_ alUser: ALUser, completion : @escaping (_ response: ALRegistrationResponse, _ error: NSError?) -> Void) {
    
        let alChatLauncher: ALChatLauncher = ALChatLauncher(applicationId: getApplicationKey() as String)
        ALDefaultChatViewSettings()
        
        let registerUserClientService: ALRegisterUserClientService = ALRegisterUserClientService()
    
        registerUserClientService.initWithCompletion(alUser, withCompletion: { (response, error) in
    
            if (error != nil)
            {
                print("error while registering to applozic");
            }
            else if(response?.message.isEqual("PASSWORD_INVALID"))!
            {
                ALUtilityClass.showAlertMessage("Invalid Passoword", andTitle: "Oops!!!")
            }
            else
            {
                print("registered")
                if(ALChatManager.isNilOrEmpty(ALUserDefaultsHandler.getApnDeviceToken() as NSString?))
                {
                    alChatLauncher.registerForNotification()
                }
                completion(response! , error as NSError?)
            }
        })
    }
    
    // ----------------------  ------------------------------------------------------/
    // convenient method to launch chat-list, after user registration is done on applozic server.
    //
    // This will automatically handle unregistered users provided getLoggedinUserInformation is implemented properly.
    // ----------------------  ------------------------------------------------------/
    
    func launchChat(_ fromViewController:UIViewController){
        self.registerUserAndLaunchChat(nil, fromController: fromViewController, forUser: nil)
    }
    
    // ----------------------  ------------------------------------------------------/
    // convenient method to directly launch individual user chat screen. UserId parameter define users for which it intented to launch chat screen.
    //
    // This will automatically handle unregistered users provided getLoggedinUserInformation is implemented properly.
    // ----------------------  ------------------------------------------------------/
    
    func launchChatForUser(_ forUserId : String ,fromViewController:UIViewController){
        self.registerUserAndLaunchChat(nil, fromController: fromViewController, forUser: forUserId)
    }
    
    // ----------------------  ------------------------------------------------------/
    //      Method to register + lauch chats screen. If user is already registered, directly chats screen will be launched.
    //      If user information is not passed, it will try to get user information from getLoggedinUserInformation.
    //-----------------------  ------------------------------------------------------/
    
    func registerUserAndLaunchChat(_ alUser:ALUser?, fromController:UIViewController,forUser:String?)
    {
        let alChatLauncher: ALChatLauncher = ALChatLauncher(applicationId: getApplicationKey() as String)
       
        if(!ALChatManager.isNilOrEmpty(ALUserDefaultsHandler.getDeviceKeyString() as NSString?))
        {
            if (ALChatManager.isNilOrEmpty(forUser as NSString?))
            {
                let title  = ALChatManager.isNilOrEmpty(fromController.title as NSString?) ? "< Back" : fromController.title;
                alChatLauncher.launchChatList(title, andViewControllerObject:fromController);
            }
            else
            {
                alChatLauncher.launchIndividualChat(forUser, withGroupId: nil, andViewControllerObject: fromController, andWithText: nil)
            }
            return;
        }
        
        //register user as it is not registered already ...
        var user : ALUser;
        if (alUser == nil) {
            user = ALChatManager.getUserDetail()
        }else {
            user = alUser!;

        }
        ALDefaultChatViewSettings();

        // register and launch...
        let registerUserClientService: ALRegisterUserClientService = ALRegisterUserClientService()
        registerUserClientService.initWithCompletion(user, withCompletion: { (response, error) in
            if (error != nil) {
                //TODO : show/handle error
                print("error while registering to applozic");
                return;
            } else if(response?.message == "REGISTERD"){
                print("registered!!!")
                if(ALChatManager.isNilOrEmpty(ALUserDefaultsHandler.getApnDeviceToken() as NSString?)){
                    alChatLauncher.registerForNotification()
                }
                //let messageClientService: ALMessageClientService = ALMessageClientService()
                //messageClientService.addWelcomeMessage()
            }
            if (ALChatManager.isNilOrEmpty(forUser as NSString?)){
                let title  = ALChatManager.isNilOrEmpty(fromController.title as NSString?) ?"< Back" : fromController.title;
                alChatLauncher.launchChatList(title, andViewControllerObject:fromController);
            }else {
                alChatLauncher.launchIndividualChat(forUser, withGroupId: nil, andViewControllerObject: fromController, andWithText: nil)
            }
        })
    }
    
    // ----------------------  ---------------------------------------------------------------------------------------------//
    //     This method can be used to get app logged-in user's information.
    //     if user information is stored in DB or preference, Code to get user's information should go here.
    //     This might be used to get existing user information in case of app update.
    //----------------------   -----------------------------------------------------------------------------------------//
    
    class func getUserDetail() -> ALUser {
        
        // TODO:Write your won code to get userId in case of update or in case of user is not registered....
        
        let user: ALUser = ALUser()
        user.userId = "iosdevtest"
        user.applicationId = ALChatManager.applicationId
        return user;
        
    }
  
    class func isNilOrEmpty(_ string: NSString?) -> Bool {
        
        switch string {
        case .some(let nonNilString): return nonNilString.length == 0
        default:return true
            
        }
    }
    
// ----------------------  ------------------------------------------------------/
// convenient method to directly launch individual context-based user chat screen. UserId parameter define users for which it intented to launch chat screen.
//
// This will automatically handle unregistered users provided getLoggedinUserInformation is implemented properly.
// ----------------------  ------------------------------------------------------/
    
    func createAndLaunchChatWithSellerWithConversationProxy (_ alConversationProxy: ALConversationProxy?, fromViewController: UIViewController) {
        
        let alChatLauncher: ALChatLauncher = ALChatLauncher(applicationId: getApplicationKey() as String)
        
        let alconversationService : ALConversationService = ALConversationService()
//        alconversationService.createConversation(alConversationProxy) { (error:NSError?, proxyObject: ALConversationProxy!) -> Void in
//            
//            if((error == nil)){
//                let finalProxy : ALConversationProxy = makeFinalProxyWithGeneratedProxy(alConversationProxy!, responseProxy: proxyObject)
//                alChatLauncher.launchIndividualContextChat(finalProxy, andViewControllerObject: fromViewController, userDisplayName: "User", andWithText: nil)
//            }
//        }
    }
}

 func getApplicationKey() -> NSString {
    
    let appKey = ALUserDefaultsHandler.getApplicationKey() as NSString?
//    let applicationKey = (appKey != nil) ? appKey : ALChatManager.applicationId
     let applicationKey = appKey
    return applicationKey!;
    
}

//----------------------------------------------------------------------------------------------------
// The below method combines the conversationID got from server's response with the details already set.
//----------------------------------------------------------------------------------------------------

func makeFinalProxyWithGeneratedProxy (_ generatedProxy:ALConversationProxy, responseProxy:ALConversationProxy)->ALConversationProxy{

    let finalProxy : ALConversationProxy = ALConversationProxy()
    finalProxy.userId = generatedProxy.userId;
    finalProxy.topicDetailJson = generatedProxy.topicDetailJson;
    finalProxy.id = responseProxy.id;
    finalProxy.groupId = responseProxy.groupId;
    
    return finalProxy;
}

//--------------------------------------------------------------------------------------------------------------
// This method helps you customise various settings
//--------------------------------------------------------------------------------------------------------------

func ALDefaultChatViewSettings () {
    
    //////////////////////////   SET AUTHENTICATION-TYPE-ID FOR INTERNAL USAGE ONLY ////////////////////////
    ALUserDefaultsHandler.setUserAuthenticationTypeId(TYPE_APPLOZIC) 
    ////////////////////////// ////////////////////////// ////////////////////////// ///////////////////////

    let flag : Bool = false
    ALUserDefaultsHandler.setNavigationRightButtonHidden(flag)
    ALUserDefaultsHandler.setBottomTabBarHidden(flag)
    ALApplozicSettings.setUserProfileHidden(flag)
    ALApplozicSettings.hideRefreshButton(flag)
    ALApplozicSettings.setTitleForConversationScreen("Chats")
    
    ALApplozicSettings.setFontFace("Helvetica")
    ALApplozicSettings.setColorForReceiveMessages(UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha:1))
    ALApplozicSettings.setColorForSendMessages(UIColor(red: 66.0/255, green: 173.0/255, blue: 247.0/255, alpha:1))
    ALApplozicSettings.setColorForNavigation(UIColor(red: 66.0/255, green: 173.0/255, blue: 247.0/255, alpha:1))
    ALApplozicSettings.setColorForNavigationItem(UIColor.white)

    let appName = Bundle.main.infoDictionary!["CFBundleName"]
    ALApplozicSettings.setNotificationTitle((appName as AnyObject).string)
    ALApplozicSettings.setMaxCompressionFactor(0.1)
    ALApplozicSettings.setMaxImageSizeForUploadInMB(3)
    ALApplozicSettings.setGroupOption(true)

    ALApplozicSettings.setTitleForBackButtonChatVC("Back")
    ALApplozicSettings.setTitleForBackButtonMsgVC("Back")
    ALApplozicSettings.setColorForSendButton(UIColor(red:66.0/255, green:173.0/255, blue:247.0/255, alpha:1))
    ALApplozicSettings.setFilterContactsStatus(true);
    ALUserDefaultsHandler.setDebugLogsRequire(true);
    ALUserDefaultsHandler.setDeviceApnsType(APNS_TYPE_DEVELOPMENT);
    //For Distribution CERT::
//     ALUserDefaultsHandler.setDeviceApnsType(APNS_TYPE_DISTRIBUTION);
    
}

