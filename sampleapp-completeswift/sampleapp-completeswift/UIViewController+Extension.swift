
//
//  UIViewController+Extension.swift
//  sampleapp-completeswift
//
//  Created by Mukesh Thawani on 13/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import UIKit
import MBProgressHUD

extension UIViewController
{
    func hideKeyboard()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard()
    {
        view.endEditing(true)
    }
    
    func alert(msg: String) {
        let hud = MBProgressHUD.showAdded(to: view, animated: true)
        hud.mode = .text
        hud.label.text = msg
        hud.hide(animated: true, afterDelay: 1.0)
    }
    
    class func topViewController() -> UIViewController? {
        return self.topViewControllerWithRootViewController(rootViewController: UIApplication.shared.keyWindow?.rootViewController)
    }
    
    class func topViewControllerWithRootViewController(rootViewController: UIViewController?) -> UIViewController? {
        
        if rootViewController is UITabBarController {
            let control = rootViewController as! UITabBarController
            return self.topViewControllerWithRootViewController(rootViewController: control.selectedViewController)
        } else if rootViewController is UINavigationController {
            let control = rootViewController as! UINavigationController
            return self.topViewControllerWithRootViewController(rootViewController: control.visibleViewController)
        } else if let control = rootViewController?.presentedViewController {
            return self.topViewControllerWithRootViewController(rootViewController: control)
        }
        
        return rootViewController
        
    }
}

