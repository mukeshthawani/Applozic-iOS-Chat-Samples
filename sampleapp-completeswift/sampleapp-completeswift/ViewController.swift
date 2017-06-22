//
//  ViewController.swift
//  sampleapp-completeswift
//
//  Created by Mukesh Thawani on 04/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import UIKit
import Applozic

class ViewController: UIViewController {

    override func viewDidAppear(_ animated: Bool) {
//        registerAndLaunch()

    }

    override func viewDidLoad() {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func registerAndLaunch() {
        let appId = ApplicationId
        let alUser = ALUser()
        alUser.applicationId = appId
        alUser.userId = UserId
        alUser.email = UserEmail
        alUser.displayName = UserDisplayName
        alUser.password = UserPassword
        registerUserToApplozic(alUser: alUser)
    }

    private func registerUserToApplozic(alUser: ALUser) {
        let alChatManager = ALChatManager(applicationKey: ALChatManager.applicationId as NSString)
        alChatManager.registerUser(alUser, completion: {response, error in
            if error == nil {
                NSLog("[REGISTRATION] Applozic user registration was successful: %@ \(response?.isRegisteredSuccessfully())")



                let conversationVC = ConversationListViewController()
                let nav = UINavigationController(rootViewController: conversationVC)
                self.present(nav, animated: false, completion: nil)
            } else {
                NSLog("[REGISTRATION] Applozic user registration error: %@", error.debugDescription)
            }
        })
    }


    @IBAction func launchChatList(_ sender: Any) {
        registerAndLaunch()
    }
}

