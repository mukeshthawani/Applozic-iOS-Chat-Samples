//
//  LaunchChatFromSimpleVCViewController.swift
//  sampleapp-swift
//
//  Created by Devashish on 09/02/16.
//  Copyright © 2016 applozic Inc. All rights reserved.
//

import UIKit
import Applozic


class LaunchChatFromSimpleVCViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func launchList(sender: AnyObject) {
        
        let chatManager : ALChatManager = ALChatManager(applicationKey: "applozic-sample-app")
        chatManager.registerUserAndLaunchChat(getUserDetail(), fromController: self, forUser:nil)
    }
    
    @IBAction func launchUserChat(sender: AnyObject)
    {
        let chatManager : ALChatManager =  ALChatManager(applicationKey: "applozic-sample-app")
        chatManager.registerUserAndLaunchChat(getUserDetail(), fromController: self, forUser:"applozic")
    }
    
    
    @IBAction func launchSellerChat(sender: AnyObject)
    {
        var alconversationProxy : ALConversationProxy =  ALConversationProxy()
        alconversationProxy = self.makeupConversationDetails()
        
        let chatManager : ALChatManager =  ALChatManager(applicationKey: "applozic-sample-app")
        chatManager.createAndLaunchChatWithSellerWithConversationProxy(alconversationProxy, fromViewController:self)
    }

    func makeupConversationDetails() -> ALConversationProxy
    {
        let alConversationProxy : ALConversationProxy = ALConversationProxy()
        alConversationProxy.topicId = "laptop01"
        alConversationProxy.userId = "adarshk"
        
        let alTopicDetails : ALTopicDetail = ALTopicDetail()
        alTopicDetails.title     = "Mac Book Pro"
        alTopicDetails.subtitle  = "13' Retina"
        alTopicDetails.link      = "https://raw.githubusercontent.com/AppLozic/Applozic-iOS-SDK/master/macbookpro.jpg"
        alTopicDetails.key1      = "Product ID"
        alTopicDetails.value1    = "mac-pro-r-13"
        alTopicDetails.key2      = "Price"
        alTopicDetails.value2    = "Rs.1,04,999.00"
        
        let jsonData: NSData = jsonToNSData(alTopicDetails.dictionary())!
        
        let resultTopicDetails : NSString = NSString.init(data: jsonData, encoding: NSUTF8StringEncoding)!
        alConversationProxy.topicDetailJson = resultTopicDetails as String
        
        return alConversationProxy
    }
    
    func jsonToNSData(json: AnyObject) -> NSData?
    {
        do
        {
            return try NSJSONSerialization.dataWithJSONObject(json, options:NSJSONWritingOptions.PrettyPrinted)
        }
        catch let Error
        {
            print(Error)
        }
        return nil;
    }
    
    @IBAction func logout(sender: AnyObject)
    {
        let registerUserClientService: ALRegisterUserClientService = ALRegisterUserClientService()
        registerUserClientService.logout();
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    func getUserDetail() -> ALUser {
        
        // TODO:Write your won code to get userId in case of update or in case of user is not registered....
        
        let user: ALUser = ALUser()
        user.userId = ALUserDefaultsHandler.getUserId();
        user.password = ALUserDefaultsHandler.getPassword()
        user.displayName = ALUserDefaultsHandler.getDisplayName()

        user.applicationId = ALChatManager.applicationId;
        if(!ALChatManager.isNilOrEmpty(ALUserDefaultsHandler.getEmailId())){
            user.email = ALUserDefaultsHandler.getEmailId();
        }
        return user;
    }
    
    
    
}
