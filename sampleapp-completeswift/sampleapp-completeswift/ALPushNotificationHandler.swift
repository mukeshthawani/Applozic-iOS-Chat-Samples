//
//  ALPushNotificationHandler.swift
//  sampleapp-completeswift
//
//  Created by Mukesh Thawani on 18/05/17.
//  Copyright © 2017 Applozic. All rights reserved.
//

import Foundation
import Applozic

class ALPushNotificationHandler {
    static let shared = ALPushNotificationHandler()
    var navVC: UINavigationController?
    
    func dataConnectionNotificationHandler() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "showNotificationAndLaunchChat"), object: nil, queue: nil, using: {[weak self] notification in
            print("launch chat push notification received")
            guard let weakSelf = self, let contactId = notification.object as? String else { return }
            weakSelf.launchIndividualChatWith(userId: contactId)
        })
    }
    
    
    func launchIndividualChatWith(userId: String) {
        let storyBoard = UIStoryboard(name: "Main", bundle: Bundle(for: ALConversationViewController.self))

        
        print("Called via notification and user id is: ", userId)
        
        let messagesVC = storyBoard.instantiateViewController(withIdentifier: "ALMessagesViewController") as! ALMessagesViewController
        messagesVC.contactId = userId
        let rootVC =  UIApplication.shared.keyWindow?.rootViewController
        navVC = UINavigationController(rootViewController: messagesVC) as! UINavigationController
        navVC?.modalTransitionStyle = .crossDissolve
        rootVC?.present(navVC!, animated: true, completion: nil)
    }
    
}


