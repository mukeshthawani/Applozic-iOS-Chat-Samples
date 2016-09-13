//
//  AppLogicLoginViewController.swift
//  applozicswift
//
//  Created by Devashish on 30/12/15.
//  Copyright © 2015 Applozic. All rights reserved.
//

import UIKit
import Applozic

class AppLogicLoginViewController: UIViewController {

    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    
    @IBOutlet weak var emailId: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        ALUserDefaultsHandler.setUserAuthenticationTypeId(1) // APPLOZIC
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    @IBAction func getStartedBtn(sender: AnyObject) {

        let alUser : ALUser =  ALUser();
        alUser.applicationId = ALChatManager.applicationId
        
        if(ALChatManager.isNilOrEmpty( self.userName.text))
        {
            let alert = UIAlertController(title: "Applozic", message: "Please enter userId ", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return;
        }
        alUser.userId = self.userName.text
        ALUserDefaultsHandler.setUserId(alUser.userId)

        print("userName:: " , alUser.userId)
        if(!((emailId.text?.isEmpty)!)){
             alUser.email = emailId.text
             ALUserDefaultsHandler.setEmailId(alUser.email)
        }

        if (!((password.text?.isEmpty)!)){
            alUser.password = password.text
            ALUserDefaultsHandler.setPassword(alUser.password)
        }
        
        let chatManager = ALChatManager(applicationKey: "applozic-sample-app")
         chatManager.registerUser(alUser) { (response, error) in
            
            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("LaunchChatFromSimpleViewController") as UIViewController
            self.presentViewController(viewController, animated:true, completion: nil)
        }
    }
    
   
    @IBAction func moreButtonAction(sender: AnyObject) {
        
        let alUser : ALUser =  ALUser();
        alUser.applicationId = ALChatManager.applicationId
        
        if(ALChatManager.isNilOrEmpty( self.userName.text)){
            let alert = UIAlertController(title: "Applozic", message: "Please enter userId ", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Okay", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            return;
        }
        alUser.userId = self.userName.text
        ALUserDefaultsHandler.setUserId(alUser.userId)
        
        print("userName:: " , alUser.userId)
        if(!((emailId.text?.isEmpty)!)){
            
            alUser.email = emailId.text
            ALUserDefaultsHandler.setEmailId(alUser.email)
        }
        if (!((password.text?.isEmpty)!)){
            alUser.password = password.text
            ALUserDefaultsHandler.setPassword(alUser.password)
        }
        
        let chatManager = ALChatManager(applicationKey: "applozic-sample-app")
        chatManager.registerUser(alUser) { (response, error) in
            
            let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("moreTabBar") as UIViewController
            self.presentViewController(viewController, animated:true, completion: nil)
        }
    }
   
}


