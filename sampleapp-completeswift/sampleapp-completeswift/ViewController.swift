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
        registerAndLaunch()
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
        ALUserDefaultsHandler.setUserId(alUser.userId)
        ALUserDefaultsHandler.setEmailId(alUser.email)
        ALUserDefaultsHandler.setDisplayName(alUser.displayName)
        let registerUserClientService: ALRegisterUserClientService = ALRegisterUserClientService()
        registerUserClientService.initWithCompletion(alUser, withCompletion: { (response, error) in
            if error == nil {
                print("message: ", response?.message)
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "messagesNav")
                self.present(vc!, animated: true, completion: nil)
            }
        })
        }

}

